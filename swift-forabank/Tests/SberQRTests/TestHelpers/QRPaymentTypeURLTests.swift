//
//  QRPaymentTypeURLTests.swift
//  
//
//  Created by Igor Malyarov on 15.11.2023.
//

import XCTest

let qrPaymentTypeURL = Bundle.module.url(forResource: "QRPaymentType", withExtension: "json")

final class QRPaymentTypeURLTests: XCTestCase {
    
    func test_QRPaymentTypeURL() throws {
        
        let url = try XCTUnwrap(qrPaymentTypeURL)
        let contents = try Data(contentsOf: url)
        
        XCTAssertFalse(contents.isEmpty)
    }
}
