//
//  Services+composedCVVPINService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation
import GenericRemoteService
import GenericLoader

extension LoaderOf: Loader {}

// MARK: - CVVPINServicesClient

extension Services {
    
    typealias AuthWithPublicKeyFetcher = Fetcher<AuthenticateWithPublicKeyService.Payload, AuthenticateWithPublicKeyService.Success, AuthenticateWithPublicKeyService.Failure>
    
    typealias AuthCompletion = (Result<SessionID, AuthError>) -> Void
    typealias Auth = (@escaping AuthCompletion) -> Void
    
    enum AuthError: Error {
        
        case activationFailure
        case authenticationFailure
    }
    
    static func composedCVVPINService(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        rsaKeyPairStore: any RSAKeyPairStore,
        cvvPINCrypto: CVVPINCrypto,
        cvvPINJSONMaker: CVVPINJSONMaker,
        currentDate: @escaping () -> Date = Date.init,
        cvvPINActivationLifespan: TimeInterval,
        ephemeralLifespan: TimeInterval
    ) -> ComposedCVVPINService {
        
        let cacheLog = { logger.log(level: $0, category: .cache, message: $1, file: $2, line: $3) }
        let networkLog = { logger.log(level: $0, category: .network, message: $1, file: $2, line: $3) }
        
        // MARK: Configure Infra: Stores & Loaders
        
        let rsaKeyPairLoader = loggingLoader(
            store: rsaKeyPairStore
        )
        
        // MARK: Loaders for Ephemeral Stores
        
        let otpEventIDLoader = loggingLoader(
            store: InMemoryStore<ChangePINService.OTPEventID>()
        )
        
        let sessionKeyLoader = loggingLoader(
            store: InMemoryStore<SessionKey>()
        )
        
        let sessionIDLoader = loggingLoader(
            store: InMemoryStore<SessionID>()
        )
        
        // MARK: Configure Remote Services
        
        let (authWithPublicKeyRemoteService, bindPublicKeyRemoteService, changePINRemoteService, confirmChangePINRemoteService, formSessionKeyRemoteService, getCodeRemoteService, showCVVRemoteService) = configureRemoteServices(
            httpClient: httpClient,
            log: { networkLog(.info, $0, $1, $2) }
        )
        
        // MARK: - ECHD Key Pair
#warning("hide echdKeyPair! expose only endpoints that use it")
        let echdKeyPair = cvvPINCrypto.generateECDHKeyPair()
        
        // MARK: - Configure InitiateActivation
        
        let initiateActivationService = makeCVVPINInitiateActivationService(
            extractSharedSecret: extractSharedSecret,
            makeSecretRequestJSON: makeSecretRequestJSON,
            processGetCode: getCodeRemoteService.process,
            processFormSessionKey: formSessionKeyRemoteService.process
        )
        
        let sessionCache = CVVPINSessionCache(
            _cacheSessionID: sessionIDLoader.save,
            _cacheSessionKey: sessionKeyLoader.save
        )
        
        typealias InitiateActivation = ComposedCVVPINService.InitiateActivation
        
        let initiateActivation: InitiateActivation = { completion in
            
            initiateActivationService.activate { result in
                
                sessionCache.handleActivateResult(result, completion: completion)
            }
        }
        
        // MARK: Configure BindPublicKey Service
        
        let bindPublicKeyService = makeBindPublicKeyService(
            loadSessionID: sessionIDLoader.load(completion:),
            loadSessionKey: sessionKeyLoader.load(completion:),
            processBindPublicKey: bindPublicKeyRemoteService.process,
            makeSecretJSON: cvvPINJSONMaker.makeSecretJSON,
            cacheLog: cacheLog,
            currentDate: currentDate,
            ephemeralLifespan: ephemeralLifespan
        )
        
        let decoratedBindPublicKeyService = FetcherDecorator(
            decoratee: bindPublicKeyService,
            onSuccess: persistRSAKeyPair,
            onFailure: clearRSAKeyPairStoreOnError
        )
        
        let bindPublicKeyConfirm = FetchAdapter(
            fetch: decoratedBindPublicKeyService.fetch,
            map: { _ in () }
        )
        
        // MARK: Configure CVV-PIN AuthenticateWithPublicKey Service
        
        let authWithPublicKeyService = makeAuthWithPublicKeyService(
            prepareKeyExchange: prepareKeyExchange(completion:),
            authRemoteService: authWithPublicKeyRemoteService,
            makeSessionKey: makeSessionKey(response:completion:),
            cache: cache(success:)
        )
        
        // MARK: Configure Change PIN Service
        
        let changePINService = makeChangePINService(
            auth: auth(completion:),
            loadSession: loadChangePINSession(completion:),
            changePINRemoteService: changePINRemoteService,
            confirmChangePINRemoteService: confirmChangePINRemoteService,
            publicRSAKeyDecrypt: publicRSAKeyDecrypt(string:completion:),
            _makePINChangeJSON: cvvPINJSONMaker.makePINChangeJSON
        )
        
        let cachingChangePINService = FetcherDecorator(
            decoratee: changePINService,
            handleSuccess: cache(response:)
        )
        
        // MARK: Configure Show CVV Service
        
        let showCVVService = makeShowCVVService(
            auth: auth(completion:),
            loadSession: loadShowCVVSession(completion:),
            showCVVRemoteService: showCVVRemoteService,
            decryptString: cvvPINCrypto.rsaDecrypt(_:withPrivateKey:),
            makeShowCVVSecretJSON: cvvPINJSONMaker.makeShowCVVSecretJSON
        )
        
        // MARK: - ComposedCVVPINService
        
        let cvvPINServicesClient = ComposedCVVPINService(
            changePIN: changePINService.changePIN(for:to:otp:completion:),
            checkActivation: checkActivation(completion:),
            confirmActivation: bindPublicKeyConfirm.fetch(_:completion:),
            getPINConfirmationCode: cachingChangePINService.fetch(completion:),
            initiateActivation: initiateActivation,
            showCVV: showCVVService.showCVV(cardID:completion:),
            // TODO: add category `CVV-PIN`
            log: logger.log
        )
        
        return cvvPINServicesClient
        
        // MARK: - Helpers
        
        func loggingLoader<T>(
            store: any Store<T>
        ) -> any Loader<T> {
            
            LoggingLoaderDecorator(
                decoratee: LoaderOf(
                    store: store,
                    currentDate: currentDate
                ),
                log: cacheLog
            )
        }
        
        func checkActivation(
            completion: @escaping (Swift.Result<Void, Error>) -> Void
        ) {
            rsaKeyPairLoader.load {
                
                completion($0.map { _ in () })
            }
        }
        
        // MARK: - Auth
        
        func auth(completion: @escaping AuthCompletion) {
            
            rsaKeyPairLoader.load { result in
                
                switch result {
                case .failure:
                    completion(.failure(.activationFailure))
                    
                case let .success(rsaKeyPair):
                    auth(rsaKeyPair, completion)
                }
            }
        }
        
        func auth(
            _ rsaKeyPair: RSADomain.KeyPair,
            _ completion: @escaping AuthCompletion
        ) {
            sessionIDLoader.load { result in
                
                switch result {
                case .failure:
                    authWithPublicKeyService.fetch {
                        
                        completion(
                            $0
                                .map(\.sessionID.sessionIDValue)
                                .map(SessionID.init(sessionIDValue:))
                                .mapError { _ in .authenticationFailure })
                    }
                    
                case let .success(sessionID):
                    completion(.success(
                        .init(sessionIDValue: sessionID.sessionIDValue)
                    ))
                }
            }
        }
        
        // MARK: - AuthenticateWithPublicKey Adapters
        
        func prepareKeyExchange(
            completion: @escaping AuthenticateWithPublicKeyService.PrepareKeyExchangeCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                completion(.init {
                    
                    try cvvPINJSONMaker.makeRequestJSON(
                        publicKey: echdKeyPair.publicKey,
                        rsaKeyPair: result.get()
                    )
                })
            }
        }
        
