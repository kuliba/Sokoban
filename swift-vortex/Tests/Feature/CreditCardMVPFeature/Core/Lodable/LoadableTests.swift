//
//  LoadableTests.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

import XCTest

class LoadableTests: XCTestCase {
    
    typealias State = LoadableState<Resource, Failure>
    
    struct Resource: Equatable {
        
        let value: String
    }
    
    func makeResource(
        _ value: String = anyMessage()
    ) -> Resource {
        
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
