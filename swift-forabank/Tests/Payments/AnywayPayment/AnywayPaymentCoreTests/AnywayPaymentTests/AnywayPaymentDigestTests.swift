//
//  AnywayPaymentDigestTests.swift
//  
//
//  Created by Igor Malyarov on 10.04.2024.
//

import AnywayPaymentCore
import XCTest

extension AnywayPayment {
    
    var digest: AnywayPaymentDigest {
        
        .init(
            check: false,
            amount: nil,
            product: nil,
            comment: nil,
            puref: nil,
            additionals: [],
            mcc: nil
        )
    }
}

final class AnywayPaymentDigestTests: XCTestCase {
    
    func test_shouldSetCheckToFalseOnPaymentWithoutOTP() {
        
        XCTAssertFalse(makeAnywayPaymentWithoutOTP().digest.check)
    }
    
    func test_shouldSetCheckToFalseOnPaymentWithOTP() {
        
        XCTAssertFalse(makeAnywayPaymentWithOTP().digest.check)
    }
}
