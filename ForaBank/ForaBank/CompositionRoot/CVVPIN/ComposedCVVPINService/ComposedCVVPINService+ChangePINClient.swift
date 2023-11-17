//
//  ComposedCVVPINService+ChangePINClient.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

import CVVPIN_Services

extension ComposedCVVPINService: ChangePINClient {
    
    func checkFunctionality(
        completion: @escaping CheckFunctionalityCompletion
    ) {
        checkActivation { [weak self] in
            
            guard self != nil else { return }
            
            completion($0.mapError { _ in .activationFailure })
        }
    }
    
    func getPINConfirmationCode(
        completion: @escaping GetPINConfirmationCodeCompletion
    ) {
        getPINConfirmationCode { [weak self] in
            
            guard self != nil else { return }
            
            completion(
                $0.map(\.phone).mapError(GetPINConfirmationCodeError.init)
            )
        }
    }
    
    func changePin(
        cardId: Int,
        newPin: String,
        otp: String,
        completion: @escaping ChangePINCompletion
    ) {
        changePIN(
            .init(cardIDValue: cardId),
            .init(pinValue: newPin),
            .init(otpValue: otp)
        ) { [weak self] in
            
            guard self != nil else { return }
            
            completion($0.mapError(ChangePINError.init))
        }
    }
}

private extension GetPINConfirmationCodeError {
    
    init(_ error: ChangePINService.GetPINConfirmationCodeError) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
            
        case .authenticationFailure, .decryptionFailure, .invalid, .network:
            self = .serviceFailure
            
        case let .server(statusCode: statusCode, errorMessage: errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

private extension ChangePINError {
    
    init(_ error: ChangePINService.ChangePINError) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
            
        case .authenticationFailure, .invalid, .makeJSONFailure, .network:
            self = .serviceFailure
            
        case let .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts):
            self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
            
        case let .server(statusCode: statusCode, errorMessage: errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case let .weakPIN(statusCode: statusCode, errorMessage: errorMessage):
            self = .weakPIN(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}
