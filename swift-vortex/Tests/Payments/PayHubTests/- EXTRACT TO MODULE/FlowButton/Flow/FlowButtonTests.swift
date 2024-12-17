//
//  FlowButtonTests.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import XCTest

class FlowButtonTests: XCTestCase {
    
    struct Destination: Equatable {
        
        let value: String
    }
    
    func makeDestination(
        _ value: String = anyMessage()
    ) -> Destination {
        
        return .init(value: value)
    }
}