        func makeSessionKey(
            response: AuthenticateWithPublicKeyService.Response,
            completion: @escaping AuthenticateWithPublicKeyService.MakeSessionKeyCompletion
        ) {
            completion(.init {
                
                let data = try cvvPINCrypto.extractSharedSecret(
                    from: response.publicServerSessionKey,
                    using: echdKeyPair.privateKey
                )
                
                return .init(sessionKeyValue: data)
            })
        }
        
        typealias AuthSuccess = AuthenticateWithPublicKeyService.Success
        typealias CacheCompletion = (Swift.Result<Void, Error>) -> Void
        
        func cache(
            success: AuthSuccess
        ) {
            let sessionIDPayload = (success.sessionID, success.sessionTTL)
            cacheSessionID(payload: sessionIDPayload) { _ in }
            
            let sessionKeyPayload = (success.sessionKey, success.sessionTTL)
            cacheSessionKey(payload: sessionKeyPayload) { _ in }
        }
        
        typealias CacheSessionIDPayload = (AuthSuccess.SessionID, AuthSuccess.SessionTTL)
        
        func cacheSessionID(
            payload: CacheSessionIDPayload,
            completion: @escaping CacheCompletion
        ) {
            sessionIDLoader.save(
                .init(sessionIDValue: payload.0.sessionIDValue),
                validUntil: currentDate() + .init(payload.1),
                completion: completion
            )
        }
        
