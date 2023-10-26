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
    
    public typealias GetCodeResult = Swift.Result<GetCodeResponse, Swift.Error>
    public typealias GetCodeCompletion = (GetCodeResult) -> Void
    public typealias GetCode = (@escaping GetCodeCompletion) -> Void
    
    public typealias FormSessionKeyResult = Swift.Result<FormSessionKeySuccess, Swift.Error>
    public typealias FormSessionKeyCompletion = (FormSessionKeyResult) -> Void
    public typealias FormSessionKey = (@escaping FormSessionKeyCompletion) -> Void
    
    public typealias BindPublicKeyWithEventIDResult = Swift.Result<Void, Swift.Error>
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

public extension CVVPINFunctionalityActivationService {
    
    typealias ActivationResult = Swift.Result<Phone, Error>
    typealias ActivationCompletion = (ActivationResult) -> Void
    
    func activate(
        completion: @escaping ActivationCompletion
    ) {
        getCode { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.getCodeFailure))
                
            case let .success(response):
                formSessionKey(response, completion)
            }
        }
    }
    
    typealias ConfirmationResult = Swift.Result<Void, Error>
    typealias ConfirmationCompletion = (ConfirmationResult) -> Void
    
    func confirmActivation(
        withOTP otp: OTP,
        completion: @escaping ConfirmationCompletion
    ) {
        bindPublicKeyWithEventID(otp) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError { _ in .bindKeyFailure })
        }
    }
    
    enum Error: Swift.Error {
        
        case bindKeyFailure
        case formSessionKeyFailure
        case getCodeFailure
    }
}

extension CVVPINFunctionalityActivationService {
    
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
            
            let sessionKeyValue: Data
            
            public init(sessionKeyValue: Data) {
                
                self.sessionKeyValue = sessionKeyValue
            }
        }
    }

    public struct GetCodeResponse {
        
        let code: String
        let phone: String
        
        public init(
            code: String,
            phone: String
        ) {
            self.code = code
            self.phone = phone
        }
    }
    
    public struct OTP {
        
        public let otpValue: String
        
        public init(otpValue: String) {
         
            self.otpValue = otpValue
        }
    }
    
    public struct Phone {
        
        public let phoneValue: String
        
        public init(phoneValue: String) {
         
            self.phoneValue = phoneValue
        }
    }
}

private extension CVVPINFunctionalityActivationService {
    
    func formSessionKey(
        _ response: GetCodeResponse,
        _ completion: @escaping ActivationCompletion
    ) {
        formSessionKey { [weak self] result in
            
            guard self != nil else { return }
            
            completion(
                result
                    .map { _ in .init(phoneValue: response.phone) }
                    .mapError { _ in .formSessionKeyFailure }
            )
        }
    }
}
