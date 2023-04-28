//
//  MCError.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.02.2023.
//

import Foundation

struct MCError: Error, Equatable {
    
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}
