//
//  Services+certificateClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

import CVVPIN_Services
import ForaCrypto
import Foundation
import GenericRemoteService

extension GenericLoaderOf: Loader {}

extension Services {
    
    static func certificateClient(
        httpClient: HTTPClient,
        keyExchangeCrypto: KeyExchangeCryptographer,
        currentDate: @escaping () -> Date = Date.init
    ) -> CertificateClient {
        
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
        
        let checkingService = CVVPINFunctionalityCheckingService(
            _loadValidPublicKey: rsaKeyPairLoader.load
        )
        
        let getCodeService = GetProcessingSessionCodeService(
            _process: getCodeRemoteService.process
        )
        
        let cachingGetCodeService = CachingGetProcessingSessionCodeServiceDecorator(
            decoratee: getCodeService,
            _cache: sessionCodeLoader.save,
            currentDate: currentDate
        )
        
        let keyPair = keyExchangeCrypto.generateP384KeyPair()
#warning("create keyExchangeCrypto after key pair generation and inject key pair into keyExchangeCrypto or another crypto to shorten calls to helpers")
        
        let formSessionKeyService = FormSessionKeyService(
            _loadCode: sessionCodeLoader.load(completion:),
            _process: formSessionKeyRemoteService.process,
            keyExchangeCrypto: keyExchangeCrypto,
            keyPair: keyPair
        )
        
        let cachingFormSessionKeyService = CachingFormSessionKeyServiceDecorator(
            decoratee: formSessionKeyService,
            _cacheSessionID: sessionIDLoader.save,
            _cacheSessionKey: sessionKeyLoader.save,
            currentDate: currentDate
        )
        
        let bindPublicKeySecretJSONMaker = BindPublicKeySecretJSONMaker<SecKey, SecKey>(
            loadSessionKey: sessionKeyLoader.load(completion:),
            saveKeyPair: {
                
                rsaKeyPairLoader.save(
                    $0,
                    validUntil: currentDate().nextYear(),
                    completion: $1)
            },
            generateKeyPair: BindPublicKeyCrypto.generateRSA4096BitKeyPair,
            signEncryptOTP: BindPublicKeyCrypto.signEncryptOTP(otp:privateKey:),
            x509Representation: BindPublicKeyCrypto.x509Representation(publicKey:),
            aesEncrypt: BindPublicKeyCrypto.aesEncrypt(data:sessionKey:)
        )
        
        let bindPublicKeyWithEventIDService = BindPublicKeyWithEventIDService(
            _loadEventID: sessionIDLoader.load(completion:),
            _makeSecretJSON: bindPublicKeySecretJSONMaker.makeSecretJSON,
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
            activateCCVPIN: { getCodeService.getCode(completion: { _ in }) },
            keyExchangeCrypto: keyExchangeCrypto,
            keyPair: keyPair
        )
        
        let cachingAuthWithPublicKeyService = CachingAuthWithPublicKeyServiceDecorator(
            decoratee: authenticateWithPublicKeyService,
            _cacheSessionID: sessionIDLoader.save,
            _cacheSessionKey: sessionKeyLoader.save,
            currentDate: currentDate
        )
        
        let showCVVService = ShowCVVService(
            _checkSession: cachingAuthWithPublicKeyService.authenticateWithPublicKey,
            loadRSAKeyPair: rsaKeyPairLoader.load(completion:),
            loadSessionKey: sessionKeyLoader.load(completion:),
            _process: showCVVRemoteService.process
        )
        
        let changePINService = ChangePINService(
            _checkSession: cachingAuthWithPublicKeyService.authenticateWithPublicKey,
            loadRSAKeyPair: rsaKeyPairLoader.load(completion:),
            loadOTPEventID: otpEventIDLoader.load(completion:),
            loadSessionID: sessionIDLoader.load(completion:),
            _confirmProcess: confirmChangePINRemoteService.process,
            _changePINProcess: changePINRemoteService.process
        )
        
        let cachingChangePINService = CachingChangePINServiceDecorator(
            decoratee: changePINService,
            _cache: otpEventIDLoader.save
        )
        
        // TODO: add category `CVV-PIN`
        let log = { LoggerAgent.shared.log(level: .debug, category: .network, message: $0) }
        
        return ComposedCVVPINService(
            log: log,
            activate: activationService.activate(completion:),
            changePIN: changePINService.changePIN(for:to:otp:completion:),
            checkActivation: checkingService.checkActivation(withFallback:completion:),
            confirmActivation: activationService.confirmActivation(withOTP:completion:),
            getPINConfirmationCode: cachingChangePINService.getPINConfirmationCode(completion:),
            showCVV: showCVVService.showCVV(cardID:completion:)
        )
    }
}

