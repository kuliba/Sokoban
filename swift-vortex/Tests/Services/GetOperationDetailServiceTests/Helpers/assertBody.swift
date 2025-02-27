//
//  assertBody.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.12.2023.
//

import XCTest

func assertBody(
    of request: URLRequest,
    hasJSON expectedJSON: String,
    file: StaticString = #file,
    line: UInt = #line
) throws {
    
    guard let httpBody = request.httpBody 
    else { return XCTFail("httpBody is nil", file: file, line: line) }
    
    let expectedData = try XCTUnwrap(expectedJSON.data(using: .utf8), "Expected JSON is not valid UTF-8", file: file, line: line)
    
    let actualObject = try JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyHashable]
    let expectedObject = try JSONSerialization.jsonObject(with: expectedData, options: []) as? [String: AnyHashable]
    
    XCTAssertNoDiff(actualObject, expectedObject, file: file, line: line)
}
