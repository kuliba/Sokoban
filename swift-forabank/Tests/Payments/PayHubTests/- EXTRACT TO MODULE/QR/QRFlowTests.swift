//
//  QRFlowTests.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import XCTest

class QRFlowTests: XCTestCase {
    
    struct ScanResult: Equatable {
        
        let value: String
    }
    
    func makeScanResult(
        _ value: String = anyMessage()
    ) -> ScanResult {
        
        return .init(value: value)
    }
    
    struct Destination: Equatable {
        
        let value: String
    }
    
    func makeDestination(
        _ value: String = anyMessage()
    ) -> Destination {
        
        return .init(value: value)
    }
}
