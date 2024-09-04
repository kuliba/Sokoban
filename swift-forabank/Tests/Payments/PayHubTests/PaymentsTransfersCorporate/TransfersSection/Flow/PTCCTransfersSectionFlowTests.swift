//
//  PTCCTransfersSectionFlowTests.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import XCTest

class PTCCTransfersSectionFlowTests: XCTestCase {
    
    struct Navigation: Equatable {
        
        let value: String
    }
    
    func makeNavigation(
        _ value: String = anyMessage()
    ) -> Navigation {
        
        return .init(value: value)
    }
    struct Select: Equatable {
        
        let value: String
    }
    
    func makeSelect(
        _ value: String = anyMessage()
    ) -> Select {
        
        return .init(value: value)
    }
}
