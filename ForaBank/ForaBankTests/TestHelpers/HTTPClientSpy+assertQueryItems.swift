//
//  HTTPClientSpy+assertQueryItems.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.09.2024.
//

import XCTest

extension HTTPClientSpy {
    
    func assert(
        queryItems expectedQueryItems: [[URLQueryItem]],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(queryItems, expectedQueryItems, "Expected \(expectedQueryItems), got \(queryItems) instead.", file: file, line: line)
    }
    
    var queryItems: [[URLQueryItem]] {
        
        requests
            .compactMap(\.url)
            .compactMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
            .compactMap(\.queryItems)
    }
}
