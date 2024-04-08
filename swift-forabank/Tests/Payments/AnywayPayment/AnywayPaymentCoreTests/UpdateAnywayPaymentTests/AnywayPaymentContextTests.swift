//
//  AnywayPaymentContextTests.swift
//  
//
//  Created by Igor Malyarov on 08.04.2024.
//

struct AnywayPaymentContext: Equatable {
    
    var staged = Set<AnywayPayment.Element.Field.ID>()
}

extension AnywayPaymentContext {
    
    mutating func stage() {
        
    }
}

import AnywayPaymentCore
import XCTest

final class AnywayPaymentContextTests: XCTestCase {
    
    func test_state_shouldNotChangeStagedOnEmptyParameters() {
        
        let noParametersPayment = makeAnywayPayment(parameters: [])
        var context = makeAnywayPaymentContext(payment: noParametersPayment)
        
        context.stage()
        
        XCTAssert(context.staged.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeAnywayPaymentContext(
        payment: AnywayPayment
    ) -> AnywayPaymentContext {
        
        .init()
    }
}
