//
//  PayHubTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

import Combine
import PayHub
import XCTest

class PayHubTests: XCTestCase {
    
    struct Latest: Hashable {
        
        let value: String
    }
    
    func makeLatest(
        _ value: String = anyMessage()
    ) -> Latest {
        
        return .init(value: value)
    }
}
