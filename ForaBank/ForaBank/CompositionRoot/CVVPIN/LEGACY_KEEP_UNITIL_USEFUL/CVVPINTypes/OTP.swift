//
//  OTP.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

struct OTP {
    
    let value: String
}

extension OTP: RawRepresentable {
    
    var rawValue: String { value }
    
    init?(rawValue: String) {
        
        self.init(value: rawValue)
    }
}
