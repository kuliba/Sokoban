//
//  GetConsentsFailureResult.swift
//
//
//  Created by Valentin Ozerov on 21.02.2025.
//

public struct GetConsentsFailureResult: Equatable, Error {
    
    public let message: String
    
    public init(message: String) {

        self.message = message
    }
}
