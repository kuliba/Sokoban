//
//  ComposedCVVPINService+ChangePinClient.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

import CVVPIN_Services

extension ComposedCVVPINService: ChangePinClient {
    
    func changePin(
        cardId: Int,
        newPin: String,
        otp: String,
        completion: @escaping ChangePinClient.ChangePINCompletion
    ) {
        changePIN(
            for: .init(cardID: cardId),
            to: .init(pin: newPin),
            otp: .init(otp: otp)
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError(CVVPinError.ChangePinError.init))
        }
    }
}

private extension CVVPinError.ChangePinError {
    
    init(_ error: ChangePINService.Error) {
        
        switch error {
        case .invalid:
            self = .network
            
        case .network:
            self = .network
            
        case let .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts):
            self = .init(errorMessage: errorMessage, retryAttempts: retryAttempts, statusCode: statusCode)
            
        case let .server(statusCode: statusCode, errorMessage: errorMessage):
            self = .init(errorMessage: errorMessage, retryAttempts: 0, statusCode: statusCode)
            
        case .other(_):
            self = .network
        }
    }
    
    static let network: Self = .init(errorMessage: "Техническая ошибка.", retryAttempts: 0, statusCode: -1)
}
