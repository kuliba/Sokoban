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
    
    typealias RSAKeyPair = RSADomain.KeyPair
    typealias AuthWithPublicKeyFetcher = Fetcher<AuthenticateWithPublicKeyService.Payload, AuthenticateWithPublicKeyService.Success, AuthenticateWithPublicKeyService.Failure>
    
    static func composedCVVPINService(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        rsaKeyPairStore: any Store<RSAKeyPair>,
        cvvPINCrypto: CVVPINCrypto,
        cvvPINJSONMaker: CVVPINJSONMaker,
        currentDate: @escaping () -> Date = Date.init,
        rsaKeyPairLifespan: TimeInterval,
        ephemeralLifespan: TimeInterval
    ) -> ComposedCVVPINService {
        
        let cacheLog = { logger.log(level: $0, category: .cache, message: $1, file: $2, line: $3) }
        let networkLog = { logger.log(level: $0, category: .network, message: $1, file: $2, line: $3) }
        
        // MARK: Configure Infra: Stores & Loaders
        
        let rsaKeyPairLoader = loggingLoaderDecorator(
            store: rsaKeyPairStore
        )
        
        // MARK: Ephemeral Stores & Loaders
        
#warning("decouple otpEventIDStore from ChangePINService with local `OTPEventID` type")
        let otpEventIDStore = InMemoryStore<ChangePINService.OTPEventID>()
        let sessionCodeStore = InMemoryStore<SessionCode>()
        let sessionKeyStore = InMemoryStore<SessionKey>()
        let sessionIDStore = InMemoryStore<SessionID>()
        
        let otpEventIDLoader = loggingLoaderDecorator(
            store: otpEventIDStore
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
            log: { networkLog(.info, $0, $1, $2) }
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
            clearCache: rsaKeyPairStore.deleteCacheIgnoringResult
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
        
        let cachingAuthWithPublicKeyService = FetcherCacheDecorator(
            decoratee: authenticateWithPublicKeyService,
            cache: cache(success:)
        )
        
        // MARK: Configure Change PIN Service
        
        let changePINService = makeChangePINService(
            rsaKeyPairLoader: rsaKeyPairLoader,
            sessionIDLoader: sessionIDLoader,
            otpEventIDLoader: otpEventIDLoader,
            sessionKeyLoader: sessionKeyLoader,
            authWithPublicKeyService: cachingAuthWithPublicKeyService,
            confirmChangePINRemoteService: confirmChangePINRemoteService,
            changePINRemoteService: changePINRemoteService,
            cvvPINCrypto: cvvPINCrypto,
            cvvPINJSONMaker: cvvPINJSONMaker,
            ephemeralLifespan: ephemeralLifespan
        )
        
        let cachingChangePINService = CachingChangePINServiceDecorator(
            decoratee: changePINService,
            cache: cache(otpEventID:completion:)
        )
        
        // MARK: Configure Show CVV Service
        
        let showCVVService = makeShowCVVService(
            rsaKeyPairLoader: rsaKeyPairLoader,
            sessionIDLoader: sessionIDLoader,
            sessionKeyLoader: sessionKeyLoader,
            authWithPublicKeyService: cachingAuthWithPublicKeyService,
            showCVVRemoteService: showCVVRemoteService,
            cvvPINCrypto: cvvPINCrypto,
            cvvPINJSONMaker: cvvPINJSONMaker
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
            log: logger.log
        )
        
        return cvvPINServicesClient
        
        // MARK: - Helpers
        
        func loggingLoaderDecorator<T>(
            store: any Store<T>
        ) -> LoggingLoaderDecorator<T> {
            
            LoggingLoaderDecorator(
                decoratee: GenericLoaderOf(
                    store: store,
                    currentDate: currentDate
                ),
                log: cacheLog
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
        
        func cache(
            success: AuthenticateWithPublicKeyService.Success
        ) {
            let payload = (success.sessionID, success.sessionTTL)
            
            cacheSessionID(payload: payload) { _ in }
            cacheSessionKey(sessionKey: success.sessionKey) { _ in }
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
                validUntil: currentDate().addingTimeInterval(ephemeralLifespan),
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

typealias MappingRemoteServiceError<MapResponseError: Error> = RemoteServiceError<Error, Error, MapResponseError>

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
            
        case .serviceError:
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
            
        case .serviceError:
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
