//
//  CVVPINComposer+showCVV.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

public extension CVVPINComposer
where CardID: RawRepresentable<Int>,
      CVV: RawRepresentable<String>,
      RemoteCVV: RawRepresentable<String>,
      SessionID == PublicKeyAuthenticationResponse.SessionID {
    
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
