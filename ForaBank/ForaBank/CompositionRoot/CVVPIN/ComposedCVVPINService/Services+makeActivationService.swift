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
    
    typealias BindPublicKeyService = Fetcher<BindPublicKeyWithEventIDService.Payload, BindPublicKeyWithEventIDService.Success, BindPublicKeyWithEventIDService.Failure>
    typealias OnBindKeyFailure = (BindPublicKeyWithEventIDService.Failure) -> Void
    
    static func makeBindPublicKeyService(
        sessionIDLoader: any Loader<SessionID>,
        bindPublicKeyWithEventIDRemoteService: BindPublicKeyWithEventIDRemoteService,
        makeSecretJSON: @escaping BindPublicKeyWithEventIDService.MakeSecretJSON,
        onBindKeyFailure: @escaping OnBindKeyFailure
   ) -> any BindPublicKeyService {
        
        let bindPublicKeyWithEventIDService = BindPublicKeyWithEventIDService(
            loadEventID: loadEventID(completion:),
            makeSecretJSON: makeSecretJSON,
            process: process(payload:completion:)
        )
        
        let rsaKeyPairCacheCleaningBindPublicKeyService = FetcherDecorator(
            decoratee: bindPublicKeyWithEventIDService,
            handleFailure: onBindKeyFailure
        )
        
        return rsaKeyPairCacheCleaningBindPublicKeyService
        
        // MARK: - BindPublicKeyWithEventID Adapters
        
        func loadEventID(
            completion: @escaping BindPublicKeyWithEventIDService.EventIDCompletion
        ) {
            sessionIDLoader.load {
                
                completion($0.map { .init(eventIDValue: $0.value) })
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

// MARK: - Mappers

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
