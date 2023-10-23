//
//  ComposedCVVPINService+ActivateCertificateClient.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

import CVVPIN_Services

extension ComposedCVVPINService: ActivateCertificateClient {
    
    func activateCertificate(
        completion: @escaping ActivateCertificateCompletion
    ) {
        activate { [weak self] result in
            
            guard self != nil else { return }
            
            completion(
                result
                    .map(\.phoneValue)
                    .map { .init($0) }
                    .mapError(CVVPinError.ActivationError.init)
            )
        }
    }
}

private extension CVVPinError.ActivationError {
    
    init(_ error: CVVPINFunctionalityActivationService.Error) {
        
        switch error {
        case .bindKeyFailure, .formSessionKeyFailure, .getCodeFailure:
            self = .network
        }
    }
    
    static let network: Self = .init(message: "Техническая ошибка.")
}
