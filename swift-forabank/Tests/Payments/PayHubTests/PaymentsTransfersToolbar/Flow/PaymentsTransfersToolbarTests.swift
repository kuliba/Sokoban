//
//  PaymentsTransfersToolbarTests.swift
//  
//
//  Created by Igor Malyarov on 22.08.2024.
//

import XCTest

class PaymentsTransfersToolbarTests: XCTestCase {
    
    struct Profile: Equatable {
        
        let value: String
    }
    
    func makeProfile(
        _ value: String = anyMessage()
    ) -> Profile {
        
        return .init(value: value)
    }
    
    struct QR: Equatable {
        
        let value: String
    }
    
    func makeQR(
        _ value: String = anyMessage()
    ) -> QR {
        
        return .init(value: value)
    }
}
