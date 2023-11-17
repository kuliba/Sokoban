//
//  AnyError.swift
//  
//
//  Created by Igor Malyarov on 04.11.2023.
//

struct AnyError: Error {
    
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

func anyError(_ message: String = "any error") -> Error {
    
    AnyError(message)
}
