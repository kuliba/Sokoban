//
//  XCTestCase+assertRequest.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.03.2025.
//

import XCTest

extension XCTestCase {
    
    func assert(
        _ request: URLRequest,
        hasKeys keys: Set<String>,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try XCTAssertNoDiff(.init(XCTUnwrap(request.url).queryItemsDict.keys), keys, file: file, line: line)
    }
    
    func assert(
        _ request: URLRequest,
        hasKey key: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try XCTAssertFalse(XCTUnwrap(request.url).queryItemsDict.keys.contains(key), file: file, line: line)
    }
    
    func assert(
        _ request: URLRequest,
        has value: String?,
        forKey key: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try XCTAssertNoDiff(XCTUnwrap(request.url).queryItemsDict[key], value, file: file, line: line)
    }
}

extension URL {
    
    var removingQueryItems: URL? {
        
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.query = nil
        
        return components?.url
    }
    
    var queryItemsDict: [String: String?] {
        
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce(into: [:]) { dict, item in
                dict[item.name] = item.value
            } ?? [:]
    }
}
