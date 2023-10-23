//
//  CardID.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

struct CardID {
    
    let value: Int
}

extension CardID: RawRepresentable {
    
    var rawValue: Int { value }
    
    init?(rawValue: Int) {
        
        self.init(value: rawValue)
    }
}
