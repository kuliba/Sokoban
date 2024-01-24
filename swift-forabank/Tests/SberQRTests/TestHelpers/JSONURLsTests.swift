//
//  JSONURLsTests.swift
//  
//
//  Created by Igor Malyarov on 15.11.2023.
//

import XCTest

let qrPaymentTypeURL = Bundle.module.url(forResource: "QRPaymentType", withExtension: "json")
let getSberQRData_any_sumURL = Bundle.module.url(forResource: "getSberQRData_any_sum", withExtension: "json")
let getSberQRData_fix_sumURL = Bundle.module.url(forResource: "getSberQRData_fix_sum", withExtension: "json")
let createSberQRPayment_IN_PROGRESSURL = Bundle.module.url(forResource: "createSberQRPayment_IN_PROGRESS", withExtension: "json")
let createSberQRPayment_rejectedURL = Bundle.module.url(forResource: "createSberQRPayment_rejected", withExtension: "json")
let createSberQRPaymentURL = Bundle.module.url(forResource: "createSberQRPayment", withExtension: "json")

final class JSONURLsTests: XCTestCase {
    
    func test_qrPaymentTypeURL() throws {
        
        let url = try XCTUnwrap(qrPaymentTypeURL)
        let contents = try Data(contentsOf: url)
        
        XCTAssertFalse(contents.isEmpty)
    }

    func test_getSberQRData_any_sumURL() throws {
        
        let url = try XCTUnwrap(getSberQRData_any_sumURL)
        let contents = try Data(contentsOf: url)
        
        XCTAssertFalse(contents.isEmpty)
    }

    func test_getSberQRData_fix_sumURL() throws {
        
        let url = try XCTUnwrap(getSberQRData_fix_sumURL)
        let contents = try Data(contentsOf: url)
        
        XCTAssertFalse(contents.isEmpty)
    }

    func test_createSberQRPayment_IN_PROGRESSURL() throws {
        
        let url = try XCTUnwrap(createSberQRPayment_IN_PROGRESSURL)
        let contents = try Data(contentsOf: url)
        
        XCTAssertFalse(contents.isEmpty)
    }

    func test_createSberQRPayment_rejectedURL() throws {
        
        let url = try XCTUnwrap(createSberQRPayment_rejectedURL)
        let contents = try Data(contentsOf: url)
        
        XCTAssertFalse(contents.isEmpty)
    }

    func test_createSberQRPaymentURL() throws {
        
        let url = try XCTUnwrap(createSberQRPaymentURL)
        let contents = try Data(contentsOf: url)
        
        XCTAssertFalse(contents.isEmpty)
    }
}
