//
//  CVVPINComposer+authenticateWithPublicKey.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

public extension CVVPINComposer
where ECDHPublicKey: RawRepresentable<Data>,
      RSAPublicKey: RawRepresentable<Data>,
      SessionID == PublicKeyAuthenticationResponse.SessionID {
    
    typealias AuthWithPublicKey = (@escaping PublicKeyAuth.Completion) -> Void
    
    func authenticateWithPublicKey(
        currentDate: @escaping () -> Date = Date.init
    ) -> AuthWithPublicKey {
        
        let publicKeyAuth = composePublicKeyAuth(currentDate: currentDate)
        
        return publicKeyAuth.authenticateWithPublicKey(completion:)
    }
}