        typealias CacheSessionKeyPayload = (AuthSuccess.SessionKey, AuthSuccess.SessionTTL)
        
        func cacheSessionKey(
            payload: CacheSessionKeyPayload,
            completion: @escaping CacheCompletion
        ) {
            sessionKeyLoader.save(
                .init(sessionKeyValue: payload.0.sessionKeyValue),
                validUntil: currentDate() + .init(payload.1),
                completion: completion
            )
        }
        
        // MARK: - BindPublicKeyWithEventID Adapters

        func persistRSAKeyPair(
            _ rsaKeyPair: RSADomain.KeyPair,
            completion: @escaping () -> Void
        ) {
            let validUntil = currentDate() + .init(cvvPINActivationLifespan)
            
            rsaKeyPairLoader.save(
                rsaKeyPair,
                validUntil: validUntil
            ) { result in
                #warning("result is ignored")
                completion()
            }
        }
        
        func clearRSAKeyPairStoreOnError(
            _ error: BindPublicKeyWithEventIDService.Failure,
            completion: @escaping () -> Void
        ) {
            // clear cache if retryAttempts == 0
            if case let .retry(_,_, retryAttempts: retryAttempts) = error,
               retryAttempts == 0 {
                
                rsaKeyPairStore.deleteCache { _ in completion() }
            } else {
                completion()
            }
        }
        
        // MARK: - ChangePIN Adapters
        
        func cache(response: ChangePINService.ConfirmResponse) {
            
            // short time
            let validUntil = currentDate().addingTimeInterval(ephemeralLifespan)
            
            otpEventIDLoader.save(
                response.otpEventID,
                validUntil: validUntil,
                completion: { _ in }
            )
        }
        
        typealias StringDecryptCompletion = (Result<String, Error>) -> Void
        
