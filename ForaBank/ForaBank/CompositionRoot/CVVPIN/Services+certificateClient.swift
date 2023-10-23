//
//  Services+certificateClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

import CVVPIN_Services
import Foundation
import GenericRemoteService

extension Services {
    
    static func certificateClient(
        httpClient: HTTPClient,
        cryptographer: KeyExchangeCryptographer,
        currentDate: @escaping () -> Date = Date.init
    ) -> CertificateClient {
        
        // MARK: - Configure Infra: Persistent Stores
        
        typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
        
        let persistentRSAKeyPairStore = KeyTagKeyChainStore<RSAKeyPair>(keyTag: .rsa)
        
        // MARK: - Configure Infra: Ephemeral Stores
        
        let eventIDStore = InMemoryStore<EventID>()
        let sessionCodeStore = InMemoryStore<SessionCode>()
        let sessionKeyStore = InMemoryStore<SessionKey>()
        let sessionIDStore = InMemoryStore<SessionID>()
        
        // MARK: - Configure Infra: Loaders
        
        let eventIDLoader = GenericLoaderOf(
            loggingStore: eventIDStore,
            currentDate: currentDate
        )
        
        let rsaKeyPairLoader = GenericLoaderOf(
            loggingStore: persistentRSAKeyPairStore,
            currentDate: currentDate
        )
        
        let sessionCodeLoader = GenericLoaderOf(
            loggingStore: sessionCodeStore,
            currentDate: currentDate
        )
        
        let sessionKeyLoader = GenericLoaderOf(
            loggingStore: sessionKeyStore,
            currentDate: currentDate
        )
        
        let sessionIDLoader = GenericLoaderOf(
            loggingStore: sessionIDStore,
            currentDate: currentDate
        )
        
        // MARK: - Configure Remote Services
        
        let (getCodeRemoteService, formSessionKeyRemoteService, bindPublicKeyWithEventIDRemoteService, showCVVRemoteService, confirmChangePINRemoteService, changePINRemoteService) = configureRemoteServices(httpClient: httpClient)
        
        // MARK: - Configure CVV-PIN Services
        
        typealias CVVPINCheckingService = ComposedCVVPINService.CVVPINCheckingService
        typealias CVVPINActivationService = ComposedCVVPINService.CVVPINActivationService
        
        let checkingService = CVVPINCheckingService(
            loadValidPublicKey: { [rsaKeyPairLoader] completion in
                
                rsaKeyPairLoader.load { completion($0.map { _ in () }) }
            }
        )
        
        let getCodeService = GetProcessingSessionCodeService(
            process: { completion in
                
                getCodeRemoteService.get {
                    
                    completion($0.mapError { .init($0) })
                }
            }
        )
        
        let cachingGetCodeService = CachingGetProcessingSessionCodeServiceDecorator(
            decoratee: getCodeService,
            cache: {
                
                sessionCodeLoader.saveAndForget(
                    .init(sessionCode: $0.code),
                    currentDate()
                )
            }
        )
     
        let keyPair = cryptographer.generateP384KeyPair()
        
        let formSessionKeyService = FormSessionKeyService(
            loadCode: { completion in
                
                sessionCodeLoader.load {
                    
                    completion($0.map { .init(code: $0.sessionCode) })
                }
            },
            makeSecretRequestJSON: { completion in
                
                completion(.init {
                    try cryptographer.makeSecretRequestJSON(
                        publicKey: keyPair.publicKey
                    )
                })
            },
            process: { payload, completion in
                
                formSessionKeyRemoteService.process(
                    .init(code: payload.code, data: payload.data)
                ) {
                    completion($0.mapError { .init($0) })
                }
            },
            makeSessionKey: { string, completion in
                
                completion(
                    .init(catching: { try .init(
                        sessionKey: cryptographer.sharedSecret(string, keyPair.privateKey)
                    )})
                )
            }
        )
        
        let cachingFormSessionKeyService = CachingFormSessionKeyServiceDecorator(
            decoratee: formSessionKeyService,
            cache: {
                sessionKeyLoader.saveAndForget(
                    .init(sessionKey: $0.sessionKey), currentDate()
                )
            }
        )
        
        let bindPublicKeyWithEventIDService = BindPublicKeyWithEventIDService(
            loadEventID: { completion in
                
                eventIDLoader.load {
                    
                    completion($0.map { .init(eventID: $0.value) })
                }
            },
            makeSecretJSON: { _, completion in
                
                completion(.init {
                    
                    #warning("UNIMPLEMENTED")
                    throw NSError(domain: "Unimplemented.", code: -1)
                })
            },
            process: { input, completion in
                
                bindPublicKeyWithEventIDRemoteService.process(input) {
                    
                    completion($0.mapError { .init($0) })
                }
            }
        )
        
        let rsaKeyPairCacheCleaningBindPublicKeyWithEventIDService = RSAKeyPairCacheCleaningBindPublicKeyWithEventIDServiceDecorator(
            decoratee: bindPublicKeyWithEventIDService,
            clearCache: persistentRSAKeyPairStore.clear
        )
        
        let activationService = CVVPINActivationService(
            getCode: { completion in
                
                cachingGetCodeService.getCode {
                    
                    completion($0.map { .init($0) }.mapError { $0 })
                }
            },
            formSessionKey: { completion in
                
                cachingFormSessionKeyService.formSessionKey { result in
                    
                    completion(
                        result
                            .map { .init(sessionKey: $0.sessionKey) }
                            .mapError { $0 }
                    )
                }
            },
            bindPublicKeyWithEventID: { otp, completion in
                
                rsaKeyPairCacheCleaningBindPublicKeyWithEventIDService.bind(
                    otp: .init(otp: otp.otp)
                ) {
                    completion($0.mapError { $0 })
                }
            }
        )
        
        let checkSession = sessionIDLoader.load(completion:)
        
        let showCVVService = ShowCVVService(
            checkSession: { completion in
                
                checkSession { completion($0.map { .init(sessionID: $0.value) }) }
            },
            makeJSON: { _,_, completion in
                
                #warning("UNIMPLEMENTED")
                completion(.failure(.other(.makeJSONFailure)))
            },
            process: { payload, completion in
                
                showCVVRemoteService.process((
                    .init(value: payload.sessionID.sessionID),
                    payload.data
                )) {
                    completion($0.mapError { .init($0) })
                }
            },
            decryptCVV: { _, completion in
                #warning("UNIMPLEMENTED")
                completion(.failure(.other(.makeJSONFailure)))
            }
        )
        
        let changePINService = ChangePINService(
            checkSession: { completion in
                
                checkSession { completion($0.map { .init(sessionID: $0.value) }) }
            },
            publicRSAKeyDecrypt: { _, completion in
                
                completion(.init {
                    
                    #warning("UNIMPLEMENTED")
                    throw NSError(domain: "Unimplemented", code: -1)
                })
            },
            confirmProcess: { payload, completion in
                
                confirmChangePINRemoteService.process(
                    .init(value: payload.sessionID)
                ) {
                    completion(
                        $0
                            .map { .init(eventID: $0.eventID, phone: $0.phone) }
                            .mapError { .init($0) }
                    )
                }
            },
            makePINChangeJSON: { _,_,_, completion in
                
                completion( .init {
                    #warning("UNIMPLEMENTED")
                    throw NSError(domain: "Unimplemented", code: -1)
                })
            },
            changePINProcess: { payload, completion in
                
                changePINRemoteService.process((
                    .init(value: payload.0.sessionID),
                    payload.1
                )) {
                    completion($0.mapError { .init($0) })
                }
            }
        )
        
        return ComposedCVVPINService(
            cvvPINCheckingService: checkingService,
            cvvPINActivationService: activationService,
            showCVVService: showCVVService,
            changePINService: changePINService
        )
    }
    
