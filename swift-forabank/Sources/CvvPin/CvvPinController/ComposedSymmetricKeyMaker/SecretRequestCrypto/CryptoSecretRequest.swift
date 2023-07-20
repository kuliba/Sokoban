//
//  CryptoSecretRequest.swift
//  
//
//  Created by Igor Malyarov on 18.07.2023.
//

import Foundation

public struct CryptoSecretRequest: Equatable {
    
    public let code: CryptoSessionCode
    public let data: Data
    
    public init(code: CryptoSessionCode, data: Data) {
        
        self.code = code
        self.data = data
    }
}
