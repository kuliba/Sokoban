//
//  CvvPinService+CertificateClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import CvvPin
import Foundation

extension CvvPinService: CheckCertificateClient {
    
    typealias CheckCertificateResult = Result<Void, CVVPinError.PinError>
    typealias CheckCertificateCompletion = (CheckCertificateResult) -> Void
    
    func checkCertificate(
        completion: @escaping CheckCertificateCompletion
    ) {
        #warning("replace with crypto storage request")
        completion(.failure(.certificate))
    }
}
 
extension CvvPinService: ActivateCertificateClient {
    
    typealias ActivateCertificateResult = Result<Void, CVVPinError.ActivationError>
    typealias ActivateCertificateCompletion = (ActivateCertificateResult) -> Void
    
    func activateCertificate(
        completion: @escaping ActivateCertificateCompletion
    ) {
//        self.exchangeKey { <#Result<Void, Error>#> in
//            <#code#>
//        }
        let _: Void = unimplemented()
    }
}
