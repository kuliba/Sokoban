//
//  FlowTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import XCTest

class FlowTests: XCTestCase {
    
    struct Select: Equatable {
        
        let value: String
    }
    
    func makeSelect(
        _ value: String = anyMessage()
    ) -> Select {
        
        return .init(value: value)
    }
    
    struct Navigation: Equatable {
        
        let value: String
    }
    
    func makeNavigation(
        _ value: String = anyMessage()
    ) -> Navigation {
        
        return .init(value: value)
    }
}
