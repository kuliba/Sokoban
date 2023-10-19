//
//  SadCertificateClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

import PinCodeUI

final class SadCertificateClient: CertificateClient {
    
    func checkCertificate(
        completion: @escaping CheckCertificateCompletion
    ) {
        completion(.failure(CVVPinError.CheckError.certificate))
    }
    
    func activateCertificate(
        completion: @escaping ActivateCertificateCompletion
    ) {
        completion(.success("+7....77"))
    }
    
    func confirmWith(
        otp: String,
        completion: @escaping ConfirmationCompletion
    ) {
        completion(.success(()))
    }
    
    func showCVV(
        cardId: Int,
        completion: @escaping ShowCVVCompletion
    ) {
        completion(.success("111"))
    }
    
    func getPinConfirmCode(
        completion: @escaping GetPinConfirmCodeCompletion
    ) {
        completion(.success("+1..22"))
    }
    
    func changePin(
        cardId: Int,
        newPin: String,
        otp: String,
        completion: @escaping ChangePINCompletion
    ) {
        completion(.failure(.init(errorMessage: "error", retryAttempts: 1, statusCode: 7021)))
    }
}
