//
//  XCTestCase+getJSON.swift
//  VortexTests
//
//  Created by Igor Malyarov on 03.05.2023.
//

import XCTest

extension XCTestCase {
    
    func getJSON(
        from filename: String,
        ext: String = "json",
        bundle: Bundle? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data {
        
        let bundle = bundle ?? .init(for: Self.self)
        let url = try XCTUnwrap(bundle.url(forResource: filename, withExtension: ext), "\n\nMissing file \"\(filename).\(ext)\" in bundle \"\(bundle.appName)\"", file: file, line: line)
        
        return try .init(contentsOf: url)
    }
}
