//
//  EventID.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

struct EventID {
    
    let value: String
}

extension EventID: RawRepresentable {
    
    var rawValue: String { value }
    
    init?(rawValue: String) {
        
        self.init(value: rawValue)
    }
}
