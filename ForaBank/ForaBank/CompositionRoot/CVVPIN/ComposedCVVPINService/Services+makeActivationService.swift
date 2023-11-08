//
//  Services+makeActivationService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation
import GenericRemoteService

extension Services {
    
    typealias CacheGetProcessingSessionCode = (GetProcessingSessionCodeService.Response) -> Void
    typealias CacheFormSessionKeySuccess = (FormSessionKeyService.Success) -> Void
    typealias CacheRSAKeyPair = (RSAKeyPair, @escaping (Swift.Result<Void, Error>) -> Void) -> Void
    typealias OnBindKeyFailure = (BindPublicKeyWithEventIDService.Failure) -> Void
    
    static func makeActivationService(
        getCodeRemoteService: GetCodeRemoteService,
        sessionCodeLoader: any Loader<SessionCode>,
        sessionIDLoader: any Loader<SessionID>,
        sessionKeyLoader: any Loader<SessionKey>,
        formSessionKeyRemoteService: FormSessionKeyRemoteService,
        bindPublicKeyWithEventIDRemoteService: BindPublicKeyWithEventIDRemoteService,
        cacheGetProcessingSessionCode: @escaping CacheGetProcessingSessionCode,
        cacheFormSessionKeySuccess: @escaping CacheFormSessionKeySuccess,
        cacheRSAKeyPair: @escaping CacheRSAKeyPair,
        onBindKeyFailure: @escaping OnBindKeyFailure,
        echdKeyPair: ECDHDomain.KeyPair,
        cvvPINCrypto: CVVPINCrypto,
        cvvPINJSONMaker: CVVPINJSONMaker
    ) -> CVVPINFunctionalityActivationService {
        
        let getCodeService = GetProcessingSessionCodeService(
            process: process(completion:)
        )
        
        let cachingGetCodeService = FetcherDecorator(
            decoratee: getCodeService,
            cache: cacheGetProcessingSessionCode
        )
        
        let formSessionKeyService = FormSessionKeyService(
            loadCode: loadCode(completion:),
            makeSecretRequestJSON: makeSecretRequestJSON(completion:),
            process: process(payload:completion:),
            makeSessionKey: makeSessionKey(string:completion:)
        )
        
        let cachingFormSessionKeyService = FetcherDecorator(
            decoratee: formSessionKeyService,
            cache: cacheFormSessionKeySuccess
        )
        
        let bindPublicKeyWithEventIDService = BindPublicKeyWithEventIDService(
            loadEventID: loadEventID(completion:),
            makeSecretJSON: makeSecretJSON(otp:completion:),
            process: process(payload:completion:)
        )
        
        let rsaKeyPairCacheCleaningBindPublicKeyService = FetcherDecorator(
            decoratee: bindPublicKeyWithEventIDService,
            handleFailure: onBindKeyFailure
        )
        
        let activationService = Services.makeActivationService(
            getCode: cachingGetCodeService.fetch,
            formSessionKey: cachingFormSessionKeyService.fetch,
            bindPublicKeyWithEventID: rsaKeyPairCacheCleaningBindPublicKeyService.fetch
        )
        
        return activationService
        
        // MARK: - GetProcessingSessionCode Adapters
        
        func process(
            completion: @escaping GetProcessingSessionCodeService.ProcessCompletion
        ) {
            getCodeRemoteService.process {
                
                completion($0.mapError { .init($0) })
            }
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
            payload: FormSessionKeyService.ProcessPayload,
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
                    
                    cacheRSAKeyPair(rsaKeyPair) {
                        
                        completion($0.map { _ in data })
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        func process(
            payload: BindPublicKeyWithEventIDService.ProcessPayload,
            completion: @escaping BindPublicKeyWithEventIDService.ProcessCompletion
        ){
            bindPublicKeyWithEventIDRemoteService.process(payload) {
                
                completion($0.mapError { .init($0) })
            }
        }
    }
}

// MARK: - Adapters

private extension RemoteService where Input == Void {
    
    func process(completion: @escaping ProcessCompletion) {
        
        process((), completion: completion)
    }
}

// MARK: - Mappers

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

extension Services {
    
    typealias GetCode = (@escaping GetProcessingSessionCodeService.Completion) -> Void
    typealias FormSessionKey = (@escaping FormSessionKeyService.Completion) -> Void
    typealias BindPublicKeyWithEventID = (BindPublicKeyWithEventIDService.OTP, @escaping BindPublicKeyWithEventIDService.Completion) -> Void
    
    static func makeActivationService(
        getCode: @escaping GetCode,
        formSessionKey: @escaping FormSessionKey,
        bindPublicKeyWithEventID: @escaping BindPublicKeyWithEventID
    ) -> CVVPINFunctionalityActivationService {
        
        let activationService = CVVPINFunctionalityActivationService(
            getCode: _getCode(completion:),
            formSessionKey: _formSessionKey(completion:),
            bindPublicKeyWithEventID: _bindPublicKeyWithEventID
        )
        
        return activationService
        
        // MARK: - CVVPINFunctionalityActivation Adapters
        
        func _getCode(
            completion: @escaping CVVPINFunctionalityActivationService.GetCodeCompletion
        ) {
            getCode { result in
                
                completion(
                    result
                        .map(CVVPINFunctionalityActivationService.GetCodeResponse.init)
                        .mapError(CVVPINFunctionalityActivationService.GetCodeResponseError.init)
                )
            }
        }
        
        func _formSessionKey(
            completion: @escaping CVVPINFunctionalityActivationService.FormSessionKeyCompletion
        ) {
            formSessionKey { result in
                
                completion(
                    result
                        .map(CVVPINFunctionalityActivationService.FormSessionKeySuccess.init)
                        .mapError(CVVPINFunctionalityActivationService.FormSessionKeyError.init)
                )
            }
        }
        
        func _bindPublicKeyWithEventID(
            otp: CVVPINFunctionalityActivationService.OTP,
            completion: @escaping CVVPINFunctionalityActivationService.BindPublicKeyWithEventIDCompletion
        ) {
            bindPublicKeyWithEventID(
                .init(otpValue: otp.otpValue)
            ) {
                completion($0.mapError(CVVPINFunctionalityActivationService.BindPublicKeyError.init))
            }
        }
    }
}

// MARK: - Mappers

private extension CVVPINFunctionalityActivationService.GetCodeResponse {
    
    init(_ response: GetProcessingSessionCodeService.Response) {
        
        self.init(code: response.code, phone: response.phone)
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

private extension CVVPINFunctionalityActivationService.FormSessionKeySuccess {
    
    init(_ success: FormSessionKeyService.Success) {
        
        self.init(
            sessionKey: .init(sessionKeyValue: success.sessionKey.sessionKeyValue),
            eventID: .init(eventIDValue: success.eventID.eventIDValue),
            sessionTTL: success.sessionTTL
        )
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
