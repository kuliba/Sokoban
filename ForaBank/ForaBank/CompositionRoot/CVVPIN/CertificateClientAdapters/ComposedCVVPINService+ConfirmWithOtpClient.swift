//
//  ComposedCVVPINService+ConfirmWithOtpClient.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

import CVVPIN_Services

extension ComposedCVVPINService: ConfirmWithOtpClient {
    
    func confirmWith(
        otp: String,
        completion: @escaping ConfirmWithOtpClient.ConfirmationCompletion
    ) {
        confirmActivation(
            withOTP: .init(otp: otp)
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError(CVVPinError.OtpError.init))
        }
    }
}

private extension CVVPinError.OtpError {
    
    init(_ error: CVVPINFunctionalityActivationService.Error) {
        
        switch error {
        case .bindKeyFailure:
            self = .network
            
        case .formSessionKeyFailure:
            self = .network
            
        case .getCodeFailure:
            self = .network
        }
    }
    
    static let network: Self = .init(errorMessage: "Техническая ошибка", retryAttempts: 0)
}
