//
//  assertBody.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.12.2023.
//

import XCTest

func assertBody(
    of request: URLRequest,
    hasJSON json: String,
    file: StaticString = #file,
    line: UInt = #line
) throws {
    
    try XCTAssertNoDiff(
        String(data: XCTUnwrap(request.httpBody), encoding: .utf8),
        json.replacingOccurrences(of: "\\s", with: "", options: .regularExpression),
        file: file, line: line
    )
}
