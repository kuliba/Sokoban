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
        
        // MARK: - ECHD Key Pair
        
        let echdKeyPair = cvvPINCrypto.generateECDHKeyPair()
        
        // MARK: Configure CVV-PIN Services

        let activationService = Services.makeActivationService(
            getCodeRemoteService: getCodeRemoteService,
            sessionCodeLoader: sessionCodeLoader,
            sessionIDLoader: sessionIDLoader,
            sessionKeyLoader: sessionKeyLoader,
            formSessionKeyRemoteService: formSessionKeyRemoteService,
            bindPublicKeyWithEventIDRemoteService: bindPublicKeyWithEventIDRemoteService,
            cacheGetProcessingSessionCode: cache(response:),
            cacheFormSessionKeySuccess: cache(success:),
            onBindKeyFailure: clearRSACacheOnError,
            makeSecretJSON: makeSecretJSON(otp:completion:),
            _makeSecretRequestJSON: {
                
                try cvvPINJSONMaker.makeSecretRequestJSON(
                    publicKey: echdKeyPair.publicKey
                )
            },
            makeSessionKey: makeSessionKey(string:completion:),
            cvvPINJSONMaker: cvvPINJSONMaker
        )
        
        let authenticateWithPublicKeyService = AuthenticateWithPublicKeyService(
            prepareKeyExchange: prepareKeyExchange(completion:),
            process: process(data:completion:),
            makeSessionKey: makeSessionKey(response:completion:)
        )
        
        let cachingAuthWithPublicKeyService = FetcherDecorator(
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
        
        let cachingChangePINService = FetcherDecorator(
            decoratee: changePINService,
            cache: cache(response:)
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
            getPINConfirmationCode: cachingChangePINService.fetch(completion:),
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
            completion: @escaping (Swift.Result<Void, Error>) -> Void
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
                .init(value: payload.0.sessionIDValue),
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
                        validUntil: currentDate().addingTimeInterval(rsaKeyPairLifespan)
                    ) {
                        completion($0.map { _ in data })
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        func clearRSACacheOnError(
            _ error: BindPublicKeyWithEventIDService.Failure
        ) {
            // clear cache if retryAttempts == 0
            if case .server = error {
                rsaKeyPairStore.deleteCacheIgnoringResult()
            }
        }
        
        // MARK: - Cache (ChangePIN)
        
        func cache(response: ChangePINService.ConfirmResponse) {
            
            // short time
            let validUntil = currentDate().addingTimeInterval(ephemeralLifespan)
            
            otpEventIDLoader.save(
                response.otpEventID,
                validUntil: validUntil,
                completion: { _ in }
            )
        }
        
        // MARK: - Cache (GetProcessingSessionCode)

        func cache(
            response: GetProcessingSessionCodeService.Response
        ) {
            // Добавляем в базу данных Redis с индексом 1, запись (пару ключ-значение ) с коротким TTL (например 15 секунд), у которой ключом является session:code:to-process:<code>, где <code> - сгенерированный короткоживущий токен CODE, а значением является JSON (BSON) содержащий параметры необходимые для формирования связки клиента с его открытым ключом
            let validUntil = currentDate().addingTimeInterval(ephemeralLifespan)
            
            sessionCodeLoader.save(
                .init(sessionCodeValue: response.code),
                validUntil: validUntil,
                completion: { _ in }
            )
        }
        
        // MARK: - FormSessionKey Adapters

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
                .init(value: payload.0.eventIDValue),
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
