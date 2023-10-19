//
//  HappyCertificateClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

import PinCodeUI

final class HappyCertificateClient: CertificateClient {
    
    func checkCertificate(
        completion: @escaping CheckCertificateCompletion
    ) {
        completion(.success(()))
    }
    
    func activateCertificate(
        completion: @escaping ActivateCertificateCompletion
    ) {
        completion(.success("+7...88"))
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
        completion(.success("123"))
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
        completion(.success(()))
    }
}
