//
//  HappyCVVPINServicesClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

import PinCodeUI

final class HappyCVVPINServicesClient: CVVPINServicesClient {
    
    func checkFunctionality(
        completion: @escaping CheckFunctionalityCompletion
    ) {
        completion(.success(()))
    }
    
    func activate(
        completion: @escaping ActivateCompletion
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
    
    func getPINConfirmationCode(
        completion: @escaping GetPINConfirmationCodeCompletion
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
