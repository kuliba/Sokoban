//
//  File.swift
//  
//
//  Created by Valentin Ozerov on 08.11.2024.
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
