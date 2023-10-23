//
//  ComposedCVVPINService+PinConfirmationCodeClient.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

import CVVPIN_Services

extension ComposedCVVPINService: PinConfirmationCodeClient {
    
    func getPinConfirmCode(
        completion: @escaping GetPinConfirmCodeCompletion
    ) {
        getPINConfirmationCode { [weak self] result in
            
            guard self != nil else { return }
            
            completion(
                result
                    .map(\.phone)
                    .mapError(CVVPinError.PinConfirmationError.init)
            )
        }
    }
}

private extension CVVPinError.PinConfirmationError {
    
    init(_ error: ChangePINService.Error) {
        
        switch error {
            
        case .invalid:
            self = .network
            
        case .network:
            self = .network
            
        case .retry(statusCode: let statusCode, errorMessage: let errorMessage, retryAttempts: _):
            self = .init(errorMessage: errorMessage, statusCode: statusCode)
            
        case .server(statusCode: let statusCode, errorMessage: let errorMessage):
            self = .init(errorMessage: errorMessage, statusCode: statusCode)

        case .other:
            self = .network
        }
    }
    
    static let network: Self = .init(errorMessage: "Техническая ошибка", statusCode: -1)
}
