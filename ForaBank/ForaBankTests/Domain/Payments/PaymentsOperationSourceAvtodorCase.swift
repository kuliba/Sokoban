//
//  PaymentsOperationSourceAvtodorCase.swift
//  VortexTests
//
//  Created by Igor Malyarov on 16.06.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsOperationSourceAvtodorCase: XCTestCase {
    
    func test_sourceAvtodorCaseHasDescription() {
        
        let source: Payments.Operation.Source = .avtodor
        
        XCTAssertEqual(source.debugDescription, "Fake/Combined Avtodor")
    }
}
