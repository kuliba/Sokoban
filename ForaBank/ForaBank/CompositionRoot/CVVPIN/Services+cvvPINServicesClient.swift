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
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
    
    static func cvvPINServicesClient(
        httpClient: HTTPClient,
        cvvPINCrypto: CVVPINCrypto,
        cvvPINJSONMaker: CVVPINJSONMaker,
        currentDate: @escaping () -> Date = Date.init,
        rsaKeyPairLifespan: TimeInterval,
        ephemeralLifespan: TimeInterval,
        log: @escaping Log
    ) -> (
        client: CVVPINServicesClient,
        removeRSAKeyPair: () -> Void
    ) {
        
        // MARK: Configure Infra: Persistent Stores
        
        typealias RSAKeyPair = RSADomain.KeyPair
        
        let persistentRSAKeyPairStore = KeyTagKeyChainStore<RSAKeyPair>(keyTag: .rsa)
        
        // MARK: Configure Infra: Ephemeral Stores
        
        let otpEventIDStore = InMemoryStore<ChangePINService.OTPEventID>()
        let sessionCodeStore = InMemoryStore<SessionCode>()
        let sessionKeyStore = InMemoryStore<SessionKey>()
        let sessionIDStore = InMemoryStore<SessionID>()
        
        // MARK: Configure Infra: Loaders
        
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
            log: { log(.info, .network, $0, $1, $2) }
        )
        
        // MARK: Configure CVV-PIN Services
        
        let getCodeService = GetProcessingSessionCodeService(
            process: process(completion:)
        )
        
        let cachingGetCodeService = CachingGetProcessingSessionCodeServiceDecorator(
            decoratee: getCodeService,
            cache: cache(response:completion:)
        )
        
        let echdKeyPair = cvvPINCrypto.generateECDHKeyPair()
        
        let formSessionKeyService = FormSessionKeyService(
            loadCode: loadCode(completion:),
            makeSecretRequestJSON: makeSecretRequestJSON(completion:),
            process: process(payload:completion:),
            makeSessionKey: makeSessionKey(string:completion:)
        )
        
        let cachingFormSessionKeyService = CachingFormSessionKeyServiceDecorator(
            decoratee: formSessionKeyService,
            cacheSessionID: cacheSessionID,
            cacheSessionKey: cacheSessionKey(sessionKey:completion:)
        )
        
        let bindPublicKeyWithEventIDService = BindPublicKeyWithEventIDService(
            loadEventID: loadEventID(completion:),
            makeSecretJSON: makeSecretJSON(otp:completion:),
            process: process(payload:completion:)
        )
        
        let rsaKeyPairCacheCleaningBindPublicKeyWithEventIDService = RSAKeyPairCacheCleaningBindPublicKeyWithEventIDServiceDecorator(
            decoratee: bindPublicKeyWithEventIDService,
            clearCache: persistentRSAKeyPairStore.clear
        )
        
        let activationService = CVVPINFunctionalityActivationService(
            getCode: getCode(completion:),
            formSessionKey: formSessionKey(completion:),
            bindPublicKeyWithEventID: bindPublicKeyWithEventID
        )
        
        let authenticateWithPublicKeyService = AuthenticateWithPublicKeyService(
            prepareKeyExchange: prepareKeyExchange(completion:),
            process: process(data:completion:),
            makeSessionKey: makeSessionKey(response:completion:)
        )

        let cachingAuthWithPublicKeyService = CachingAuthWithPublicKeyServiceDecorator(
            decoratee: authenticateWithPublicKeyService,
            cacheSessionID: cacheSessionID(payload:completion:),
            cacheSessionKey: cacheSessionKey(sessionKey:completion:)
        )
        
        // MARK: Configure Show CVV Service
        
        let showCVVService = ShowCVVService(
            authenticate: authenticate,
            makeJSON: makeSecretJSON,
            process: process,
            decryptCVV: decryptCVV
        )
        
        // MARK: Configure Change PIN Service
        
        let changePINService = ChangePINService(
            authenticate: authenticate,
            publicRSAKeyDecrypt: publicRSAKeyDecrypt,
            confirmProcess: confirmProcess,
            makePINChangeJSON: makePINChangeJSON,
            changePINProcess: changePINProcess
        )
        
        let cachingChangePINService = CachingChangePINServiceDecorator(
            decoratee: changePINService,
            cache: cache(otpEventID:completion:)
        )
        
        // MARK: - ComposedCVVPINService
        
        let cvvPINServicesClient = ComposedCVVPINService(
            activate: activationService.activate(completion:),
            changePIN: changePINService.changePIN(for:to:otp:completion:),
            checkActivation: checkActivation(completion:),
            confirmActivation: activationService.confirmActivation,
            getPINConfirmationCode: cachingChangePINService.getPINConfirmationCode,
            showCVV: showCVVService.showCVV(cardID:completion:),
            // TODO: add category `CVV-PIN`
            log: log
        )
                
        return (cvvPINServicesClient, removeRSAKeyPair)
        
        // MARK: - Helpers
        
        func removeRSAKeyPair() {
            
            persistentRSAKeyPairStore.clear()
            log(.info, .cache, "RSA Key Store clear initiated.", #file, #line)
        }
        
        func loggingLoaderDecorator<T>(
            store: any Store<T>
        ) -> LoggingLoaderDecorator<T> {
            
            LoggingLoaderDecorator(
                decoratee: GenericLoaderOf(
                    store: store,
                    currentDate: currentDate
                ),
                log: { log(.error, .cache, $0, $1, $2) }
            )
        }
        
        func checkActivation(
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            rsaKeyPairLoader.load {
                
                completion($0.map { _ in () })
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
        
        func process(
            data: Data,
            completion: @escaping AuthenticateWithPublicKeyService.ProcessCompletion
        ) {
            authWithPublicKeyRemoteService.process(data) {
                
                completion($0.mapError { .init($0) })
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
        
        func cacheSessionID(
            payload: CachingAuthWithPublicKeyServiceDecorator.CacheSessionIDPayload,
            completion: @escaping CachingAuthWithPublicKeyServiceDecorator.CacheCompletion
        ) {
            sessionIDLoader.save(
                .init(value: payload.0.sessionIDValue),
                validUntil: currentDate() + .init(payload.1),
                completion: completion
            )
        }
        
        func cacheSessionKey(
            sessionKey: AuthenticateWithPublicKeyService.Success.SessionKey,
            completion: @escaping CachingAuthWithPublicKeyServiceDecorator.CacheCompletion
        ) {
            sessionKeyLoader.save(
                .init(sessionKeyValue: sessionKey.sessionKeyValue),
                validUntil: currentDate().addingTimeInterval(rsaKeyPairLifespan),
                completion: completion
            )
        }
        
        // MARK: - BindPublicKeyWithEventID Adapters
        
        func loadEventID(
            completion: @escaping BindPublicKeyWithEventIDService.EventIDCompletion
        ) {
            sessionIDLoader.load {
                
                completion($0.map { .init(eventIDValue: $0.value) })
            }
        }
        
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
                        validUntil: currentDate().addingTimeInterval(rsaKeyPairLifespan)
                    ) {
                        completion($0.map { _ in data })
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        func process(
            payload: BindPublicKeyWithEventIDService.Payload,
            completion: @escaping BindPublicKeyWithEventIDService.ProcessCompletion
        ){
            bindPublicKeyWithEventIDRemoteService.process(payload) {
                
                completion($0.mapError { .init($0) })
            }
        }
        
        // MARK: - ChangePIN Adapters
        
        func authenticate(
            completion: @escaping ChangePINService.AuthenticateCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                case .failure:
                    completion(.failure(.activationFailure))
                    
                case let .success(rsaKeyPair):
                    authenticate(rsaKeyPair, completion)
                }
            }
        }
        
        func authenticate(
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
        
        typealias LoadChangePINSessionCompletion = (Result<ChangePINSession, Error>) -> Void
        
        func loadSession(
            completion: @escaping LoadChangePINSessionCompletion
        ) {
            otpEventIDLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(otpEventID):
                    loadSession(otpEventID, completion)
                }
            }
        }
        
        func loadSession(
            _ otpEventID: ChangePINService.OTPEventID,
            _ completion: @escaping LoadChangePINSessionCompletion
        ) {
            sessionIDLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(sessionID):
                    loadSession(otpEventID, sessionID, completion)
                }
            }
        }
        
        func loadSession(
            _ otpEventID: ChangePINService.OTPEventID,
            _ sessionID: SessionID,
            _ completion: @escaping LoadChangePINSessionCompletion
        ) {
            sessionKeyLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(sessionKey):
                    loadSession(otpEventID, sessionID, sessionKey, completion)
                }
            }
        }
        
        func loadSession(
            _ otpEventID: ChangePINService.OTPEventID,
            _ sessionID: SessionID,
            _ sessionKey: SessionKey,
            _ completion: @escaping LoadChangePINSessionCompletion
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
        
        struct ChangePINSession {
            
            let otpEventID: ChangePINService.OTPEventID
            let sessionID: ForaBank.SessionID
            let sessionKey: SessionKey
            let rsaPrivateKey: RSADomain.PrivateKey
        }
        
        func publicRSAKeyDecrypt(
            string: String,
            completion: @escaping ChangePINService.PublicRSAKeyDecryptCompletion
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
        
        func confirmProcess(
            sessionID: ChangePINService.SessionID,
            completion: @escaping ChangePINService.ConfirmProcessCompletion
        ) {
            confirmChangePINRemoteService.process(
                .init(value: sessionID.sessionIDValue)
            ) {
                completion(
                    $0
                        .map { .init(eventID: $0.eventID, phone: $0.phone) }
                        .mapError { .init($0) }
                )
            }
        }
        
        func makePINChangeJSON(
            cardID: ChangePINService.CardID,
            pin: ChangePINService.PIN,
            otp: ChangePINService.OTP,
            completion: @escaping ChangePINService.MakePINChangeJSONCompletion
        ) {
            loadSession { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(session):
                    let sessionID = ChangePINService.SessionID(
                        sessionIDValue: session.sessionID.value
                    )
                    
                    completion(.init {
                        
                        let json = try cvvPINJSONMaker.makePINChangeJSON(
                            sessionID: sessionID,
                            cardID: .init(cardIDValue: cardID.cardIDValue),
                            otp: .init(otpValue: otp.otpValue),
                            pin: .init(pinValue: pin.pinValue),
                            otpEventID: session.otpEventID,
                            sessionKey: session.sessionKey,
                            rsaPrivateKey: session.rsaPrivateKey
                        )
                        
                        return (sessionID, json)
                    })
                }
            }
        }
        
        func changePINProcess(
            payload: (ChangePINService.SessionID, Data),
            completion: @escaping ChangePINService.ChangePINProcessCompletion
        ) {
            changePINRemoteService.process((
                .init(value: payload.0.sessionIDValue),
                payload.1
            )) {
                completion($0.mapError { .init($0) })
            }
        }
        
        func cache(
            otpEventID: ChangePINService.OTPEventID,
            completion: @escaping CachingChangePINServiceDecorator.CacheCompletion
        ) {
            // short time
            let validUntil = currentDate().addingTimeInterval(ephemeralLifespan)
            
            otpEventIDLoader.save(
                otpEventID,
                validUntil: validUntil,
                completion: completion
            )
        }
        
        // MARK: - CVVPINFunctionalityActivation Adapters
        
        func getCode(
            completion: @escaping CVVPINFunctionalityActivationService.GetCodeCompletion
        ) {
            cachingGetCodeService.getCode { result in
                
                completion(
                    result
                        .map(CVVPINFunctionalityActivationService.GetCodeResponse.init)
                        .mapError(CVVPINFunctionalityActivationService.GetCodeResponseError.init)
                )
            }
        }
        
        func formSessionKey(
            completion: @escaping CVVPINFunctionalityActivationService.FormSessionKeyCompletion
        ) {
            cachingFormSessionKeyService.formSessionKey { result in
                
                completion(
                    result
                        .map(CVVPINFunctionalityActivationService.FormSessionKeySuccess.init)
                        .mapError(CVVPINFunctionalityActivationService.FormSessionKeyError.init)
                )
            }
        }
        
        func bindPublicKeyWithEventID(
            otp: CVVPINFunctionalityActivationService.OTP,
            completion: @escaping CVVPINFunctionalityActivationService.BindPublicKeyWithEventIDCompletion
        ) {
            rsaKeyPairCacheCleaningBindPublicKeyWithEventIDService.bind(
                otp: .init(otpValue: otp.otpValue)
            ) {
                completion($0.mapError(CVVPINFunctionalityActivationService.BindPublicKeyError.init))
            }
        }
        
        // MARK: - GetProcessingSessionCode Adapters
        
        func process(
            completion: @escaping GetProcessingSessionCodeService.ProcessCompletion
        ) {
            getCodeRemoteService.process {
                
                completion($0.mapError { .init($0) })
            }
        }
        
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
        
        // MARK: - FormSessionKey Adapters
        
        func loadCode(
            completion:@escaping FormSessionKeyService.CodeCompletion
        ) {
            sessionCodeLoader.load { result in
                
                completion(
                    result
                        .map(\.sessionCodeValue)
                        .map(FormSessionKeyService.Code.init)
                )
            }
        }
        
        func makeSecretRequestJSON(
            completion: @escaping FormSessionKeyService.SecretRequestJSONCompletion
        ) {
            completion(.init {
                
                try cvvPINJSONMaker.makeSecretRequestJSON(
                    publicKey: echdKeyPair.publicKey
                )
            })
        }
        
        func process(
            payload: FormSessionKeyService.Payload,
            completion: @escaping FormSessionKeyService.ProcessCompletion
        ) {
            formSessionKeyRemoteService.process(
                .init(code: payload.code, data: payload.data)
            ) {
                completion($0.mapError { .init($0) })
            }
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
        
        func cacheSessionID(
            payload: CachingFormSessionKeyServiceDecorator.CacheSessionIDPayload,
            completion: @escaping CachingFormSessionKeyServiceDecorator.CacheCompletion
        ) {
            sessionIDLoader.save(
                .init(value: payload.0.eventIDValue),
                validUntil: currentDate() + .init(payload.1),
                completion: completion
            )
        }
        
        #warning("is there a Session Key TTL? or using `ephemeralLifespan` is ok?")
        func cacheSessionKey(
            sessionKey: FormSessionKeyService.SessionKey,
            completion: @escaping CachingFormSessionKeyServiceDecorator.CacheCompletion
        ) {
            sessionKeyLoader.save(
                .init(sessionKeyValue: sessionKey.sessionKeyValue),
                validUntil: currentDate().addingTimeInterval(ephemeralLifespan),
                completion: completion
            )
        }
        
        // MARK: - ShowCVV Adapters
        
        func authenticate(
            completion: @escaping ShowCVVService.AuthenticateCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                case .failure:
                    completion(.failure(.activationFailure))
                    
                case let .success(rsaKeyPair):
                    authenticate(rsaKeyPair, completion)
                }
            }
        }
        
        func authenticate(
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
        
        func makeSecretJSON(
            cardID: ShowCVVService.CardID,
            sessionID: ShowCVVService.SessionID,
            completion: @escaping ShowCVVService.MakeJSONCompletion
        ) {
            loadShowCVVSession { result in
                
                completion(.init {
                    
                    let session = try result.get()
                    return try cvvPINJSONMaker.makeSecretJSON(
                        with: cardID,
                        and: sessionID,
                        rsaKeyPair: session.rsaKeyPair,
                        sessionKey: session.sessionKey
                    )
                })
            }
        }
        
        func process(
            payload: ShowCVVService.Payload,
            completion: @escaping ShowCVVService.ProcessCompletion
        ) {
            showCVVRemoteService.process((
                .init(value: payload.sessionID.sessionIDValue),
                payload.data
            )) {
                completion($0.mapError { .init($0) })
            }
        }
        
        func decryptCVV(
            encryptedCVV: ShowCVVService.EncryptedCVV,
            completion: @escaping ShowCVVService.DecryptCVVCompletion
        ) {
            loadShowCVVSession {
                
                do {
                    let rsaKeyPair = try $0.get().rsaKeyPair
                    let cvvValue = try cvvPINCrypto.rsaDecrypt(
                        encryptedCVV.encryptedCVVValue,
                        withPrivateKey: rsaKeyPair.privateKey
                    )
                    completion(.success(.init(cvvValue: cvvValue)))
                } catch {
                    completion(.failure(.serviceError(.makeJSONFailure)))
                }
            }
        }
        
        typealias LoadShowCVVSessionResult = Swift.Result<ShowCVVSession, Swift.Error>
        typealias LoadShowCVVSessionCompletion = (LoadShowCVVSessionResult) -> Void
        
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
            _ rsaKeyPair: RSAKeyPair,
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
        
        struct ShowCVVSession {
            
            let rsaKeyPair: RSAKeyPair
            let sessionKey: SessionKey
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
