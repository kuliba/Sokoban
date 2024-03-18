//
//  CVVPINServicesClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

import PinCodeUI
import CardUI

typealias CVVPINServicesClient = ActivateCVVPINClient & ShowCVVClient & ChangePINClient

// MARK: - CVV-PIN Functionality Activation

protocol ActivateCVVPINClient {
    
    // MARK: Activate

    typealias Phone = PinCodeUI.PhoneDomain.Phone
    typealias ActivateResult = Result<Phone, ActivateCVVPINError>
    typealias ActivateCompletion = (ActivateResult) -> Void
    
    func activate(completion: @escaping ActivateCompletion)
    
    // MARK: Request OTP

    typealias ConfirmationResult = Result<Void, ConfirmationCodeError>
    typealias ConfirmationCompletion = (ConfirmationResult) -> Void

    func confirmWith(otp: String, completion: @escaping ConfirmationCompletion)
}

enum ActivateCVVPINError: Error {
    
    case server(statusCode: Int, errorMessage: String)
    case serviceFailure
}

enum ConfirmationCodeError: Error {
    
    case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
    case server(statusCode: Int, errorMessage: String)
    case serviceFailure
}

// MARK: - ShowCVV

protocol ShowCVVClient {
    
    typealias CVV = CardInfo.CVV
    typealias ShowCVVResult = Result<CVV, ShowCVVError>
    typealias ShowCVVCompletion = (ShowCVVResult) -> Void
    
    func showCVV(cardId: Int, completion: @escaping ShowCVVCompletion)
}

enum ShowCVVError: Error {
    
    case activationFailure
    case server(statusCode: Int, errorMessage: String)
    case serviceFailure
}

// MARK: - ChangePINClient

protocol ChangePINClient {
    
    // MARK: Check Functionality
    
    typealias CheckFunctionalityResult = Result<Void, CheckCVVPINFunctionalityError>
    typealias CheckFunctionalityCompletion = (CheckFunctionalityResult) -> Void
    
    func checkFunctionality(completion: @escaping CheckFunctionalityCompletion)
        
    // MARK: Request OTP
    
    typealias GetPINConfirmationCodeResult = Result<String, GetPINConfirmationCodeError>
    typealias GetPINConfirmationCodeCompletion = (GetPINConfirmationCodeResult) -> Void
    
    func getPINConfirmationCode(completion: @escaping GetPINConfirmationCodeCompletion)
    
    // MARK: Change PIN

    typealias ChangePINResult = Result<Void, ChangePINError>
    typealias ChangePINCompletion = (ChangePINResult) -> Void
    
    func changePin(
        cardId: Int,
        newPin: String,
        otp: String,
        completion: @escaping ChangePINCompletion
    )
}

enum CheckCVVPINFunctionalityError: Error {
    
    case activationFailure
    case server(statusCode: Int, errorMessage: String)
    case serviceFailure
}

enum GetPINConfirmationCodeError: Error {
    
    case activationFailure
    case server(statusCode: Int, errorMessage: String)
    case serviceFailure
}

enum ChangePINError: Error {
    
    case activationFailure
    case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
    case server(statusCode: Int, errorMessage: String)
    case serviceFailure
    case weakPIN(statusCode: Int, errorMessage: String)
}
