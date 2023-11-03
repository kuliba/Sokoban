//
//  CVVPINServicesTestHelpers.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.11.2023.
//

import CVVPIN_Services
import Foundation

func anySessionID(
    sessionIDValue: String = UUID().uuidString
) -> ChangePINService.SessionID {
    
    .init(sessionIDValue: sessionIDValue)
}

func anyCardID(
    cardIDValue: Int = 98765431012
) -> ChangePINService.CardID {
    
    .init(cardIDValue: cardIDValue)
}

func anyOTP(
    otpValue: String = .init(UUID().uuidString.prefix(6))
) -> ChangePINService.OTP {
    
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
) -> ShowCVVService.SessionID {
    
    .init(sessionIDValue: sessionIDValue)
}

func anyCardID(
    cardIDValue: Int = 98765431012
) -> ShowCVVService.CardID {
    
    .init(cardIDValue: cardIDValue)
}
