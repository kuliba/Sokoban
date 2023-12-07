//
//  QRPaymentTypeDictionaryTests.swift
//  
//
//  Created by Igor Malyarov on 15.11.2023.
//

import SberQR
import XCTest

final class QRPaymentTypeDictionaryTests: XCTestCase {
    
    func test_isSberQR() throws {
        
        let dict = try mapQRPaymentTypeJSON()
        
        XCTAssertFalse(dict.isSberQR("__.ru"))
        
        XCTAssert(dict.isSberQR("platimultiqr.ru"))
        XCTAssert(dict.isSberQR("multiqrpay.ru"))
        XCTAssert(dict.isSberQR("platiqr.ru"))
        XCTAssert(dict.isSberQR("ift.multiqr.ru"))
        XCTAssert(dict.isSberQR("sberbank.ru/qr"))
        XCTAssert(dict.isSberQR("pay.multiqr.ru"))
        XCTAssert(dict.isSberQR("multiqr.ru"))
    }
    
    func test_isSberQR_shouldReturnFalseForNonSberURL() throws {
        
        let dict = try mapQRPaymentTypeJSON()
        let anyURL = anyURL()
        
        XCTAssertFalse(dict.isSberQR(anyURL))
    }
    
    func test_isSberQR_shouldReturnTrueForSberURL() throws {
        
        let dict = try mapQRPaymentTypeJSON()
        let sberQRURL = try XCTUnwrap(URL(string: platiqr_ru()))

        XCTAssert(dict.isSberQR(sberQRURL))
    }
    
    // MARK: - Helpers
    
    private func mapQRPaymentTypeJSON() throws -> QRPaymentTypeDictionary {
        
        try ResponseMapper.mapQRPaymentTypeJSON(data: qrPaymentTypeJSON())
    }
    
    private func qrPaymentTypeJSON() throws -> Data {
        
        try Data(contentsOf: XCTUnwrap(qrPaymentTypeURL))
    }
    
    private func platiqr_ru() -> String {
        
        "https://platiqr.ru/?uuid=3001638371&amount=27.50&trxid=2023072420443097822"
    }
}