        func publicRSAKeyDecrypt(
            string: String,
            completion: @escaping StringDecryptCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                    
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(keyPair):
                    completion(.init {
                        
                        try cvvPINCrypto.rsaDecrypt(
                            string,
                            withPrivateKey: keyPair.privateKey
                        )
                    })
                }
            }
        }
        
        func loadChangePINSession(
            completion: @escaping LoadChangePinSessionCompletion
        ) {
            otpEventIDLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(otpEventID):
                    loadChangePINSession(otpEventID, completion)
                }
            }
        }
        
        func loadChangePINSession(
            _ otpEventID: ChangePINService.OTPEventID,
            _ completion: @escaping LoadChangePinSessionCompletion
        ) {
            sessionIDLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(sessionID):
                    loadChangePINSession(otpEventID, sessionID, completion)
                }
            }
        }
        
        func loadChangePINSession(
            _ otpEventID: ChangePINService.OTPEventID,
            _ sessionID: SessionID,
            _ completion: @escaping LoadChangePinSessionCompletion
        ) {
            sessionKeyLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(sessionKey):
                    loadChangePINSession(otpEventID, sessionID, sessionKey, completion)
                }
            }
        }
        
        func loadChangePINSession(
            _ otpEventID: ChangePINService.OTPEventID,
            _ sessionID: SessionID,
            _ sessionKey: SessionKey,
            _ completion: @escaping LoadChangePinSessionCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(rsaKeyPair):
                    completion(.success(.init(
                        otpEventID: otpEventID,
                        sessionID: sessionID,
                        sessionKey: sessionKey,
                        rsaPrivateKey: rsaKeyPair.privateKey
                    )))
                }
            }
        }
        
        // MARK: - InitiateActivation Adapters
        
        func extractSharedSecret(from string: String) throws -> Data {
            
            try cvvPINCrypto.extractSharedSecret(
                from: string,
                using: echdKeyPair.privateKey
            )
        }
        
        func makeSecretRequestJSON() throws -> Data {
            
            try cvvPINJSONMaker.makeSecretRequestJSON(
                publicKey: echdKeyPair.publicKey
            )
        }
        
        // MARK: - ShowCVV Adapters
        
        func loadShowCVVSession(
            completion: @escaping LoadShowCVVSessionCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let.success(rsaKeyPair):
                    loadShowCVVSession(rsaKeyPair, completion)
                }
            }
        }
        
        func loadShowCVVSession(
            _ rsaKeyPair: RSADomain.KeyPair,
            _ completion: @escaping LoadShowCVVSessionCompletion
        ) {
            sessionKeyLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(sessionKey):
                    completion(.success(.init(
                        rsaKeyPair: rsaKeyPair,
                        sessionKey: sessionKey
                    )))
                }
            }
        }
    }
}

// MARK: Remote Services

extension Services {
    
    typealias MappingRemoteService<Input, Output, MapResponseError: Error> = RemoteService<Input, Output, Error, Error, MapResponseError>
    
    typealias AuthWithPublicKeyRemoteService = MappingRemoteService<Data, AuthenticateWithPublicKeyService.Response, AuthenticateWithPublicKeyService.APIError>
    typealias BindPublicKeyWithEventIDRemoteService = MappingRemoteService<BindPublicKeyWithEventIDService.ProcessPayload, Void, BindPublicKeyWithEventIDService.APIError>
    typealias ChangePINRemoteService = MappingRemoteService<(SessionID, Data), Void, ChangePINService.ChangePINAPIError>
    typealias ConfirmChangePINRemoteService = MappingRemoteService<SessionID, ChangePINService.EncryptedConfirmResponse, ChangePINService.ConfirmAPIError>
    typealias FormSessionKeyRemoteService = MappingRemoteService<FormSessionKeyService.ProcessPayload, FormSessionKeyService.Response, FormSessionKeyService.APIError>
    typealias GetCodeRemoteService = MappingRemoteService<Void, GetProcessingSessionCodeService.Response, GetProcessingSessionCodeService.APIError>
    typealias ShowCVVRemoteService = MappingRemoteService<(SessionID, Data), ShowCVVService.EncryptedCVV, ShowCVVService.APIError>
    
