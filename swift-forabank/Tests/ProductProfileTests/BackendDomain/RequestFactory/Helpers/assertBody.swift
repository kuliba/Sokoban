//
//  assertBody.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import XCTest

func assertBody(
    of request: URLRequest,
    hasJSON json: String,
    file: StaticString = #file,
    line: UInt = #line
) throws {
    
    try XCTAssertNoDiff(
        String(data: XCTUnwrap(request.httpBody), encoding: .utf8)?.convertToDictionary(),
        json.convertToDictionary(),
        file: file, line: line
    )
}

private extension String {
    
    func convertToDictionary(
    ) -> [String: String]? {
        
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(
                with: data,
                options: []) as? [String: String]
        }
        return nil
    }
}
