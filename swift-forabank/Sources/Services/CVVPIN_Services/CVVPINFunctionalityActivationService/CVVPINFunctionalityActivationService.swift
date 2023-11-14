//
//  CVVPINFunctionalityActivationService.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

import Foundation

/// - Note: `SessionKey` is `SymmetricKey` is `SharedSecret`
///
public final class CVVPINFunctionalityActivationService {
    
    public typealias GetCodeResult = Result<GetCodeSuccess, GetCodeResponseError>
    public typealias GetCodeCompletion = (GetCodeResult) -> Void
    public typealias GetCode = (@escaping GetCodeCompletion) -> Void
    
    public typealias FormSessionKeyResult = Result<FormSessionKeySuccess, FormSessionKeyError>
    public typealias FormSessionKeyCompletion = (FormSessionKeyResult) -> Void
    public typealias FormSessionKey = (Code, @escaping FormSessionKeyCompletion) -> Void
    
    public typealias BindPublicKeyWithEventIDResult = Result<Void, BindPublicKeyError>
    public typealias BindPublicKeyWithEventIDCompletion = (BindPublicKeyWithEventIDResult) -> Void
    public typealias BindPublicKeyWithEventID = (OTP, @escaping BindPublicKeyWithEventIDCompletion) -> Void
    
    private let getCode: GetCode
    private let formSessionKey: FormSessionKey
    private let bindPublicKeyWithEventID: BindPublicKeyWithEventID
    
    public init(
        getCode: @escaping GetCode,
        formSessionKey: @escaping FormSessionKey,
        bindPublicKeyWithEventID: @escaping BindPublicKeyWithEventID
    ) {
        self.getCode = getCode
        self.formSessionKey = formSessionKey
        self.bindPublicKeyWithEventID = bindPublicKeyWithEventID
    }
}

// MARK: - Activate

public extension CVVPINFunctionalityActivationService {
    
    typealias ActivateResult = Result<ActivateSuccess, ActivateError>
    typealias ActivateCompletion = (ActivateResult) -> Void
    
    func activate(
        completion: @escaping ActivateCompletion
    ) {
        getCode { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(.init(error)))
                
            case let .success(success):
                _formSessionKey(success, completion)
            }
        }
    }
    
    enum ActivateError: Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
    }
}

// MARK: - Confirm

public extension CVVPINFunctionalityActivationService {
    
    typealias ConfirmResult = Result<Void, ConfirmError>
    typealias ConfirmCompletion = (ConfirmResult) -> Void
    
    func confirmActivation(
        withOTP otp: OTP,
        completion: @escaping ConfirmCompletion
    ) {
        bindPublicKeyWithEventID(otp) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError(ConfirmError.init))
        }
    }
    
    enum ConfirmError: Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
    }
}

// MARK: - Errors

public extension CVVPINFunctionalityActivationService {
    
    enum GetCodeResponseError: Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
    }
    
    enum FormSessionKeyError: Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
    }
    
    enum BindPublicKeyError: Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
    }
}

// MARK: - Types

extension CVVPINFunctionalityActivationService {
    
    public struct ActivateSuccess {
        
        // GetCodeSuccess
        public let code: Code
        public let phone: Phone
        // FormSessionKeySuccess
        public let sessionKey: FormSessionKeySuccess.SessionKey
        public let eventID: FormSessionKeySuccess.EventID
        public let sessionTTL: FormSessionKeySuccess.SessionTTL
        
        public init(
            code: Code,
            phone: Phone,
            sessionKey: FormSessionKeySuccess.SessionKey,
            eventID: FormSessionKeySuccess.EventID,
            sessionTTL: FormSessionKeySuccess.SessionTTL
        ) {
            self.code = code
            self.phone = phone
            self.sessionKey = sessionKey
            self.eventID = eventID
            self.sessionTTL = sessionTTL
        }
        
        internal init(
            getCodeSuccess: GetCodeSuccess,
            formSessionKeySuccess: FormSessionKeySuccess
        ) {
            self.code = getCodeSuccess.code
            self.phone = getCodeSuccess.phone
            self.sessionKey = formSessionKeySuccess.sessionKey
            self.eventID = formSessionKeySuccess.eventID
            self.sessionTTL = formSessionKeySuccess.sessionTTL
        }
    }
    
    public struct FormSessionKeySuccess {
        
        public let sessionKey: SessionKey
        public let eventID: EventID
        public let sessionTTL: SessionTTL
        
        public init(
            sessionKey: SessionKey,
            eventID: EventID,
            sessionTTL: SessionTTL
        ) {
            self.sessionKey = sessionKey
            self.eventID = eventID
            self.sessionTTL = sessionTTL
        }
        
        public typealias SessionTTL = Int
        
        public struct EventID {
            
            public let eventIDValue: String
            
            public init(eventIDValue: String) {
                
                self.eventIDValue = eventIDValue
            }
        }
        
        public struct SessionKey {
            
            public let sessionKeyValue: Data
            
            public init(sessionKeyValue: Data) {
                
                self.sessionKeyValue = sessionKeyValue
            }
        }
    }
    
    public struct GetCodeSuccess {
        
        let code: Code
        let phone: Phone
        
        public init(
            code: Code,
            phone: Phone
        ) {
            self.code = code
            self.phone = phone
        }
    }
    
    public struct Code {
        
        public let codeValue: String
        
        public init(codeValue: String) {
            
            self.codeValue = codeValue
        }
    }
    
    public struct Phone {
        
        public let phoneValue: String
        
        public init(phoneValue: String) {
            
            self.phoneValue = phoneValue
        }
    }
    
    public struct OTP {
        
        public let otpValue: String
        
        public init(otpValue: String) {
            
            self.otpValue = otpValue
        }
    }
}

private extension CVVPINFunctionalityActivationService {
    
    func _formSessionKey(
        _ getCodeSuccess: GetCodeSuccess,
        _ completion: @escaping ActivateCompletion
    ) {
        formSessionKey(getCodeSuccess.code) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(
                result
                    .map { formSessionKeySuccess in
                     
                            .init(
                                getCodeSuccess: getCodeSuccess,
                                formSessionKeySuccess: formSessionKeySuccess
                            )
                    }
                    .mapError(ActivateError.init)
            )
        }
    }
}

// MARK: - Error Mapping

private extension CVVPINFunctionalityActivationService.ActivateError {
    
    init(_ error: CVVPINFunctionalityActivationService.GetCodeResponseError) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
    
    init(_ error: CVVPINFunctionalityActivationService.FormSessionKeyError) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case .serviceFailure:
            self = .serviceFailure
        }
    }
}

private extension CVVPINFunctionalityActivationService.ConfirmError {
    
    init(_ error: CVVPINFunctionalityActivationService.BindPublicKeyError) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .retry(statusCode, errorMessage, retryAttempts):
            self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case .serviceFailure:
            self = .serviceFailure
        }
    }
}