    typealias MappingRemoteService<Input, Output, MapResponseError: Error> = RemoteService<Input, Output, Error, Error, MapResponseError>
    
    static func configureRemoteServices(
        httpClient: HTTPClient,
        log: @escaping (String) -> Void = { LoggerAgent.shared.log(level: .debug, category: .network, message: $0) }
    ) -> (
        getCodeRemoteService: MappingRemoteService<Void, GetProcessingSessionCodeService.Response, GetProcessingSessionCodeService.APIError>,
        formSessionKeyRemoteService: MappingRemoteService<FormSessionKeyService.Payload, FormSessionKeyService.Response, FormSessionKeyService.APIError>,
        bindPublicKeyWithEventIDRemoteService: MappingRemoteService<BindPublicKeyWithEventIDService.Payload, Void, BindPublicKeyWithEventIDService.APIError>,
        showCVVRemoteService: MappingRemoteService<(SessionID, Data), ShowCVVService.EncryptedCVV, ShowCVVService.APIError>,
        confirmChangePINRemoteService: MappingRemoteService<SessionID, ChangePINService.EncryptedConfirmResponse, ChangePINService.ConfirmAPIError>,
        changePINRemoteService: MappingRemoteService<(SessionID, Data), Void, ChangePINService.ChangePINAPIError>
    ) {
        let getCodeRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeGetProcessingSessionCode,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapGetCodeResponse
        ).remoteService
        
        let formSessionKeyRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeSecretRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapFormSessionKeyResponse
        ).remoteService
        
        let bindPublicKeyWithEventIDRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeBindPublicKeyWithEventIDRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapBindPublicKeyWithEventIDResponse
        ).remoteService
        
        let showCVVRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeShowCVVRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapShowCVVResponse
        ).remoteService
        
        let confirmChangePINRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeGetPINConfirmationCodeRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapConfirmChangePINResponse
        ).remoteService
        
        let changePINRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.makeChangePINRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapChangePINResponse
        ).remoteService
        
        return (getCodeRemoteService, formSessionKeyRemoteService, bindPublicKeyWithEventIDRemoteService, showCVVRemoteService, confirmChangePINRemoteService, changePINRemoteService)
    }
}

struct SessionCode {
    
    let sessionCode: String
}

struct SessionKey {
    
    let sessionKey: Data
}

// MARK: - Error Mappers

private typealias MappingRemoteServiceError<MapResponseError: Error> = RemoteServiceError<Error, Error, MapResponseError>

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

// MARK: - Mappers

private extension CVVPINFunctionalityActivationService.GetCodeResponse {
    
    init(_ response: GetProcessingSessionCodeService.Response) {
        
        self.init(code: response.code, phone: response.phone)
    }
}

// MARK: - Adapters

extension RemoteService where Input == Void {
    
    func get(completion: @escaping ProcessCompletion) {
        
        process((), completion: completion)
    }
}

extension RemoteService where CreateRequestError == Error {
    
    convenience init(
        createRequest: @escaping (Input) throws -> URLRequest,
        performRequest: @escaping PerformRequest,
        mapResponse: @escaping MapResponse
    ) {
        self.init(
            createRequest: { input in .init { try createRequest(input) }},
            performRequest: performRequest,
            mapResponse: mapResponse
        )
    }
}
