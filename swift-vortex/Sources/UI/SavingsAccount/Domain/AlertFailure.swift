//
//  AlertFailure.swift
//  
//
//  Created by Andryusina Nataly on 04.12.2024.
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
