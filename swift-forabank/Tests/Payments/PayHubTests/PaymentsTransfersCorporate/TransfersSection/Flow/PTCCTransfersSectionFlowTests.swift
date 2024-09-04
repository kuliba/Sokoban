//
//  PTCCTransfersSectionFlowTests.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import XCTest

class PTCCTransfersSectionFlowTests: XCTestCase {
    
    struct Select: Equatable {
        
        let value: String
    }
    
    func makeSelect(
        _ value: String = anyMessage()
    ) -> Select {
        
        return .init(value: value)
    }
}
