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
    
    static func cvvPINServicesClient(
        httpClient: HTTPClient,
        cvvPINCrypto: CVVPINCrypto,
        cvvPINJSONMaker: CVVPINJSONMaker,
        currentDate: @escaping () -> Date = Date.init
    ) -> CVVPINServicesClient {
        
        // MARK: Configure Infra: Persistent Stores
        
        typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
        
        let persistentRSAKeyPairStore = KeyTagKeyChainStore<RSAKeyPair>(keyTag: .rsa)
        
        // MARK: Configure Infra: Ephemeral Stores
        
        let otpEventIDStore = InMemoryStore<ChangePINService.OTPEventID>()
        let sessionCodeStore = InMemoryStore<SessionCode>()
        let sessionKeyStore = InMemoryStore<SessionKey>()
        let sessionIDStore = InMemoryStore<SessionID>()
        
        // MARK: Configure Infra: Loaders
        
        let otpEventIDLoader = LoggingLoaderDecorator(
            decoratee: GenericLoaderOf(
                store: otpEventIDStore,
                currentDate: currentDate
            )
        )
        
        let rsaKeyPairLoader = LoggingLoaderDecorator(
            decoratee: GenericLoaderOf(
                store: persistentRSAKeyPairStore,
                currentDate: currentDate
            )
        )
        
        let sessionCodeLoader = LoggingLoaderDecorator(
            decoratee: GenericLoaderOf(
                store: sessionCodeStore,
                currentDate: currentDate
            )
        )
        
        let sessionKeyLoader = LoggingLoaderDecorator(
            decoratee: GenericLoaderOf(
                store: sessionKeyStore,
                currentDate: currentDate
            )
        )
        
        let sessionIDLoader = LoggingLoaderDecorator(
            decoratee: GenericLoaderOf(
                store: sessionIDStore,
                currentDate: currentDate
            )
        )
        
        // MARK: Configure Remote Services
        
        let (authWithPublicKeyRemoteService, bindPublicKeyWithEventIDRemoteService, changePINRemoteService, confirmChangePINRemoteService, formSessionKeyRemoteService, getCodeRemoteService, showCVVRemoteService) = configureRemoteServices(httpClient: httpClient)
        
        // MARK: Configure CVV-PIN Services
        
        let getCodeService = GetProcessingSessionCodeService(
            _process: getCodeRemoteService.process
        )
        
        let cachingGetCodeService = CachingGetProcessingSessionCodeServiceDecorator(
            decoratee: getCodeService,
            _cache: sessionCodeLoader.save,
            currentDate: currentDate
        )
        
        let keyPair = cvvPINCrypto.generateP384KeyPair()
        
        let formSessionKeyService = FormSessionKeyService(
            _loadCode: sessionCodeLoader.load(completion:),
            _process: formSessionKeyRemoteService.process,
            _makeSecretRequestJSON: cvvPINJSONMaker.makeSecretRequestJSON,
            _makeSharedSecret: cvvPINCrypto.makeSharedSecret,
            keyPair: keyPair
        )
        
        let cachingFormSessionKeyService = CachingFormSessionKeyServiceDecorator(
            decoratee: formSessionKeyService,
            _cacheSessionID: sessionIDLoader.save,
            _cacheSessionKey: sessionKeyLoader.save,
            currentDate: currentDate
        )
        
        typealias MakeBindPublicKeySecretJSONResult = Result<Data, Error>
        typealias MakeBindPublicKeySecretJSONCompletion = (MakeBindPublicKeySecretJSONResult) -> Void
        typealias MakeBindPublicKeySecretJSON = (String, @escaping MakeBindPublicKeySecretJSONCompletion) -> Void
        
        let makeBindPublicKeySecretJSON: MakeBindPublicKeySecretJSON = { otp, completion in
            
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
        
        typealias AuthSuccess = AuthenticateWithPublicKeyService.Success
        typealias AuthResult = Result<AuthSuccess, AuthError>
        typealias AuthCompletion = (AuthResult) -> Void
        typealias Authenticate = (@escaping AuthCompletion) -> Void
        
        let authenticate: Authenticate = { completion in
            
            rsaKeyPairLoader.load { result in
                
                switch result {
                case .failure:
                    completion(.failure(.activationFailure))
                    
                case .success:
                    cachingAuthWithPublicKeyService.authenticateWithPublicKey {
                        
                        completion($0.mapError { _ in .activationFailure })
                    }
                }
            }
        }
        
        let showCVVServiceAuthenticate: ShowCVVService.Authenticate = { completion in
            
            authenticate { result in
                
                completion(
                    result
                        .map(\.sessionID.sessionIDValue)
                        .map(ShowCVVService.SessionID.init)
                        .mapError(ShowCVVService.AuthenticateError.init)
                )
            }
        }
        
        let loadSession: ShowCVVService._LoadSession = { completion in
            
            rsaKeyPairLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let.success(rsaKeyPair):
                    sessionKeyLoader.load { result in
                        
                        switch result {
                        case let .failure(error):
                            completion(.failure(error))
                            
                        case let .success(sessionKey):
                            completion(.success((rsaKeyPair, sessionKey)))
                        }
                    }
                }
            }
        }
        
        let showCVVService = ShowCVVService(
            _authenticate: showCVVServiceAuthenticate,
            loadRSAKeyPair: rsaKeyPairLoader.load(completion:),
            _loadSession: loadSession,
            _makeSecretJSON: cvvPINJSONMaker.makeSecretJSON,
            _process: showCVVRemoteService.process
        )
        
        let changePINServiceAuthenticate: ChangePINService.Authenticate = { completion in
            
            authenticate { result in
                
                completion(
                    result
                        .map(\.sessionID.sessionIDValue)
                        .map(ChangePINService.SessionID.init(sessionIDValue:))
                        .mapError(ChangePINService.AuthenticateError.init)
                )
            }
        }
        
        let loadOTPSession: ChangePINService.LoadOTPSession = { completion in
            
            otpEventIDLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(otpEventID):
                    sessionIDLoader.load { result in
                        
                        switch result {
                        case let .failure(error):
                            completion(.failure(error))
                            
                        case let .success(sessionID):
                            completion(.success((otpEventID, sessionID)))
                        }
                    }
                }
            }
        }
        
        let changePINService = ChangePINService(
            _authenticate: changePINServiceAuthenticate,
            loadRSAKeyPair: rsaKeyPairLoader.load(completion:),
            loadOTPSession: loadOTPSession,
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
        
        // TODO: add category `CVV-PIN`
        let log = { LoggerAgent.shared.log(level: .debug, category: .network, message: $0) }
        
        return ComposedCVVPINService(
            log: log,
            activate: activationService.activate(completion:),
            changePIN: changePINService.changePIN(for:to:otp:completion:),
            checkActivation: checkActivation,
            confirmActivation: activationService.confirmActivation(withOTP:completion:),
            getPINConfirmationCode: cachingChangePINService.getPINConfirmationCode(completion:),
            showCVV: showCVVService.showCVV(cardID:completion:)
        )
    }
}

