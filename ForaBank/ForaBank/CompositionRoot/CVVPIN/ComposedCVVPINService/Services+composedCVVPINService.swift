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

extension GenericLoaderOf: Loader {}

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
        
        // MARK: Ephemeral Stores & Loaders
        
#warning("decouple otpEventIDStore from ChangePINService with local `OTPEventID` type")
        let otpEventIDStore = InMemoryStore<ChangePINService.OTPEventID>()
        let sessionCodeStore = InMemoryStore<SessionCode>()
        let sessionKeyStore = InMemoryStore<SessionKey>()
        let sessionIDStore = InMemoryStore<SessionID>()
        
        let otpEventIDLoader = loggingLoader(
            store: otpEventIDStore
        )
        
        let sessionCodeLoader = loggingLoader(
            store: sessionCodeStore
        )
        
        let sessionKeyLoader = loggingLoader(
            store: sessionKeyStore
        )
        
        let sessionIDLoader = loggingLoader(
            store: sessionIDStore
        )
        
        // MARK: Configure Remote Services
        
        let (authWithPublicKeyRemoteService, bindPublicKeyRemoteService, changePINRemoteService, confirmChangePINRemoteService, formSessionKeyRemoteService, getCodeRemoteService, showCVVRemoteService) = configureRemoteServices(
            httpClient: httpClient,
            log: { networkLog(.info, $0, $1, $2) }
        )
        
        // MARK: - ECHD Key Pair
        
        let echdKeyPair = cvvPINCrypto.generateECDHKeyPair()
        
        // MARK: Configure CVV-PIN Activation Service
        
        let getCodeService = makeGetCodeService(
            processGetCode: getCodeRemoteService.process,
            cacheGetProcessingSessionCode: cache(response:completion:)
        )
        
        let formSessionKeyService = makeFormSessionKeyService(
            loadSessionCode: sessionCodeLoader.load(completion:),
            processFormSessionKey: formSessionKeyRemoteService.process,
            makeSecretRequestJSON: makeSecretRequestJSON,
            makeSessionKey: makeSessionKey(string:completion:),
            cacheFormSessionKey: cache(success:)
        )
        
        let bindPublicKeyService = makeBindPublicKeyService(
            loadSessionID: sessionIDLoader.load(completion:),
            processBindPublicKey: bindPublicKeyRemoteService.process,
            makeSecretJSON: makeSecretJSON(otp:completion:)
        )
        
        let decoratedBindPublicKeyService = FetcherDecorator(
            decoratee: bindPublicKeyService,
            onSuccess: persistRSAKeyPair,
            onFailure: clearRSAKeyPairStoreOnError
        )
        
        let activationService = makeActivationService(
            getCode: getCodeService.fetch,
            formSessionKey: formSessionKeyService.fetch,
            bindPublicKeyWithEventID: decoratedBindPublicKeyService.fetch
        )
        
        // MARK: - alt
        
        let adaptedGetCodeService = FetchAdapter(
            getCodeService.fetch,
            map: CVVPINInitiateActivationService.GetCodeSuccess.init,
            mapError: CVVPINInitiateActivationService.GetCodeResponseError.init
        )
        
        let adaptedFormSessionKeyService = FetchAdapter(
            formSessionKeyService.fetch,
            map: CVVPINInitiateActivationService.FormSessionKeySuccess.init,
            mapError: CVVPINInitiateActivationService.FormSessionKeyError.init
        )
        
        let initiateActivationService = CVVPINInitiateActivationService(
            getCode: adaptedGetCodeService.fetch,
            formSessionKey: adaptedFormSessionKeyService.fetch
        )
        
        let decoratedInitiateActivationService = FetchDecorator(
            initiateActivationService.activate(completion:),
            handleResult: { result, completion in
                
#warning("store result")
                completion()
            }
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
            makeShowCVVSecretJSON: cvvPINJSONMaker.makeShowCVVSecretJSON(with:and:rsaKeyPair:sessionKey:)
        )
        
        // MARK: - ComposedCVVPINService
        
        let cvvPINServicesClient = ComposedCVVPINService(
            changePIN: changePINService.changePIN(for:to:otp:completion:),
            checkActivation: checkActivation(completion:),
            confirmActivation: activationService.confirmActivation,
            getPINConfirmationCode: cachingChangePINService.fetch(completion:),
            initiateActivation: decoratedInitiateActivationService.fetch(completion:),
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
                decoratee: GenericLoaderOf(
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
        
        func makeSecretJSON(
            otp: BindPublicKeyWithEventIDService.OTP,
            completion: @escaping BindPublicKeyWithEventIDService.SecretJSONCompletion
        ) {
            sessionKeyLoader.load { result in
                
                do {
                    let sessionKey = try result.get()
                    let (data, rsaKeyPair) = try cvvPINJSONMaker.makeSecretJSON(
                        otp: otp.otpValue,
                        sessionKey: sessionKey
                    )
                    
                    rsaKeyPairLoader.save(
                        rsaKeyPair,
                        validUntil: currentDate().addingTimeInterval(cvvPINActivationLifespan)
                    ) {
                        completion($0.map { _ in data })
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        func persistRSAKeyPair(
            _ success: BindPublicKeyWithEventIDService.Success,
            completion: @escaping () -> Void
        ) {
            
#warning("finish this: load key pair from ephemeral store and save to persistent store")
    
            completion()
        }
        
        func clearRSAKeyPairStoreOnError(
            _ error: BindPublicKeyWithEventIDService.Failure,
            completion: @escaping () -> Void
        ) {
            // clear cache if retryAttempts == 0
            if case let .retry(_,_, retryAttempts: retryAttempts) = error,
               retryAttempts == 0 {
                
                rsaKeyPairStore.deleteCache { _ in completion() }
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
        
        // MARK: - FormSessionKey Adapters
        
        func makeSecretRequestJSON(
            completion: @escaping FormSessionKeyService.SecretRequestJSONCompletion
        ) {
            completion(.init {
                
                try cvvPINJSONMaker.makeSecretRequestJSON(
                    publicKey: echdKeyPair.publicKey
                )
            })
        }
        
        func makeSessionKey(
            string: String,
            completion: @escaping FormSessionKeyService.MakeSessionKeyCompletion
        ) {
            completion(.init {
                
                try .init(
                    sessionKeyValue: cvvPINCrypto.extractSharedSecret(
                        from: string,
                        using: echdKeyPair.privateKey
                    )
                )
            })
        }
        
        typealias FormSessionKeySuccess = FormSessionKeyService.Success
        typealias FormSessionKeyCacheCompletion = (Swift.Result<Void, Error>) -> Void
        
        func cache(success: FormSessionKeySuccess) {
            
            let sessionIDPayload = (success.eventID, success.sessionTTL)
            cacheSessionID(payload: sessionIDPayload) { _ in }
            
            let sessionKeyPayload = (success.sessionKey, success.sessionTTL)
            cacheSessionKey(payload: sessionKeyPayload) { _ in }
        }
        
        typealias FormSessionKeyCacheSessionIDPayload = (FormSessionKeySuccess.EventID, FormSessionKeySuccess.SessionTTL)
        
        func cacheSessionID(
            payload: FormSessionKeyCacheSessionIDPayload,
            completion: @escaping FormSessionKeyCacheCompletion
        ) {
            sessionIDLoader.save(
                .init(sessionIDValue: payload.0.eventIDValue),
                validUntil: currentDate() + .init(payload.1),
                completion: completion
            )
        }
        
        typealias FormSessionKeyCacheSessionKeyPayload = (FormSessionKeyService.SessionKey, FormSessionKeySuccess.SessionTTL)
        
        func cacheSessionKey(
            payload: FormSessionKeyCacheSessionKeyPayload,
            completion: @escaping FormSessionKeyCacheCompletion
        ) {
            sessionKeyLoader.save(
                .init(sessionKeyValue: payload.0.sessionKeyValue),
                validUntil: currentDate() + .init(payload.1),
                completion: completion
            )
        }
        
        // MARK: - GetProcessingSessionCode
        
        func cache(
            response: GetProcessingSessionCodeService.Response,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            // Добавляем в базу данных Redis с индексом 1, запись (пару ключ-значение ) с коротким TTL (например 15 секунд), у которой ключом является session:code:to-process:<code>, где <code> - сгенерированный короткоживущий токен CODE, а значением является JSON (BSON) содержащий параметры необходимые для формирования связки клиента с его открытым ключом
            let validUntil = currentDate().addingTimeInterval(ephemeralLifespan)
            
            sessionCodeLoader.save(
                .init(sessionCodeValue: response.code),
                validUntil: validUntil,
                completion: completion
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

private extension CVVPINInitiateActivationService.GetCodeSuccess {
    
    init(_ response: GetProcessingSessionCodeService.Response) {
        
        self.init(
            code: .init(codeValue: response.code),
            phone: .init(phoneValue: response.phone)
        )
    }
}

private extension CVVPINInitiateActivationService.FormSessionKeySuccess {
    
    init(_ success: FormSessionKeyService.Success) {
        
        self.init(
            sessionKey: .init(sessionKeyValue: success.sessionKey.sessionKeyValue),
            eventID: .init(eventIDValue: success.eventID.eventIDValue),
            sessionTTL: success.sessionTTL
        )
    }
}

// MARK: - Error Mappers

private extension ShowCVVService.AuthenticateError {
    
    init(_ error: Services.AuthError) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
            
        case .authenticationFailure:
            self = .authenticationFailure
        }
    }
}

private extension ChangePINService.AuthenticateError {
    
    init(_ error: Services.AuthError) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
            
        case .authenticationFailure:
            self = .authenticationFailure
        }
    }
}

private extension CVVPINInitiateActivationService.GetCodeResponseError {
    
    init(_ error: GetProcessingSessionCodeService.Error) {
        
        switch error {
        case let .invalid(statusCode: statusCode, data: data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode: statusCode, errorMessage: errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

private extension CVVPINInitiateActivationService.FormSessionKeyError {
    
    init(_ error: FormSessionKeyService.Error) {
        
        switch error {
        case let .invalid(statusCode: statusCode, data: data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode: statusCode, errorMessage: errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case .serviceError:
            self = .serviceFailure
        }
    }
}
