//
//  SecretRequest.swift
//  
//
//  Created by Igor Malyarov on 18.07.2023.
//

import Foundation

public struct SecretRequest: Equatable {
    
    public let code: String
    public let data: String
    
    public init(code: String, data: String) {
        
        self.code = code
        self.data = data
    }
}
