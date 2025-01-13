//
//  XCTestCase+XCTAssertThrowsAsNSError.swift
//  
//
//  Created by Igor Malyarov on 22.06.2023.
//

import XCTest

extension XCTestCase {
    
    func XCTAssertThrowsAsNSError<T>(
        _ expression: @autoclosure () throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        error: Error
    ) {
        
        XCTAssertThrowsError(
            try expression(),
            message(),
            file: file, line: line
        ) {
            XCTAssertEqual(
                $0 as NSError,
                error as NSError,
                file: file, line: line
            )
        }
    }
}
