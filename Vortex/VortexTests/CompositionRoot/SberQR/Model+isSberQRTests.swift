//
//  Model+isSberQRTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.12.2023.
//

@testable import Vortex
import XCTest

final class Model_isSberQRTests: XCTestCase {
    
    func test_isSberQR_shouldReturnFalseForSberQROnEmptyDictionary() {
        
        let sut = makeSUT()
        
        for content in contents {
            
            let url = anyURL(string: "https://\(content)/\(UUID().uuidString)")
            
            XCTAssertFalse(sut.isSberQR(url), "Expected false for \(content) on empty dictionary, but got true.")
            XCTAssert(sut.isQRDictionaryEmpty())
        }
    }
    
    func test_isSberQR_shouldReturnTrueForSberQROnNonEmptyDictionary() {
        
        let sut = makeSUT()
        sut.addSberQRTypes()
        
        for content in contents {
            
            let url = anyURL(string: "https://\(content)/\(UUID().uuidString)")
            
            XCTAssert(sut.isSberQR(url), "Expected false for \(content) on empty dictionary, but got true.")
            XCTAssertFalse(sut.isQRDictionaryEmpty())
        }
    }
    
    func test_isSberQR_shouldReturnFalseForNonSberQROnNonEmptyDictionary() {
        
        let sut = makeSUT()
        sut.addSberQRTypes()
        let url = anyURL()
        
        XCTAssertFalse(sut.isSberQR(url))
        XCTAssertFalse(sut.isQRDictionaryEmpty())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut: Model = .mockWithEmptyExcept()
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}

private extension Model {
    
    func addSberQRTypes() {
        
        let qrPaymentTypes: [QRPaymentType] = contents.map {
            
            .init(content: $0, paymentType: .sberQR)
        }
        addQRPaymentTypeAndWait(qrPaymentTypes)
    }
    
    func addQRPaymentTypeAndWait(
        _ qrPaymentTypes: [QRPaymentType],
        timeout: TimeInterval = 0.05
    ) {
        qrPaymentType.send(qrPaymentTypes)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func isQRDictionaryEmpty() -> Bool {
        
        qrPaymentType.value.isEmpty
    }
}

private let contents = [
    "platimultiqr.ru",
    "multiqrpay.ru",
    "platiqr.ru",
    "ift.multiqr.ru",
    "sberbank.ru/qr",
    "pay.multiqr.ru",
    "multiqr.ru",
]

private extension String {
    
    static let sberQR = "SBERQR"
}
