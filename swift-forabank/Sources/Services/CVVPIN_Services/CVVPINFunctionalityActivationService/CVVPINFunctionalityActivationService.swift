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
    
    public typealias FormSessionKeyResult = Swift.Result<SessionKey, Swift.Error>
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
    
    public struct SessionKey {
        
        let sessionKey: Data
        
        public init(sessionKey: Data) {
         
            self.sessionKey = sessionKey
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
        
        public let otp: String
        
        public init(otp: String) {
         
            self.otp = otp
        }
    }
    
    public struct Phone {
        
        public let phone: String
        
        public init(phone: String) {
         
            self.phone = phone
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
                    .map { _ in .init(phone: response.phone) }
                    .mapError { _ in .formSessionKeyFailure }
            )
        }
    }
}