// MARK: Remote Services

extension Services {
    
    typealias MappingRemoteService<Input, Output, MapResponseError: Error> = RemoteService<Input, Output, Error, Error, MapResponseError>
    
    static func configureRemoteServices(
        httpClient: HTTPClient,
        log: @escaping (String) -> Void = { LoggerAgent.shared.log(level: .debug, category: .network, message: $0) }
    ) -> (
        authWithPublicKeyRemoteService: MappingRemoteService<Data, AuthenticateWithPublicKeyService.Response, AuthenticateWithPublicKeyService.APIError>,
        bindPublicKeyWithEventIDRemoteService: MappingRemoteService<BindPublicKeyWithEventIDService.Payload, Void, BindPublicKeyWithEventIDService.APIError>,
        changePINRemoteService: MappingRemoteService<(SessionID, Data), Void, ChangePINService.ChangePINAPIError>,
        confirmChangePINRemoteService: MappingRemoteService<SessionID, ChangePINService.EncryptedConfirmResponse, ChangePINService.ConfirmAPIError>,
        formSessionKeyRemoteService: MappingRemoteService<FormSessionKeyService.Payload, FormSessionKeyService.Response, FormSessionKeyService.APIError>,
        getCodeRemoteService: MappingRemoteService<Void, GetProcessingSessionCodeService.Response, GetProcessingSessionCodeService.APIError>,
        showCVVRemoteService: MappingRemoteService<(SessionID, Data), ShowCVVService.EncryptedCVV, ShowCVVService.APIError>
    ) {
        let authWithPublicKeyRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeProcessPublicKeyAuthenticationRequest(data:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapProcessPublicKeyAuthenticationResponse
        ).remoteService
        
        let bindPublicKeyWithEventIDRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeBindPublicKeyWithEventIDRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapBindPublicKeyWithEventIDResponse
        ).remoteService
        
