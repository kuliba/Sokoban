//
//  ComposedCVVPINService+ActivateCVVPINClient.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

import CVVPIN_Services

extension ComposedCVVPINService: ActivateCVVPINClient {
    
    func activate(
        completion: @escaping ActivateCompletion
    ) {
        initiateActivation { [weak self] result in
            
            guard self != nil else { return }
            
            completion(
                result
                    .map(\.phone.phoneValue)
                    .map { .init($0) }
                    .mapError(ActivateCVVPINError.init)
            )
        }
    }
    
    func confirmWith(
        otp: String,
        completion: @escaping ConfirmationCompletion
    ) {
        confirmActivation(
            .init(otpValue: otp)
        ) { [weak self] in
            
            guard self != nil else { return }
            
            completion($0.mapError(ConfirmationCodeError.init))
        }
    }
}

private extension ActivateCVVPINError {
    
    init(_ error: CVVPINInitiateActivationService.ActivateError) {
        
        switch error {
        case .invalid:
            self = .serviceFailure
            
        case .network:
            self = .serviceFailure
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case .serviceFailure:
            self = .serviceFailure
        }
    }
}

private extension ConfirmationCodeError {
    
    init(_ error: BindPublicKeyWithEventIDService.Error) {
        
        switch error {
            
        case .invalid, .network, .serviceError:
            self = .serviceFailure
            
        case let .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts):
            self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
            
        case let .server(statusCode: statusCode, errorMessage: errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}
