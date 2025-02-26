//
//  AlertFailure.swift
//  
//
//  Created by Valentin Ozerov on 18.02.2025.
//

import Foundation

public struct AlertFailure: Identifiable, Equatable {
    
    public var id: String { message }

    public let message: String
    
    public init(
        message: String
    ) {
        self.message = message
    }
}
