//
//  Services+cvvPINServicesClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

import CVVPIN_Services
import ForaCrypto
import Foundation
import GenericRemoteService

extension GenericLoaderOf: Loader {}

// MARK: - CVVPINServicesClient

extension Services {
    
    typealias Log = (LoggerAgentCategory, String, StaticString, UInt) -> Void
    
    static func cvvPINServicesClient(
        httpClient: HTTPClient,
        cvvPINCrypto: CVVPINCrypto,
        cvvPINJSONMaker: CVVPINJSONMaker,
        currentDate: @escaping () -> Date = Date.init,
        log: @escaping Log
    ) -> CVVPINServicesClient {
        
        // MARK: Configure Infra: Persistent Stores
        
        typealias RSAKeyPair = RSADomain.KeyPair
        
        let persistentRSAKeyPairStore = KeyTagKeyChainStore<RSAKeyPair>(keyTag: .rsa)
        
        // MARK: Configure Infra: Ephemeral Stores
        
        let otpEventIDStore = InMemoryStore<ChangePINService.OTPEventID>()
        let sessionCodeStore = InMemoryStore<SessionCode>()
        let sessionKeyStore = InMemoryStore<SessionKey>()
        let sessionIDStore = InMemoryStore<SessionID>()
        
        // MARK: Configure Infra: Loaders
        
        func loggingLoaderDecorator<T>(
            store: any Store<T>
        ) -> LoggingLoaderDecorator<T> {
            
            LoggingLoaderDecorator(
                decoratee: GenericLoaderOf(
                    store: store,
                    currentDate: currentDate
                ),
                log: { log(.cache, $0, $1, $2) }
            )
        }
        
        let otpEventIDLoader = loggingLoaderDecorator(
            store: otpEventIDStore
        )
        
        let rsaKeyPairLoader = loggingLoaderDecorator(
            store: persistentRSAKeyPairStore
        )
        
        let sessionCodeLoader = loggingLoaderDecorator(
            store: sessionCodeStore
        )
        
        let sessionKeyLoader = loggingLoaderDecorator(
            store: sessionKeyStore
        )
        
        let sessionIDLoader = loggingLoaderDecorator(
            store: sessionIDStore
        )
        
        // MARK: Configure Remote Services
        
        let (authWithPublicKeyRemoteService, bindPublicKeyWithEventIDRemoteService, changePINRemoteService, confirmChangePINRemoteService, formSessionKeyRemoteService, getCodeRemoteService, showCVVRemoteService) = configureRemoteServices(
            httpClient: httpClient,
            log: { log(.network, $0, $1, $2) }
        )
        
        // MARK: Configure CVV-PIN Services
        
        let getCodeService = GetProcessingSessionCodeService(
            _process: getCodeRemoteService.process
        )
        
        let cachingGetCodeService = CachingGetProcessingSessionCodeServiceDecorator(
            decoratee: getCodeService,
            _cache: sessionCodeLoader.save,
            currentDate: currentDate
        )
        
        let keyPair = cvvPINCrypto.generateECDHKeyPair()
        
        let formSessionKeyService = FormSessionKeyService(
            _loadCode: sessionCodeLoader.load(completion:),
            _process: formSessionKeyRemoteService.process,
            _makeSecretRequestJSON: cvvPINJSONMaker.makeSecretRequestJSON,
            _makeSharedSecret: cvvPINCrypto.extractSharedSecret,
            keyPair: keyPair
        )
        
        let cachingFormSessionKeyService = CachingFormSessionKeyServiceDecorator(
            decoratee: formSessionKeyService,
            _cacheSessionID: sessionIDLoader.save,
            _cacheSessionKey: sessionKeyLoader.save,
            currentDate: currentDate
        )
        
        let bindPublicKeyWithEventIDService = BindPublicKeyWithEventIDService(
            _loadEventID: sessionIDLoader.load(completion:),
            _makeSecretJSON: makeBindPublicKeySecretJSON,
            _process: bindPublicKeyWithEventIDRemoteService.process
        )
        
        let rsaKeyPairCacheCleaningBindPublicKeyWithEventIDService = RSAKeyPairCacheCleaningBindPublicKeyWithEventIDServiceDecorator(
            decoratee: bindPublicKeyWithEventIDService,
            clearCache: persistentRSAKeyPairStore.clear
        )
        
        let activationService = CVVPINFunctionalityActivationService(
            _getCode: cachingGetCodeService.getCode,
            _formSessionKey: cachingFormSessionKeyService.formSessionKey,
            _bindPublicKeyWithEventID: rsaKeyPairCacheCleaningBindPublicKeyWithEventIDService.bind
        )
        
        let authenticateWithPublicKeyService = AuthenticateWithPublicKeyService(
            loadRSAKeyPair: rsaKeyPairLoader.load(completion:),
            _process: authWithPublicKeyRemoteService.process,
            _makeRequestJSON: cvvPINJSONMaker.makeRequestJSON,
            _makeSharedSecret: cvvPINCrypto.makeSharedSecret,
            keyPair: keyPair
        )
        
        let cachingAuthWithPublicKeyService = CachingAuthWithPublicKeyServiceDecorator(
            decoratee: authenticateWithPublicKeyService,
            _cacheSessionID: sessionIDLoader.save,
            _cacheSessionKey: sessionKeyLoader.save,
            currentDate: currentDate
        )
        
        // MARK: Configure Show CVV Service
        
        let showCVVService = ShowCVVService(
            _authenticate: showCVVAuthenticate,
            _loadSession: loadShowCVVSession,
            _makeSecretJSON: cvvPINJSONMaker.makeSecretJSON,
            _process: showCVVRemoteService.process,
            _rsaDecrypt: cvvPINCrypto.rsaDecrypt(_:withPrivateKey:)
        )
        
        // MARK: Configure Change PIN Service
        
        let changePINService = ChangePINService(
            _authenticate: changePINAuthenticate,
            loadRSAKeyPair: rsaKeyPairLoader.load(completion:),
            _loadChangePINSession: loadChangePINSession,
            _confirmProcess: confirmChangePINRemoteService.process,
            _changePINProcess: changePINRemoteService.process,
            _rsaDecrypt: cvvPINCrypto.rsaDecrypt(_:withPrivateKey:),
            _makePINChangeJSON: cvvPINJSONMaker.makePINChangeJSON
        )
        
        let cachingChangePINService = CachingChangePINServiceDecorator(
            decoratee: changePINService,
            _cache: otpEventIDLoader.save
        )
        
        let checkActivation: ComposedCVVPINService.CheckActivation = { completion in
            
            rsaKeyPairLoader.load {
                
                completion($0.map { _ in () })
            }
        }
        
        return ComposedCVVPINService(
            // TODO: add category `CVV-PIN`
            log: { log(.network, $0, $1, $2) },
            activate: activationService.activate(completion:),
            changePIN: changePINService.changePIN(for:to:otp:completion:),
            checkActivation: checkActivation,
            confirmActivation: activationService.confirmActivation(withOTP:completion:),
            getPINConfirmationCode: cachingChangePINService.getPINConfirmationCode(completion:),
            showCVV: showCVVService.showCVV(cardID:completion:)
        )
        
        // MARK: - Helpers
        
        func makeBindPublicKeySecretJSON(
            otp: String,
            completion: @escaping (Result<Data, Error>) -> Void
        ) {
            sessionKeyLoader.load { result in
                
                do {
                    let sessionKey = try result.get()
                    let (data, rsaKeyPair) = try cvvPINJSONMaker.makeSecretJSON(
                        otp: otp,
                        sessionKey: sessionKey
                    )
                    
                    rsaKeyPairLoader.save(
                        rsaKeyPair,
                        validUntil: currentDate().nextYear()
                    ) {
                        completion($0.map { _ in data })
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
#warning("extract repeated")
        
        func showCVVAuthenticate(
            completion: @escaping ShowCVVService.AuthenticateCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                case .failure:
                    completion(.failure(.activationFailure))
                    
                case let .success(rsaKeyPair):
                    showCVVAuthenticate(rsaKeyPair, completion)
                }
            }
        }
        
        func showCVVAuthenticate(
            _ rsaKeyPair: RSAKeyPair,
            _ completion: @escaping ShowCVVService.AuthenticateCompletion
        ) {
            sessionIDLoader.load { result in
                
                switch result {
                case .failure:
                    cachingAuthWithPublicKeyService.authenticateWithPublicKey {
                        
                        completion(
                            $0
                                .map(\.sessionID.sessionIDValue)
                                .map(ShowCVVService.SessionID.init)
                                .mapError { _ in .authenticationFailure })
                    }
                    
                case let .success(sessionID):
                    completion(.success(
                        .init(sessionIDValue: sessionID.value)
                    ))
                }
            }
        }
        
        
        func changePINAuthenticate(
            completion: @escaping ChangePINService.AuthenticateCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                case .failure:
                    completion(.failure(.activationFailure))
                    
                case let .success(rsaKeyPair):
                    changePINAuthenticate(rsaKeyPair, completion)
                }
            }
        }
        
        func changePINAuthenticate(
            _ rsaKeyPair: RSAKeyPair,
            _ completion: @escaping ChangePINService.AuthenticateCompletion
        ) {
            sessionIDLoader.load { result in
                
                switch result {
                case .failure:
                    cachingAuthWithPublicKeyService.authenticateWithPublicKey {
                        
                        completion(
                            $0
                                .map(\.sessionID.sessionIDValue)
                                .map(ChangePINService.SessionID.init(sessionIDValue:))
                                .mapError { _ in .authenticationFailure })
                    }
                    
                case let .success(sessionID):
                    completion(.success(.init(
                        sessionIDValue: sessionID.value
                    )))
                }
            }
        }
        
        func loadShowCVVSession(
            completion: @escaping ShowCVVService._LoadSessionCompletion
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
            _ rsaKeyPair: RSAKeyPair,
            _ completion: @escaping ShowCVVService._LoadSessionCompletion
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
        
        func loadChangePINSession(
            completion: @escaping ChangePINService._LoadChangePINSessionCompletion
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
            _ completion: @escaping ChangePINService._LoadChangePINSessionCompletion
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
            _ completion: @escaping ChangePINService._LoadChangePINSessionCompletion
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
            _ completion: @escaping ChangePINService._LoadChangePINSessionCompletion
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
    }
}

// MARK: Remote Services

extension Services {
    
    typealias MappingRemoteService<Input, Output, MapResponseError: Error> = RemoteService<Input, Output, Error, Error, MapResponseError>
    
    typealias AuthWithPublicKeyRemoteService = MappingRemoteService<Data, AuthenticateWithPublicKeyService.Response, AuthenticateWithPublicKeyService.APIError>
    typealias BindPublicKeyWithEventIDRemoteService = MappingRemoteService<BindPublicKeyWithEventIDService.Payload, Void, BindPublicKeyWithEventIDService.APIError>
    typealias ChangePINRemoteService = MappingRemoteService<(SessionID, Data), Void, ChangePINService.ChangePINAPIError>
    typealias ConfirmChangePINRemoteService = MappingRemoteService<SessionID, ChangePINService.EncryptedConfirmResponse, ChangePINService.ConfirmAPIError>
    typealias FormSessionKeyRemoteService = MappingRemoteService<FormSessionKeyService.Payload, FormSessionKeyService.Response, FormSessionKeyService.APIError>
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

struct SessionCode {
    
    let sessionCodeValue: String
}

struct SessionKey {
    
    let sessionKeyValue: Data
}

// MARK: - Adapters

private extension AuthenticateWithPublicKeyService {
    
    typealias RSAKeyPair = RSADomain.KeyPair
    typealias LoadRSAKeyPairResult = Swift.Result<RSAKeyPair, Swift.Error>
    typealias LoadRSAKeyPairCompletion = (LoadRSAKeyPairResult) -> Void
    typealias LoadRSAKeyPair = (@escaping LoadRSAKeyPairCompletion) -> Void
    
    typealias _ProcessResult = Swift.Result<Response, MappingRemoteServiceError<APIError>>
    typealias _ProcessCompletion = (_ProcessResult) -> Void
    typealias _Process = (Data, @escaping _ProcessCompletion) -> Void
    
    typealias _MakeRequestJSON = (ECDHDomain.PublicKey, RSAKeyPair) throws -> Data
    
    typealias _MakeSharedSecret = (String, P384KeyAgreementDomain.PrivateKey) -> Swift.Result<Data, Swift.Error>
    
    convenience init(
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        _process: @escaping _Process,
        _makeRequestJSON: @escaping _MakeRequestJSON,
        _makeSharedSecret: @escaping _MakeSharedSecret,
        keyPair: P384KeyAgreementDomain.KeyPair
    ) {
        self.init(
            prepareKeyExchange: { completion in
                
                loadRSAKeyPair { result in
                    
                    completion(.init {
                        
                        let rsaKeyPair = try result.get()
                        return try _makeRequestJSON(keyPair.publicKey, rsaKeyPair)
                    })
                }
            },
            process: { data, completion in
                
                _process(data) {
                    
                    completion($0.mapError { .init($0) })
                }
            },
            makeSessionKey: { response, completion in
                
                completion(
                    _makeSharedSecret(
                        response.publicServerSessionKey,
                        keyPair.privateKey
                    )
                    .map(Success.SessionKey.init)
                )
            }
        )
    }
}

private extension BindPublicKeyWithEventIDService {
    
    typealias _LoadEventIDResult = Swift.Result<SessionID, Swift.Error>
    typealias _LoadEventIDCompletion = (_LoadEventIDResult) -> Void
    typealias _LoadEventID = (@escaping _LoadEventIDCompletion) -> Void
    
    typealias _MakeSecretJSONResult = Swift.Result<Data, Swift.Error>
    typealias _MakeSecretJSONCompletion = (_MakeSecretJSONResult) -> Void
    typealias _MakeSecretJSON = (String, @escaping _MakeSecretJSONCompletion) -> Void
    
    typealias _ProcessResult = Swift.Result<Void, MappingRemoteServiceError<APIError>>
    typealias _ProcessCompletion = (_ProcessResult) -> Void
    typealias _Process = (Payload, @escaping _ProcessCompletion) -> Void
    
    convenience init(
        _loadEventID: @escaping _LoadEventID,
        _makeSecretJSON: @escaping _MakeSecretJSON,
        _process: @escaping _Process
    ) {
        self.init(
            loadEventID: { completion in
                
                _loadEventID {
                    
                    completion($0.map { .init(eventIDValue: $0.value) })
                }
            },
            makeSecretJSON: { otp, completion in
                
                _makeSecretJSON(otp.otpValue, completion)
            },
            process: { input, completion in
                
                _process(input) {
                    
                    completion($0.mapError { .init($0) })
                }
            }
        )
    }
}

private extension CachingAuthWithPublicKeyServiceDecorator {
    
    typealias _CacheSessionIDCompletion = (Result<Void, Error>) -> Void
    typealias _CacheSessionID = (SessionID, Date, @escaping _CacheSessionIDCompletion) -> Void
    
    typealias _CacheSessionKeyCompletion = (Result<Void, Error>) -> Void
    typealias _CacheSessionKey = (SessionKey, Date, @escaping _CacheSessionKeyCompletion) -> Void
    
    convenience init(
        decoratee: Service,
        _cacheSessionID: @escaping _CacheSessionID,
        _cacheSessionKey: @escaping _CacheSessionKey,
        currentDate: @escaping () -> Date = Date.init
    ) {
        self.init(
            decoratee: decoratee,
            cacheSessionID: { payload, completion in
                
                _cacheSessionID(
                    .init(value: payload.0.sessionIDValue),
                    currentDate() + .init(payload.1),
                    completion
                )
            },
            cacheSessionKey: { sessionKey, completion in
                
                _cacheSessionKey(
                    .init(sessionKeyValue: sessionKey.sessionKeyValue),
                    currentDate().nextYear(),
                    completion
                )
            }
        )
    }
}

private extension CachingChangePINServiceDecorator {
    
    typealias _CacheOTPEventIDCompletion = (Result<Void, Error>) -> Void
    typealias _CacheOTPEventID = (Service.OTPEventID, Date, @escaping _CacheOTPEventIDCompletion) -> Void
    
    convenience init(
        decoratee: Service,
        _cache: @escaping _CacheOTPEventID,
        currentDate: @escaping () -> Date = Date.init
    ) {
        self.init(
            decoratee: decoratee,
            cache: { otpEventID, completion in
                
                // short time
                let validUntil = currentDate().addingShortTime()
                
                _cache(
                    otpEventID,
                    validUntil,
                    completion
                )
            }
        )
    }
}

private extension CachingFormSessionKeyServiceDecorator {
    
#warning("same shape as in CachingAuthWithPublicKeyServiceDecorator extension")
    
    typealias _CacheSessionIDCompletion = (Result<Void, Error>) -> Void
    typealias _CacheSessionID = (SessionID, Date, @escaping _CacheSessionIDCompletion) -> Void
    
    typealias _CacheSessionKeyCompletion = (Result<Void, Error>) -> Void
    typealias _CacheSessionKey = (SessionKey, Date, @escaping _CacheSessionKeyCompletion) -> Void
    
    convenience init(
        decoratee: Service,
        _cacheSessionID: @escaping _CacheSessionID,
        _cacheSessionKey: @escaping _CacheSessionKey,
        currentDate: @escaping () -> Date = Date.init
    ) {
        self.init(
            decoratee: decoratee,
            cacheSessionID: { payload, completion in
                
                _cacheSessionID(
                    .init(value: payload.0.eventIDValue),
                    currentDate() + .init(payload.1),
                    completion
                )
            },
            cacheSessionKey: { sessionKey, completion in
                
                _cacheSessionKey(
                    .init(sessionKeyValue: sessionKey.sessionKeyValue),
                    currentDate().nextYear(),
                    completion
                )
            }
        )
    }
}

private extension CachingGetProcessingSessionCodeServiceDecorator {
    
    typealias _CacheCompletion = (Result<Void, Error>) -> Void
    typealias _Cache = (SessionCode, Date, @escaping _CacheCompletion) -> Void
    
    convenience init(
        decoratee: GetProcessingSessionCodeService,
        _cache: @escaping _Cache,
        currentDate: @escaping () -> Date = Date.init
    ) {
        self.init(
            decoratee: decoratee,
            cache: { response, completion in
                
                // Добавляем в базу данных Redis с индексом 1, запись (пару ключ-значение ) с коротким TTL (например 15 секунд), у которой ключом является session:code:to-process:<code>, где <code> - сгенерированный короткоживущий токен CODE, а значением является JSON (BSON) содержащий параметры необходимые для формирования связки клиента с его открытым ключом
                let validUntil = currentDate().addingShortTime()
                
                _cache(
                    .init(sessionCodeValue: response.code),
                    validUntil,
                    completion
                )
            }
        )
    }
}

private extension ChangePINService {
    
    typealias _Authenticate = ChangePINService.Authenticate
    
    typealias LoadRSAKeyPairResult = Swift.Result<RSADomain.KeyPair, Swift.Error>
    typealias LoadRSAKeyPairCompletion = (LoadRSAKeyPairResult) -> Void
    typealias LoadRSAKeyPair = (@escaping LoadRSAKeyPairCompletion) -> Void
    
    typealias _LoadChangePINSessionResult = Swift.Result<_Session, Swift.Error>
    typealias _LoadChangePINSessionCompletion = (_LoadChangePINSessionResult) -> Void
    typealias _LoadChangePINSession = (@escaping _LoadChangePINSessionCompletion) -> Void
    
    typealias _ConfirmProcessResult = Swift.Result<EncryptedConfirmResponse, MappingRemoteServiceError<ConfirmAPIError>>
    typealias _ConfirmProcessCompletion = (_ConfirmProcessResult) -> Void
    typealias _ConfirmProcess = (ForaBank.SessionID, @escaping _ConfirmProcessCompletion) -> Void
    
    typealias _ChangePINProcessResult = Swift.Result<Void, MappingRemoteServiceError<ChangePINAPIError>>
    typealias _ChangePINProcessCompletion = (_ChangePINProcessResult) -> Void
    typealias _ChangePINProcess = ((ForaBank.SessionID, Data),@escaping _ChangePINProcessCompletion) -> Void
    
    typealias _RSADecrypt = (String, RSADomain.PrivateKey) throws -> String
    
    typealias _MakePINChangeJSON = (SessionID, CardID, OTP, PIN, OTPEventID, SessionKey, RSADomain.PrivateKey) throws -> Data
    
    convenience init(
        _authenticate: @escaping _Authenticate,
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        _loadChangePINSession: @escaping _LoadChangePINSession,
        _confirmProcess: @escaping _ConfirmProcess,
        _changePINProcess: @escaping _ChangePINProcess,
        _rsaDecrypt: @escaping _RSADecrypt,
        _makePINChangeJSON: @escaping _MakePINChangeJSON
    ) {
        self.init(
            authenticate: _authenticate,
            publicRSAKeyDecrypt: { string, completion in
                
                loadRSAKeyPair { result in
                    
                    switch result {
                        
                    case let .failure(error):
                        completion(.failure(error))
                        
                    case let .success(keyPair):
                        completion(.init {
                            
                            try _rsaDecrypt(string, keyPair.privateKey)
                        })
                    }
                }
            },
            confirmProcess: { payload, completion in
                
                _confirmProcess(
                    .init(value: payload.sessionIDValue)
                ) {
                    completion(
                        $0
                            .map { .init(eventID: $0.eventID, phone: $0.phone) }
                            .mapError { .init($0) }
                    )
                }
            },
            makePINChangeJSON: { cardID, pin, otp, completion in
                
                _loadChangePINSession { result in
                    
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                        
                    case let .success(session):
                        let sessionID = ChangePINService.SessionID(
                            sessionIDValue: session.sessionID.value
                        )
                        
                        completion(.init {
                            
                            let json = try _makePINChangeJSON(
                                sessionID,
                                .init(cardIDValue: cardID.cardIDValue),
                                .init(otpValue: otp.otpValue),
                                .init(pinValue: pin.pinValue),
                                session.otpEventID,
                                session.sessionKey,
                                session.rsaPrivateKey
                            )
                            
                            return (sessionID, json)
                        })
                    }
                }
            },
            changePINProcess: { payload, completion in
                
                _changePINProcess((
                    .init(value: payload.0.sessionIDValue),
                    payload.1
                )) {
                    completion($0.mapError { .init($0) })
                }
            }
        )
    }
    
    typealias RSAPrivateKey = RSADomain.PrivateKey
    
    struct _Session {
        
        let otpEventID: OTPEventID
        let sessionID: ForaBank.SessionID
        let sessionKey: SessionKey
        let rsaPrivateKey: RSAPrivateKey
    }
}

private extension CVVPINFunctionalityActivationService {
    
    typealias _GetCodeResult = Swift.Result<GetProcessingSessionCodeService.Response, GetProcessingSessionCodeService.Error>
    typealias _GetCodeCompletion = (_GetCodeResult) -> Void
    typealias _GetCode = (@escaping _GetCodeCompletion) -> Void
    
    typealias _FormSessionKeyResult = Swift.Result<FormSessionKeyService.Success, FormSessionKeyService.Error>
    typealias _FormSessionKeyCompletion = (_FormSessionKeyResult) -> Void
    typealias _FormSessionKey = (@escaping _FormSessionKeyCompletion) -> Void
    
    typealias _BindResult = Swift.Result<Void, BindPublicKeyWithEventIDService.Error>
    typealias _BindCompletion = (_BindResult) -> Void
    typealias _Bind = (BindPublicKeyWithEventIDService.OTP, @escaping _BindCompletion) -> Void
    
    convenience init(
        _getCode: @escaping _GetCode,
        _formSessionKey: @escaping _FormSessionKey,
        _bindPublicKeyWithEventID: @escaping _Bind
    ) {
        self.init(
            getCode: { completion in
                
                _getCode { result in
                    
                    completion(
                        result
                            .map(GetCodeResponse.init)
                            .mapError(GetCodeResponseError.init)
                    )
                }
            },
            formSessionKey: { completion in
                
                _formSessionKey { result in
                    
                    completion(
                        result
                            .map(FormSessionKeySuccess.init)
                            .mapError(FormSessionKeyError.init)
                    )
                }
            },
            bindPublicKeyWithEventID: { otp, completion in
                
                _bindPublicKeyWithEventID(
                    .init(otpValue: otp.otpValue)
                ) {
                    completion($0.mapError(BindPublicKeyError.init))
                }
            }
        )
    }
}

private extension FormSessionKeyService {
    
    typealias _LoadCodeResult = Swift.Result<SessionCode, Swift.Error>
    typealias _LoadCodeCompletion = (_LoadCodeResult) -> Void
    typealias _LoadCode = (@escaping _LoadCodeCompletion) -> Void
    
    typealias _ProcessResult = Swift.Result<Response, MappingRemoteServiceError<APIError>>
    typealias _ProcessCompletion = (_ProcessResult) -> Void
    typealias _Process = (Payload, @escaping _ProcessCompletion) -> Void
    
    typealias _MakeSecretRequestJSON = (P384KeyAgreementDomain.PublicKey) throws -> Data
    
    typealias _MakeSharedSecret = (String, P384KeyAgreementDomain.PrivateKey) throws -> Data
    
    convenience init(
        _loadCode: @escaping _LoadCode,
        _process: @escaping _Process,
        _makeSecretRequestJSON: @escaping _MakeSecretRequestJSON,
        _makeSharedSecret: @escaping _MakeSharedSecret,
        keyPair: P384KeyAgreementDomain.KeyPair
    ) {
        self.init(
            loadCode: { completion in
                
                _loadCode { result in
                    
                    completion(
                        result
                            .map(\.sessionCodeValue)
                            .map(FormSessionKeyService.Code.init)
                    )
                }
            },
            makeSecretRequestJSON: { completion in
                
                completion(.init {
                    
                    try _makeSecretRequestJSON(keyPair.publicKey)
                })
            },
            process: { payload, completion in
                
                _process(
                    .init(code: payload.code, data: payload.data)
                ) {
                    completion($0.mapError { .init($0) })
                }
            },
            makeSessionKey: { string, completion in
                
                completion(.init {
                    
                    try .init(
                        sessionKeyValue: _makeSharedSecret(
                            string,
                            keyPair.privateKey
                        )
                    )
                })
            }
        )
    }
}

private extension GetProcessingSessionCodeService {
    
    typealias _ProcessResult = Swift.Result<Response, MappingRemoteServiceError<APIError>>
    typealias _ProcessCompletion = (_ProcessResult) -> Void
    typealias _Process = (@escaping _ProcessCompletion) -> Void
    
    convenience init(
        _process: @escaping _Process
    ) {
        self.init { completion in
            
            _process {
                
                completion($0.mapError { .init($0) })
            }
        }
    }
}

private extension ShowCVVService {
    
    typealias _Authenticate = ShowCVVService.Authenticate
    
    typealias RSAKeyPair = RSADomain.KeyPair
    
    typealias _LoadSessionResult = Swift.Result<_Session, Swift.Error>
    typealias _LoadSessionCompletion = (_LoadSessionResult) -> Void
    typealias _LoadSession = (@escaping _LoadSessionCompletion) -> Void
    
    typealias _ProcessResult = Swift.Result<EncryptedCVV, MappingRemoteServiceError<APIError>>
    typealias _ProcessCompletion = (_ProcessResult) -> Void
    typealias _Process = ((ForaBank.SessionID, Data), @escaping _ProcessCompletion) -> Void
    
    typealias _MakeSecretJSON = (CardID, SessionID, RSAKeyPair, SessionKey) throws -> Data
    
    typealias RSAPrivateKey = RSADomain.PrivateKey
    typealias _RSADecrypt = (String, RSAPrivateKey) throws -> String
    
    convenience init(
        _authenticate: @escaping _Authenticate,
        _loadSession: @escaping _LoadSession,
        _makeSecretJSON: @escaping _MakeSecretJSON,
        _process: @escaping _Process,
        _rsaDecrypt: @escaping _RSADecrypt
    ) {
        self.init(
            authenticate: _authenticate,
            makeJSON: { cardID, sessionID, completion in
                
                _loadSession { result in
                    
                    completion(.init {
                        
                        let session = try result.get()
                        return try _makeSecretJSON(
                            cardID,
                            sessionID,
                            session.rsaKeyPair,
                            session.sessionKey
                        )
                    })
                }
            },
            process: { payload, completion in
                
                _process((
                    .init(value: payload.sessionID.sessionIDValue),
                    payload.data
                )) {
                    completion($0.mapError { .init($0) })
                }
            },
            decryptCVV: { encryptedCVV, completion in
                
                _loadSession {
                    
                    do {
                        let rsaKeyPair = try $0.get().rsaKeyPair
                        let cvvValue = try _rsaDecrypt(
                            encryptedCVV.encryptedCVVValue,
                            rsaKeyPair.privateKey
                        )
                        completion(.success(.init(cvvValue: cvvValue)))
                    } catch {
                        completion(.failure(.serviceError(.makeJSONFailure)))
                    }
                }
            }
        )
    }
    
    struct _Session {
        
        let rsaKeyPair: RSAKeyPair
        let sessionKey: SessionKey
    }
}

private extension CVVPINCrypto {
    
    func makeSharedSecret(
        from string: String,
        using privateKey: P384KeyAgreementDomain.PrivateKey
    ) -> Result<Data, Error> {
        
        .init {
            try extractSharedSecret(
                from: string,
                using: privateKey
            )
        }
    }
}

// MARK: - Error Mappers

enum AuthError: Error {
    
    case activationFailure
    case authenticationFailure
}

private extension ShowCVVService.AuthenticateError {
    
    init(_ error: AuthError) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
            
        case .authenticationFailure:
            self = .authenticationFailure
        }
    }
}

