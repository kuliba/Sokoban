//
//  PublicKeyWithEventID.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.08.2023.
//

struct PublicKeyWithEventID: Equatable {
    
    let keyString: String
    let eventID: EventID
    
    struct EventID: Equatable {
        
        let value: String
        
        var isEmpty: Bool { value.isEmpty }
    }
}
