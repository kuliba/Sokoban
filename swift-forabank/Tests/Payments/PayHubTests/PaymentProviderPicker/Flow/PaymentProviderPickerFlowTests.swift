//
//  PaymentProviderPickerFlowTests.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

import XCTest

class PaymentProviderPickerFlowTests: XCTestCase {
    
    struct Latest: Equatable {
        
        let value: String
    }
    
    func makeLatest(
        _ value: String = anyMessage()
    ) -> Latest {
        
        return .init(value: value)
    }
}