        let changePINRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeChangePINRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapChangePINResponse
        ).remoteService
        
        let confirmChangePINRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeGetPINConfirmationCodeRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapConfirmChangePINResponse
        ).remoteService
        
        let formSessionKeyRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeSecretRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapFormSessionKeyResponse
        ).remoteService
        
        let getCodeRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeGetProcessingSessionCode,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapGetCodeResponse
        ).remoteService
        
        let showCVVRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeShowCVVRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapShowCVVResponse
        ).remoteService
        
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
    
    typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
    typealias LoadRSAKeyPairResult = Swift.Result<RSAKeyPair, Swift.Error>
    typealias LoadRSAKeyPairCompletion = (LoadRSAKeyPairResult) -> Void
    typealias LoadRSAKeyPair = (@escaping LoadRSAKeyPairCompletion) -> Void
    
    typealias _ProcessResult = Swift.Result<Response, MappingRemoteServiceError<APIError>>
    typealias _ProcessCompletion = (_ProcessResult) -> Void
    typealias _Process = (Data, @escaping _ProcessCompletion) -> Void
    
    typealias _MakeRequestJSON = (P384KeyAgreementDomain.PublicKey, RSAKeyPair) throws -> Data
    
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
                let validUntil = currentDate() + 15
                
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
                let validUntil = currentDate() + 15
                
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
    
    typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
    typealias LoadRSAKeyPairResult = Swift.Result<RSAKeyPair, Swift.Error>
    typealias LoadRSAKeyPairCompletion = (LoadRSAKeyPairResult) -> Void
    typealias LoadRSAKeyPair = (@escaping LoadRSAKeyPairCompletion) -> Void
    
    typealias LoadOTPSessionResult = Swift.Result<(OTPEventID, ForaBank.SessionID), Swift.Error>
    typealias LoadOTPSessionCompletion = (LoadOTPSessionResult) -> Void
    typealias LoadOTPSession = (@escaping LoadOTPSessionCompletion) -> Void
    
    typealias _ConfirmProcessResult = Swift.Result<EncryptedConfirmResponse, MappingRemoteServiceError<ConfirmAPIError>>
    typealias _ConfirmProcessCompletion = (_ConfirmProcessResult) -> Void
    typealias _ConfirmProcess = (ForaBank.SessionID, @escaping _ConfirmProcessCompletion) -> Void
    
    typealias _ChangePINProcessResult = Swift.Result<Void, MappingRemoteServiceError<ChangePINAPIError>>
    typealias _ChangePINProcessCompletion = (_ChangePINProcessResult) -> Void
    typealias _ChangePINProcess = ((ForaBank.SessionID, Data),@escaping _ChangePINProcessCompletion) -> Void
    
    typealias _RSADecrypt = (String, SecKey) throws -> String
    
    typealias _MakePINChangeJSON = (SessionID, CardID, OTP, PIN, OTPEventID) throws -> Data
    
    convenience init(
        _authenticate: @escaping _Authenticate,
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        loadOTPSession: @escaping LoadOTPSession,
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
                
                loadOTPSession { result in
                    
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                        
                    case let .success((otpEventID, sessionID)):
                        let sessionID = ChangePINService.SessionID(sessionIDValue: sessionID.value)
                        
                        completion(.init {
                            
                            let json = try _makePINChangeJSON(
                                sessionID,
                                .init(cardIDValue: cardID.cardIDValue),
                                .init(otpValue: otp.otpValue),
                                .init(pinValue: pin.pinValue),
                                otpEventID
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
                
//                _getCode {
//
//                    completion(
//                        $0
//                            .map { .init($0) }
//                            .mapError(GetCodeResponseError.init)
//                    )
//                }
            },
            formSessionKey: { completion in
                
//                _formSessionKey { result in
//
//                    completion(
//                        result
//                            .map(FormSessionKeyService.Success.init)
//                            .mapError(FormSessionKeyError.init))
//                }
            },
            bindPublicKeyWithEventID: { otp, completion in
                
//                _bindPublicKeyWithEventID(
//                    .init(otpValue: otp.otpValue)
//                ) {
//                    completion($0.mapError(BindPublicKeyError.init))
//                }
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
    
    typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
    typealias LoadRSAKeyPairResult = Swift.Result<RSAKeyPair, Swift.Error>
    typealias LoadRSAKeyPairCompletion = (LoadRSAKeyPairResult) -> Void
    typealias LoadRSAKeyPair = (@escaping LoadRSAKeyPairCompletion) -> Void
    
    typealias _LoadSessionResult = Swift.Result<(RSAKeyPair, SessionKey), Swift.Error>
    typealias _LoadSessionCompletion = (_LoadSessionResult) -> Void
    typealias _LoadSession = (@escaping _LoadSessionCompletion) -> Void
    
    typealias _ProcessResult = Swift.Result<EncryptedCVV, MappingRemoteServiceError<APIError>>
    typealias _ProcessCompletion = (_ProcessResult) -> Void
    typealias _Process = ((ForaBank.SessionID, Data), @escaping _ProcessCompletion) -> Void
    
    typealias _MakeSecretJSON = (CardID, SessionID, (publicKey: SecKey, privateKey: SecKey), SessionKey) throws -> Data
    
    convenience init(
        _authenticate: @escaping _Authenticate,
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        _loadSession: @escaping _LoadSession,
        _makeSecretJSON: @escaping _MakeSecretJSON,
        _process: @escaping _Process
    ) {
        self.init(
            authenticate: _authenticate,
            makeJSON: { cardID, sessionID, completion in
                
                _loadSession { result in
                    
                    completion(.init {
                        
                        let (rsaKeyPair, sessionKey) = try result.get()
                        return try _makeSecretJSON(
                            cardID,
                            sessionID,
                            rsaKeyPair,
                            sessionKey
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
                
                loadRSAKeyPair { result in
                    
                    do {
                        let privateKey = try result.get().privateKey
                        let cvvValue = try ShowCVVCrypto.decrypt(
                            string: encryptedCVV.encryptedCVVValue,
                            withPrivateKey: privateKey
                        )
                        completion(.success(.init(cvvValue: cvvValue)))
                    } catch {
                        completion(.failure(.serviceError(.makeJSONFailure)))
                    }
                }
            }
        )
    }
}

private extension CVVPINCrypto {
    
    func makeSharedSecret(
        from string: String,
        using privateKey: P384KeyAgreementDomain.PrivateKey
    ) -> Result<Data, Error> {
        
        .init {
            try makeSharedSecret(
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

// MARK: - Loggers

private extension LoggingLoaderDecorator {
    
    convenience init(
        decoratee: any Loader<T>
    ) {
        self.init(
            decoratee: decoratee,
            log: {
                LoggerAgent.shared.log(level: .debug, category: .cache, message: $0)
            }
        )
    }
}

private extension LoggingRemoteServiceDecorator {
    
    convenience init(
        createRequest: @escaping CreateRequest,
        performRequest: @escaping Decoratee.PerformRequest,
        mapResponse: @escaping Decoratee.MapResponse
    ) {
        self.init(
            createRequest: createRequest,
            performRequest: performRequest,
            mapResponse: mapResponse,
            log: {
                LoggerAgent.shared.log(level: .debug, category: .network, message: $0)
            }
        )
    }
}

// MARK: -

private extension Date {
    
    func nextYear() -> Date {
        
#if RELEASE
        addingTimeInterval(15_778_463)
#else
        addingTimeInterval(600)
#endif
    }
}
