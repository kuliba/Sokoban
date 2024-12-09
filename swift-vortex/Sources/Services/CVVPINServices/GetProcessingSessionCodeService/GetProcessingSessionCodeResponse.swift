//
//  GetProcessingSessionCodeResponse.swift
//  
//
//  Created by Igor Malyarov on 19.10.2023.
//

import Foundation

public struct GetProcessingSessionCodeResponse: Equatable {
    
    public let code: Code
    public let phone: Phone
    
    public init(
        code: Code,
        phone: Phone
    ) {
        self.code = code
        self.phone = phone
    }
    
    public struct Code: Equatable {
        
        public let code: String
        
        public init(code: String) {
            
            self.code = code
        }
    }
    
    public struct Phone: Equatable {
        
        public let phone: String
        
        public init(phone: String) {
            
            self.phone = phone
        }
    }
}
