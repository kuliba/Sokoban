//
//  CVVPINComposer+authenticateWithPublicKey.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

public extension CVVPINComposer
where ECDHPublicKey: Base64StringEncodable,
      RSAPublicKey: Base64StringEncodable,
      SessionID == PublicKeyAuthenticationResponse.SessionID {
    
    typealias AuthWithPublicKey = (@escaping PublicKeyAuth.Completion) -> Void
    
    func authenticateWithPublicKey(
        currentDate: @escaping () -> Date = Date.init
    ) -> AuthWithPublicKey {
        
        let publicKeyAuth = composePublicKeyAuth(currentDate: currentDate)
        
        return publicKeyAuth.authenticateWithPublicKey(completion:)
    }
}
