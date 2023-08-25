//
//  Helpers.swift
//  
//
//  Created by Igor Malyarov on 11.08.2023.
//

import CryptoKit
import CvvPin
import Foundation

func uniqueKeyExchange() -> KeyExchangeDomain.KeyExchange {
    
    .init(
        sharedSecret: uniqueData(),
        eventID: uniqueEventID(),
        sessionTTL: 300.0
    )
}

func uniqueSymmetricKey() -> SymmetricKey {
    
    .init(size: .bits256)
}

func uniqueData() -> Data {
    
    SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
}

func uniqueEventID() -> KeyExchangeDomain.KeyExchange.EventID {
    
    .init(value: UUID().uuidString)
}
