//
//  URLMatchTests.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

import XCTest

final class URLMatchesTests: XCTestCase {
    
    func test_matches() throws {
        
        for content in contents {
            
            let sberQRURL = try XCTUnwrap(URL(string: "https://\(content)/\(UUID().uuidString)"))
            
            XCTAssert(
                sberQRURL.matches(.sberQR, in: sberQRMatches),
                "Expected to qualify \(sberQRURL) as SberQR URL, but did not."
            )
        }
    }
    
    // MARK: - Helpers
    
    private var sberQRMatches: [(content: String, paymentType: String)] {
        
        contents.map { (content: $0, paymentType: .sberQR) }
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
}

private extension String {
    
    static let sberQR = "SBERQR"
}
