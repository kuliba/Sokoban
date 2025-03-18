//
//  LoadFailure.swift
//
//
//  Created by Дмитрий Савушкин on 12.03.2025.
//

import Foundation

public struct LoadFailure: Error, Equatable {
    
    public let message: String
    public let type: FailureType
    
    public init(
        message: String,
        type: FailureType
    ) {
        self.message = message
        self.type = type
    }
    
    public enum FailureType {
        
        case alert, informer
    }
}
