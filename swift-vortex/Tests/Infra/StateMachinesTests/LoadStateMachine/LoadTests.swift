//
//  LoadTests.swift
//  
//
//  Created by Igor Malyarov on 19.02.2025.
//

import XCTest

class LoadTests: XCTestCase {
    
    typealias State = LoadState<Success, Failure>
    typealias Event = LoadEvent<Success, Failure>
    typealias Effect = LoadEffect
    
    struct Success: Equatable {
        
        let value: String
    }
    
    func makeSuccess(
        _ value: String = anyMessage()
    ) -> Success {
        
        return .init(value: value)
    }
    
    struct Failure: Error, Equatable {
        
        let value: String
    }
    
    func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
    }
}
