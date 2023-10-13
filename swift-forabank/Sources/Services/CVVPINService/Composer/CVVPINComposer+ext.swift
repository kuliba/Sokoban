//
//  CVVPINComposer+ext.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

public extension CVVPINComposer
where CardID: RawRepresentable<Int>,
      CVV: RawRepresentable<String>,
      ECDHPublicKey: RawRepresentable<Data>,
      EventID: RawRepresentable<String>,
      OTP: RawRepresentable<String>,
      PIN: RawRepresentable<String>,
      RemoteCVV: RawRepresentable<String>,
      RSAPublicKey: RawRepresentable<Data>,
      SessionID == PublicKeyAuthenticationResponse.SessionID {
    
    // MARK: - ChangePin
    
    typealias ChangePin = (CardID, OTP, PIN, @escaping PINChanger.Completion) -> Void
    
    func changePIN() -> ChangePin {
        
        let pinChanger = composePINChanger()
        
        return pinChanger.changePIN(cardID:otp:pin:completion:)
    }
    
    // MARK: - AuthWithPublicKey
    
    typealias AuthWithPublicKey = (@escaping PublicKeyAuth.Completion) -> Void
    
    func authenticateWithPublicKey(
        currentDate: @escaping () -> Date = Date.init
    ) -> AuthWithPublicKey {
        
        let publicKeyAuth = composePublicKeyAuth(currentDate: currentDate)
        
        return publicKeyAuth.authenticateWithPublicKey(completion:)
    }
    
    // MARK: - ShowCVV
    
    typealias ShowCVV = (CardID, @escaping CVVService.CVVCompletion) -> Void
    
    func showCVV() -> ShowCVV {
        
        let showCVVService = composeShowCVV()
        
        return showCVVService.showCVV(forCardWithID:completion:)
    }
}

extension PublicKeyAuthenticationResponse.SessionID: RawRepresentable {
    
    public var rawValue: String { value }
    
    public init(rawValue: String) {
        
        self.init(value: rawValue)
    }
}
