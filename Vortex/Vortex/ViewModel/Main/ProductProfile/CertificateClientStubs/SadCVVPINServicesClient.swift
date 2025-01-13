//
//  SadCVVPINServicesClient.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.10.2023.
//

import PinCodeUI

final class SadCVVPINServicesClient: CVVPINServicesClient {
    
    func checkFunctionality(
        completion: @escaping CheckFunctionalityCompletion
    ) {
        completion(.failure(.activationFailure))
    }
    
    func activate(
        completion: @escaping ActivateCompletion
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
        completion(.failure(.retry(statusCode: 7021, errorMessage: "error", retryAttempts: 1)))
    }
}
