//
//  PIN.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

struct PIN {
    
    let value: String
}

extension PIN: RawRepresentable {
    
    var rawValue: String { value }
    
    init?(rawValue: String) {
        
        self.init(value: rawValue)
    }
}