    static func configureRemoteServices(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> (
        authWithPublicKeyRemoteService: AuthWithPublicKeyRemoteService,
        bindPublicKeyWithEventIDRemoteService: BindPublicKeyWithEventIDRemoteService,
        changePINRemoteService: ChangePINRemoteService,
        confirmChangePINRemoteService: ConfirmChangePINRemoteService,
        formSessionKeyRemoteService: FormSessionKeyRemoteService,
        getCodeRemoteService: GetCodeRemoteService,
        showCVVRemoteService: ShowCVVRemoteService
    ) {
        func remoteService<Input, Output, ResponseError: Error>(
            createRequest: @escaping LoggingRemoteServiceDecorator<Input, Output, Error, ResponseError>.CreateRequest,
            performRequest: @escaping LoggingRemoteServiceDecorator<Input, Output, Error, ResponseError>.Decoratee.PerformRequest,
            mapResponse: @escaping LoggingRemoteServiceDecorator<Input, Output, Error, ResponseError>.Decoratee.MapResponse
        ) -> MappingRemoteService<Input, Output, ResponseError> {
            
            LoggingRemoteServiceDecorator(
                createRequest: createRequest,
                performRequest: performRequest,
                mapResponse: mapResponse,
                log: log
            ).remoteService
        }
        
        let authWithPublicKeyRemoteService: AuthWithPublicKeyRemoteService = remoteService(
            createRequest: RequestFactory.makeProcessPublicKeyAuthenticationRequest(data:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapProcessPublicKeyAuthenticationResponse
        )
        
        let bindPublicKeyWithEventIDRemoteService: BindPublicKeyWithEventIDRemoteService = remoteService(
            createRequest: RequestFactory.makeBindPublicKeyWithEventIDRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapBindPublicKeyWithEventIDResponse
        )
        
        let changePINRemoteService: ChangePINRemoteService = remoteService(
            createRequest: RequestFactory.makeChangePINRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapChangePINResponse
        )
        
        let confirmChangePINRemoteService: ConfirmChangePINRemoteService = remoteService(
            createRequest: RequestFactory.makeGetPINConfirmationCodeRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapConfirmChangePINResponse
        )
        
        let formSessionKeyRemoteService: FormSessionKeyRemoteService = remoteService(
            createRequest: RequestFactory.makeSecretRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapFormSessionKeyResponse
        )
        
        let getCodeRemoteService: GetCodeRemoteService = remoteService(
            createRequest: RequestFactory.makeGetProcessingSessionCode,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapGetCodeResponse
        )
        
        let showCVVRemoteService: ShowCVVRemoteService = remoteService(
            createRequest: RequestFactory.makeShowCVVRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapShowCVVResponse
        )
        
        return (authWithPublicKeyRemoteService, bindPublicKeyWithEventIDRemoteService, changePINRemoteService, confirmChangePINRemoteService, formSessionKeyRemoteService, getCodeRemoteService, showCVVRemoteService)
    }
}

// MARK: - Adapters

private extension RemoteService where Input == Void {
    
    func process(completion: @escaping ProcessCompletion) {
        
        process((), completion: completion)
    }
}

private extension CVVPINSessionCache {
    
    typealias _CacheSessionID = (SessionID, Date, @escaping CacheCompletion) -> Void
    typealias _CacheSessionKey = (SessionKey, Date, @escaping CacheCompletion) -> Void
    
    convenience init(
        _cacheSessionID: @escaping _CacheSessionID,
        _cacheSessionKey: @escaping _CacheSessionKey,
        currentDate: @escaping CurrentDate = Date.init
    ) {
        self.init(
            cacheSessionID: { payload, completion in
                
                _cacheSessionID(payload.0, payload.1, completion)
            },
            cacheSessionKey: { payload, completion in
                
                _cacheSessionKey(payload.0, payload.1, completion)
            },
            currentDate: currentDate
        )
    }
}
