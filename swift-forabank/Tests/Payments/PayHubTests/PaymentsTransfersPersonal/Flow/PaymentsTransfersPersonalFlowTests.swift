//
//  PaymentsTransfersPersonalFlowTests.swift
//  
//
//  Created by Igor Malyarov on 17.08.2024.
//

import XCTest

class PaymentsTransfersPersonalFlowTests: XCTestCase {
    
    typealias Profile = String
    typealias QR = Int
    
    func makeProfile(
        _ value: String = anyMessage()
    ) -> Profile {
        
        return value
    }
    
    func makeQR(
        _ value: Int = .random(in: 1...100)
    ) -> QR {
        
        return value
    }
}
