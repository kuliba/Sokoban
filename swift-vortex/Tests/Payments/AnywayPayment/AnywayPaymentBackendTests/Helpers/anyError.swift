//
//  anyError.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation

func anyError(_ message: String = "any error") -> Error {
    
    AnyError(message: message)
}

struct AnyError: Error, Equatable {
    
    let message: String
}
