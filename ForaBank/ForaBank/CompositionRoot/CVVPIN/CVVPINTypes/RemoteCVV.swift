//
//  RemoteCVV.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

struct RemoteCVV {
    
    let value: String
}

extension RemoteCVV: RawRepresentable {
    
    var rawValue: String { value }
    
    init?(rawValue: String) {
        
        self.init(value: rawValue)
    }
}