private extension ChangePINService.AuthenticateError {
    
    init(_ error: AuthError) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
            
        case .authenticationFailure:
            self = .authenticationFailure
        }
    }
}

private typealias MappingRemoteServiceError<MapResponseError: Error> = RemoteServiceError<Error, Error, MapResponseError>

private extension AuthenticateWithPublicKeyService.APIError {
    
    init(_ error: MappingRemoteServiceError<AuthenticateWithPublicKeyService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

private extension BindPublicKeyWithEventIDService.APIError {
    
    init(_ error: MappingRemoteServiceError<BindPublicKeyWithEventIDService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

private extension ChangePINService.ChangePINAPIError {
    
    init(_ error: MappingRemoteServiceError<ChangePINService.ChangePINAPIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

private extension ChangePINService.ConfirmAPIError {
    
    init(_ error: MappingRemoteServiceError<ChangePINService.ConfirmAPIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

private extension FormSessionKeyService.APIError {
    
    init(_ error: MappingRemoteServiceError<FormSessionKeyService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

private extension CVVPINFunctionalityActivationService.GetCodeResponseError {
    
    init(_ error: GetProcessingSessionCodeService.Error) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

private extension CVVPINFunctionalityActivationService.FormSessionKeyError {
    
    init(_ error: FormSessionKeyService.Error) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case .other:
            self = .serviceFailure
        }
    }
}

private extension CVVPINFunctionalityActivationService.BindPublicKeyError {
    
    init(_ error: BindPublicKeyWithEventIDService.Error) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .retry(statusCode, errorMessage, retryAttempts):
            self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case .other:
            self = .serviceFailure
        }
    }
}

private extension GetProcessingSessionCodeService.APIError {
    
    init(_ error: MappingRemoteServiceError<GetProcessingSessionCodeService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

private extension ShowCVVService.APIError {
    
    init(_ error: MappingRemoteServiceError<ShowCVVService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .connectivity
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

private extension RemoteService where Input == Void {
    
    func process(completion: @escaping ProcessCompletion) {
        
        process((), completion: completion)
    }
}

// MARK: - Mappers

private extension CVVPINFunctionalityActivationService.FormSessionKeySuccess {
    
    init(_ success: FormSessionKeyService.Success) {
        
        self.init(
            sessionKey: .init(sessionKeyValue: success.sessionKey.sessionKeyValue),
            eventID: .init(eventIDValue: success.eventID.eventIDValue),
            sessionTTL: success.sessionTTL
        )
    }
}

private extension CVVPINFunctionalityActivationService.GetCodeResponse {
    
    init(_ response: GetProcessingSessionCodeService.Response) {
        
        self.init(code: response.code, phone: response.phone)
    }
}

// MARK: - NextYear

private extension Date {
    
    func addingShortTime() -> Self {
        
        addingTimeInterval(30)
    }
    
    func nextYear() -> Date {
        
#if RELEASE
        addingTimeInterval(15_778_463)
#else
        addingTimeInterval(600)
#endif
    }
}