extension ComposedCVVPINService {
    
    convenience init(
        log: @escaping (String) -> Void,
        activate: @escaping Activate,
        changePIN: @escaping ChangePIN,
        checkActivation: @escaping CheckActivation,
        confirmActivation: @escaping ConfirmActivation,
        getPINConfirmationCode: @escaping GetPINConfirmationCode,
        showCVV: @escaping ShowCVV
    ) {
        self.init(
            activate: { completion in
                
                activate { result in
                    
                    switch result {
                    case let .failure(error):
                        log("Activation Failure: \(error)")
                    case let .success(phone):
                        log("Activation success: \(phone)")
                    }
                    
                    completion(result)
                }
            },
            changePIN: { cardID, pin ,otp, completion in
                
                changePIN(cardID, pin, otp) { result in
                    
                    switch result {
                    case let .failure(error):
                        log("Change PIN Failure: \(error)")
                    case .success:
                        log("Change PIN success.")
                    }
                    
                    completion(result)
                }
            },
            checkActivation: checkActivation,
            confirmActivation: { otp, completion in
                
                confirmActivation(otp) { result in
                    
                    switch result {
                    case let .failure(error):
                        log("Confirm Activation Failure: \(error)")
                    case .success:
                        log("Confirm Activation success.")
                    }
                    
                    completion(result)
                }
            },
            getPINConfirmationCode: { completion in
                
                getPINConfirmationCode { result in
                    
                    switch result {
                    case let .failure(error):
                        log("Get PIN Confirmation Code Failure: \(error)")
                    case let .success(response):
                        log("Get PIN Confirmation Code success: \(response)")
                    }
                    
                    completion(result)
                }
            },
            showCVV: { cardID, completion in
                
                showCVV(cardID) { result in
                    
                    switch result {
                    case let .failure(error):
                        log("Show CVV Failure: \(error)")
                    case let .success(cvv):
                        log("Show CVV success: \(cvv).")
                    }
                    
                    completion(result)
                }
            }
        )
    }
}

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
    
    convenience init(
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        _process: @escaping _Process,
        activateCCVPIN: @escaping ActivateCCVPIN,
        keyExchangeCrypto: KeyExchangeCryptographer,
        keyPair: P384KeyAgreementDomain.KeyPair
    ) {
        self.init(
            prepareKeyExchange: { completion in
                
                loadRSAKeyPair { result in
                    
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                        
                    case let .success(rsaKeyPair):
                        completion(.init {
                            
                            try keyExchangeCrypto.loggingMakeRequestJSON(
                                publicKey: keyPair.publicKey,
                                rsaKeyPair: rsaKeyPair
                            )
                        })
                    }
                }
            },
            process: { data, completion in
                
                _process(data) { result in
                    
                    completion(result.mapError { .init($0) })
                }
            },
            activateCCVPIN: activateCCVPIN,
            makeSessionKey: { response, completion in
                
                completion(
                    .init { try .init(
                        sessionKeyValue: keyExchangeCrypto.sharedSecret(
                            response.publicServerSessionKey,
                            keyPair.privateKey
                        )
                    )}
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
                
                _makeSecretJSON(
                    otp.otpValue,
                    completion
                )
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
    
    typealias _CheckSessionResult = Swift.Result<AuthenticateWithPublicKeyService.Success, AuthenticateWithPublicKeyService.Error>
    typealias _CheckSessionCompletion = (_CheckSessionResult) -> Void
    typealias _CheckSession = (@escaping _CheckSessionCompletion) -> Void
    
    typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
    typealias LoadRSAKeyPairResult = Swift.Result<RSAKeyPair, Swift.Error>
    typealias LoadRSAKeyPairCompletion = (LoadRSAKeyPairResult) -> Void
    typealias LoadRSAKeyPair = (@escaping LoadRSAKeyPairCompletion) -> Void
    
    typealias LoadOTPEventIDResult = Swift.Result<OTPEventID, Swift.Error>
    typealias LoadOTPEventIDCompletion = (LoadOTPEventIDResult) -> Void
    typealias LoadOTPEventID = (@escaping LoadOTPEventIDCompletion) -> Void
    
    typealias LoadSessionIDResult = Swift.Result<ForaBank.SessionID, Swift.Error>
    typealias LoadSessionIDCompletion = (LoadSessionIDResult) -> Void
    typealias LoadSessionID = (@escaping LoadSessionIDCompletion) -> Void
    
    typealias _ConfirmProcessResult = Swift.Result<EncryptedConfirmResponse, MappingRemoteServiceError<ConfirmAPIError>>
    typealias _ConfirmProcessCompletion = (_ConfirmProcessResult) -> Void
    typealias _ConfirmProcess = (ForaBank.SessionID, @escaping _ConfirmProcessCompletion) -> Void
    
    typealias _ChangePINProcessResult = Swift.Result<Void, MappingRemoteServiceError<ChangePINAPIError>>
    typealias _ChangePINProcessCompletion = (_ChangePINProcessResult) -> Void
    typealias _ChangePINProcess = ((ForaBank.SessionID, Data),@escaping _ChangePINProcessCompletion) -> Void
    
    convenience init(
        _checkSession: @escaping _CheckSession,
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        loadOTPEventID: @escaping LoadOTPEventID,
        loadSessionID: @escaping LoadSessionID,
        _confirmProcess: @escaping _ConfirmProcess,
        _changePINProcess: @escaping _ChangePINProcess
    ) {
        self.init(
            checkSession: { completion in
                
                _checkSession { result in
                    
                    completion(
                        result
                            .map(\.sessionID.sessionIDValue)
                            .map { .init(sessionIDValue: $0) }
                            .mapError { $0 }
                    )
                }
            },
            publicRSAKeyDecrypt: { string, completion in
                
                loadRSAKeyPair { result in
                    
                    switch result {
                        
                    case let .failure(error):
                        completion(.failure(error))
                        
                    case let .success(keyPair):
#warning("на bpmn схеме указано `Расшифровываем EVENT-ID открытым RSA-ключом клиента` и `Расшифровываем phone открытым RSA-ключом клиента`, но на стороне бэка шифрование производится открытым ключом переданным ранее -- ВАЖНО: ПОТЕНЦИАЛЬНА ОШИБКА - ПРОБУЮ РАСШИФРОВАТЬ ПРИВАТНЫМ КЛЮЧОМ")
                        completion(.init {
                            
                            try ForaCrypto.Crypto.loggingRSADecrypt(
                                encryptedString: string,
                                withPrivateKey: keyPair.privateKey,
                                algorithm: .rsaSignatureDigestPKCS1v15Raw
                            )
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
                
                loadOTPEventID { result in
                    
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                        
                    case let .success(otpEventID):
                        loadSessionID { result in
                            
                            switch result {
                            case let .failure(error):
                                completion(.failure(error))
                                
                            case let .success(sessionID):
                                let sessionID = ChangePINService.SessionID(sessionIDValue: sessionID.value)
                                
                                completion( .init {
                                    
                                    let maker = ChangePINSecretJSONMaker.loggingLive
                                    let json = try maker.makePINChangeJSON(
                                        sessionID: sessionID,
                                        cardID: .init(value: cardID.cardIDValue),
                                        otp: .init(value: otp.otpValue),
                                        pin: .init(value: pin.pinValue),
                                        eventID: otpEventID
                                    )
                                    
                                    return (sessionID, json)
                                })
                            }
                        }
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
                
                _getCode {
                    
                    completion($0.map { .init($0) }.mapError { $0 })
                }
            },
            formSessionKey: { completion in
                
                _formSessionKey {
                    
                    completion($0.map { .init($0) }.mapError { $0 })
                }
            },
            bindPublicKeyWithEventID: { otp, completion in
                
                _bindPublicKeyWithEventID(
                    .init(otpValue: otp.otpValue)
                ) {
                    completion($0.mapError { $0 })
                }
            }
        )
    }
}

private extension CVVPINFunctionalityCheckingService {
    
    typealias _LoadValidPublicKeyResult = Swift.Result<(publicKey: SecKey, privateKey: SecKey), Swift.Error>
    typealias _LoadValidPublicKeyCompletion = (_LoadValidPublicKeyResult) -> Void
    typealias _LoadValidPublicKey = (@escaping _LoadValidPublicKeyCompletion) -> Void
    
    convenience init(
        _loadValidPublicKey: @escaping _LoadValidPublicKey
    ) {
        self.init { completion in
            
            _loadValidPublicKey { completion($0.map { _ in () }) }
        }
    }
}

private extension FormSessionKeyService {
    
    typealias _LoadCodeResult = Swift.Result<SessionCode, Swift.Error>
    typealias _LoadCodeCompletion = (_LoadCodeResult) -> Void
    typealias _LoadCode = (@escaping _LoadCodeCompletion) -> Void
    
    typealias _ProcessResult = Swift.Result<Response, MappingRemoteServiceError<APIError>>
    typealias _ProcessCompletion = (_ProcessResult) -> Void
    typealias _Process = (Payload, @escaping _ProcessCompletion) -> Void
    
    convenience init(
        _loadCode: @escaping _LoadCode,
        _process: @escaping _Process,
        keyExchangeCrypto: KeyExchangeCryptographer,
        keyPair: P384KeyAgreementDomain.KeyPair
    ) {
        self.init(
            loadCode: { completion in
                
                _loadCode {
                    
                    completion($0.map { .init(codeValue: $0.sessionCodeValue) })
                }
            },
            makeSecretRequestJSON: { completion in
                
                completion(.init {
                    
                    try keyExchangeCrypto.loggingMakeSecretRequestJSON(
                        publicKey: keyPair.publicKey
                    )
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
                        sessionKeyValue: keyExchangeCrypto.sharedSecret(string, keyPair.privateKey)
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
    
    typealias _CheckSessionResult = Swift.Result<AuthenticateWithPublicKeyService.Success, AuthenticateWithPublicKeyService.Error>
    typealias _CheckSessionCompletion = (_CheckSessionResult) -> Void
    typealias _CheckSession = (@escaping _CheckSessionCompletion) -> Void
    
    typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
    typealias LoadRSAKeyPairResult = Swift.Result<RSAKeyPair, Swift.Error>
    typealias LoadRSAKeyPairCompletion = (LoadRSAKeyPairResult) -> Void
    typealias LoadRSAKeyPair = (@escaping LoadRSAKeyPairCompletion) -> Void
    
    typealias LoadSessionKeyResult = Swift.Result<SessionKey, Swift.Error>
    typealias LoadSessionKeyCompletion = (LoadSessionKeyResult) -> Void
    typealias LoadSessionKey = (@escaping LoadSessionKeyCompletion) -> Void
    
    typealias _ProcessResult = Swift.Result<EncryptedCVV, MappingRemoteServiceError<APIError>>
    typealias _ProcessCompletion = (_ProcessResult) -> Void
    typealias _Process = ((ForaBank.SessionID, Data), @escaping _ProcessCompletion) -> Void
    
    convenience init(
        _checkSession: @escaping _CheckSession,
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        loadSessionKey: @escaping LoadSessionKey,
        _process: @escaping _Process
    ) {
        self.init(
            checkSession: { completion in
                
                _checkSession { result in
                    
                    completion(
                        result
                            .map(\.sessionID.sessionIDValue)
                            .map { .init(sessionIDValue: $0) }
                            .mapError { $0 }
                    )
                }
            },
            makeJSON: { cardID, sessionID, completion in
                
                Self.makeShowCVVJSON(
                    cardID: cardID,
                    sessionID: sessionID,
                    loadRSAKeyPair: loadRSAKeyPair,
                    loadSessionKey: loadSessionKey,
                    completion: completion
                )
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
                
                Self.decryptCVV(
                    encryptedCVV: encryptedCVV,
                    loadRSAKeyPair: loadRSAKeyPair,
                    completion: completion
                )
            }
        )
    }
}

private extension ShowCVVService {
    
    static func makeShowCVVJSON(
        cardID: ShowCVVService.CardID,
        sessionID: ShowCVVService.SessionID,
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        loadSessionKey: @escaping LoadSessionKey,
        completion: @escaping (Swift.Result<Data, Swift.Error>) -> Void
    ) {
        loadRSAKeyPair { result in
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(keyPair):
                
                loadSessionKey { result in
                    
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                        
                    case let .success(sessionKey):
                        completion(.init {
                            
                            try makeSecretJSON(
                                with: cardID,
                                and: sessionID,
                                publicKey: keyPair.publicKey,
                                privateKey: keyPair.privateKey,
                                sessionKey: sessionKey
                            )
                        })
                    }
                }
            }
        }
    }
    
    static func makeSecretJSON(
        with cardID: ShowCVVService.CardID,
        and sessionID: ShowCVVService.SessionID,
        publicKey: SecKey,
        privateKey: SecKey,
        sessionKey: SessionKey
    ) throws -> Data {
        
        let hashSignVerify = ShowCVVCrypto.hashSignVerify(string:publicKey:privateKey:)
        let aesEncrypt = BindPublicKeyCrypto.aesEncrypt(data:sessionKey:)
        
        let concatenation = "\(cardID.cardIDValue)" + sessionID.sessionIDValue
        let signature = try hashSignVerify(concatenation, publicKey, privateKey)
        let signatureBase64 = signature.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            // int(11)
            "cardId": "\(cardID.cardIDValue)",
            // String(40)
            "sessionId": sessionID.sessionIDValue,
            // String(1024): BASE64-строка с цифровой подписью
            "signature": signatureBase64
        ] as [String: String])
        
        let encrypted = try aesEncrypt(json, sessionKey)
        
        return encrypted
    }
}

private extension ShowCVVService {
    
    static func decryptCVV(
        encryptedCVV: ShowCVVService.EncryptedCVV,
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        completion: @escaping ShowCVVService.DecryptCVVCompletion
    ) {
        loadRSAKeyPair { result in
            
            do {
                let privateKey = try result.get().privateKey
                let cvvValue = try ShowCVVCrypto.decrypt(
                    string: encryptedCVV.encryptedCVVValue,
                    withPrivateKey: privateKey
                )
                completion(.success(.init(cvvValue: cvvValue)))
            } catch {
                completion(.failure(.other(.makeJSONFailure)))
            }
        }
    }
}

// MARK: - Error Mappers

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
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
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

// MARK: - Adapters

private extension RemoteService where Input == Void {
    
    func process(completion: @escaping ProcessCompletion) {
        
        process((), completion: completion)
    }
}

// MARK: - Loggers

private extension ForaCrypto.Crypto {
    
    static func loggingRSADecrypt(
        encryptedString string: String,
        withPrivateKey privateKey: SecKey,
        algorithm: SecKeyAlgorithm,
        log: @escaping (String) -> Void = { LoggerAgent.shared.log(level: .debug, category: .crypto, message: $0) }
    ) throws -> String {
        
        do {
            let data = try decrypt(
                string,
                with: algorithm,
                using: privateKey
            )

            guard let string = String(data: data, encoding: .utf8)
            else {
                throw NSError(domain: "Data to string conversion error.", code: -1)
            }
            
            return string
        } catch {
            log("Decryption with private key failure: \(error)")
            throw error
        }
    }
}

private extension KeyExchangeCryptographer {
    
    func loggingMakeSecretRequestJSON(
        publicKey: P384KeyAgreementDomain.PublicKey,
        log: @escaping (String) -> Void = { LoggerAgent.shared.log(level: .debug, category: .crypto, message: $0) }
    ) throws -> Data {
        
        do {
            let json = try makeSecretRequestJSON(
                publicKey: publicKey
            )
            log("Make Secret JSON success: \"\(String(data: json, encoding: .utf8) ?? "n/a")\"")
            
            return json
        } catch {
            log("Make Secret JSON failure: \(error.localizedDescription)")
            throw error
        }
    }
    
    func loggingMakeRequestJSON(
        publicKey: P384KeyAgreementDomain.PublicKey,
        rsaKeyPair: RSAKeyPair,
        log: @escaping (String) -> Void = { LoggerAgent.shared.log(level: .debug, category: .crypto, message: $0) }
    ) throws -> Data {
        
        do {
            let json = try makeRequestJSON(
                publicKey: publicKey,
                rsaKeyPair: rsaKeyPair
            )
            log("Make JSON success: \"\(String(data: json, encoding: .utf8) ?? "n/a")\"")
            
            return json
        } catch {
            log("Make JSON failure: \(error.localizedDescription)")
            throw error
        }
    }
}

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
