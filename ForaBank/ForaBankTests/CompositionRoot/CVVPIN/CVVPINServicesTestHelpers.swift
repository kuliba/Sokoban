//
//  CVVPINServicesTestHelpers.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.11.2023.
//

import CVVPIN_Services
import Foundation

func anyCardID(
    cardIDValue: Int = 98765431012
) -> ChangePINService.CardID {
    
    .init(cardIDValue: cardIDValue)
}

func anyCardID(
    cardIDValue: Int = 98765431012
) -> ShowCVVService.CardID {
    
    .init(cardIDValue: cardIDValue)
}

func anyOTP(
    otpValue: String = .init(UUID().uuidString.prefix(6))
) -> ChangePINService.OTP {
    
    .init(otpValue: otpValue)
}

func anyOTP(
    otpValue: String = .init(UUID().uuidString.prefix(6))
) -> CVVPINFunctionalityActivationService.OTP {
    
    .init(otpValue: otpValue)
}

func anyPIN(
    pinValue: String = .init(UUID().uuidString.prefix(4))
) -> ChangePINService.PIN {
    
    .init(pinValue: pinValue)
}

func anyOTPEventID(
    eventIDValue: String = UUID().uuidString
) -> ChangePINService.OTPEventID {
    
    .init(eventIDValue: eventIDValue)
}

func anySessionID(
    sessionIDValue: String = UUID().uuidString
) -> ChangePINService.SessionID {
    
    .init(sessionIDValue: sessionIDValue)
}

func anySessionID(
    sessionIDValue: String = UUID().uuidString
) -> ShowCVVService.SessionID {
    
    .init(sessionIDValue: sessionIDValue)
}

typealias CVVPINActivateResult = CVVPINInitiateActivationService.ActivateResult

func anySuccess(
    codeValue: String = UUID().uuidString,
    phoneValue: String = UUID().uuidString,
    sessionKeyValue: Data = anyData(),
    eventIDValue: String = UUID().uuidString,
    sessionTTL: Int = 23
) -> CVVPINActivateResult {
    
    .success(.init(
        code: .init(codeValue: codeValue),
        phone: .init(phoneValue: phoneValue),
        sessionKey: .init(sessionKeyValue: sessionKeyValue),
        eventID: .init(eventIDValue: eventIDValue),
        sessionTTL: sessionTTL
    ))
}

func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> CVVPINActivateResult {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
}

typealias ChangePINResult = ChangePINService.ChangePINResult

func anySuccess() -> ChangePINResult {
    
    .success(())
}

func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> ChangePINResult {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
}

typealias CVVPINConfirmResult = CVVPINFunctionalityActivationService.ConfirmResult

func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> CVVPINConfirmResult {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
}

typealias GetPINConfirmationCodeResult = ChangePINService.GetPINConfirmationCodeResult

func anySuccess(
    _ eventIDValue: String = UUID().uuidString,
    _ phoneValue: String = UUID().uuidString
) -> GetPINConfirmationCodeResult {
    
    .success(.init(
        otpEventID: .init(eventIDValue: eventIDValue),
        phone: phoneValue
    ))
}

func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> GetPINConfirmationCodeResult {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
}

func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> BindPublicKeyWithEventIDService.Result {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
}

func anySuccess(
    _ cvvValue: String = .init(UUID().uuidString.prefix(3))
) -> ShowCVVService.Result {
    
    .success(.init(cvvValue: cvvValue))
}

func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> ShowCVVService.Result {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
}
