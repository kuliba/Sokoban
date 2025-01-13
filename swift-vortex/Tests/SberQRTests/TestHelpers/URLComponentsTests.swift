//
//  URLComponentsTests.swift
//
//
//  Created by Igor Malyarov on 15.11.2023.
//

import XCTest

/// https://pl.innovation.ru/dbo/api/v3/dict/QRPaymentType?serial=7d6bbcc2a0f9aee7b4cd02c8392f4e8c

/// Пример ссылки  https://platiqr.ru/?uuid=3001638371&amount=27.50&trxid=2023072420443097822

final class URLComponentsTests: XCTestCase {
    
    func test() throws {
        
        let url = try XCTUnwrap(URL(string: platiqr_ru()))
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = try XCTUnwrap(components.queryItems)
        let parameters = queryItems.compactMap { item in
        
            item.value.map { (item.name, $0) }
        }
        let dict = Dictionary(uniqueKeysWithValues: parameters)
        
        XCTAssertEqual(dict, ["trxid": "2023072420443097822", "amount": "27.50", "uuid": "3001638371"])
    }
    
    // MARK: - Helpers
    
    private func platiqr_ru() -> String {
        
        "https://platiqr.ru/?uuid=3001638371&amount=27.50&trxid=2023072420443097822"
    }
}
