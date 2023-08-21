//
//  GetProcessingSessionCode.swift
//  
//
//  Created by Igor Malyarov on 31.07.2023.
//

public struct GetProcessingSessionCode: Equatable {
    
    public let code: String
    public let phone: String
    
    public init(code: String, phone: String) {
        self.code = code
        self.phone = phone
    }
}
