//
//  AlertFailure.swift
//  
//
//  Created by Andryusina Nataly on 04.10.2024.
//

import Foundation

public struct AlertFailure: Identifiable, Equatable {
    
    public var id: String { message }

    let message: String
    
    public init(
        message: String
    ) {
        self.message = message
    }
}
