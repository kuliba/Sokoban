//
//  CVVPINComposer+changePIN.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

public extension CVVPINComposer
where CardID: RawRepresentable<Int>,
      EventID: RawRepresentable<String>,
      OTP: RawRepresentable<String>,
      PIN: RawRepresentable<String>,
      SessionID == PublicKeyAuthenticationResponse.SessionID {
    
    typealias ChangePin = (CardID, OTP, PIN, @escaping PINChanger.Completion) -> Void
    
    func changePIN() -> ChangePin {
        
        let pinChanger = composePINChanger()
        
        return pinChanger.changePIN(cardID:otp:pin:completion:)
    }
}
