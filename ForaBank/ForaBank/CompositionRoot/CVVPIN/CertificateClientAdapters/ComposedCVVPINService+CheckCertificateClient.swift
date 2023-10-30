//
//  ComposedCVVPINService+CheckCertificateClient.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

import CVVPIN_Services

extension ComposedCVVPINService: CheckCertificateClient {
    
    func checkCertificate(
        completion: @escaping CheckCertificateCompletion
    ) {
        checkActivation { [weak self] completion in
            
            self?.activateCertificate { [weak self] result in
                
                guard self != nil else { return }
                
                completion(result.map { _ in () }.mapError { $0 })
            }
        } _: { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError(CVVPinError.CheckError.init))
        }
    }
}

private extension CVVPinError.CheckError {
    
    init(_ error: CVVPINFunctionalityCheckingService.Error) {
        
        switch error {
        case .checkSessionFailure:
            self = .certificate
        }
    }
}
