//
//  Services+makeActivationService.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation
import GenericRemoteService

extension Services {
    
    typealias GetCode = (@escaping GetProcessingSessionCodeService.Completion) -> Void
    typealias FormSessionKey = (FormSessionKeyService.Code, @escaping FormSessionKeyService.Completion) -> Void
    typealias BindPublicKeyWithEventID = (BindPublicKeyWithEventIDService.OTP, @escaping BindPublicKeyWithEventIDService.Completion) -> Void
    
    static func makeActivationService(
        getCode: @escaping GetCode,
        formSessionKey: @escaping FormSessionKey,
        bindPublicKeyWithEventID: @escaping BindPublicKeyWithEventID
    ) -> CVVPINFunctionalityActivationService {
        
        let activationService = CVVPINFunctionalityActivationService(
            getCode: _getCode(completion:),
            formSessionKey: _formSessionKey(_:completion:),
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
                        .map(CVVPINFunctionalityActivationService.GetCodeSuccess.init)
                        .mapError(CVVPINFunctionalityActivationService.GetCodeResponseError.init)
                )
            }
        }
        
        func _formSessionKey(
            _ code: CVVPINFunctionalityActivationService.Code,
            completion: @escaping CVVPINFunctionalityActivationService.FormSessionKeyCompletion
        ) {
            formSessionKey(.init(codeValue: code.codeValue)) { result in
                
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

private extension CVVPINFunctionalityActivationService.GetCodeSuccess {
    
    init(_ response: GetProcessingSessionCodeService.Response) {
        
        self.init(
            code: .init(codeValue: response.code),
            phone: .init(phoneValue: response.phone)
        )
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
