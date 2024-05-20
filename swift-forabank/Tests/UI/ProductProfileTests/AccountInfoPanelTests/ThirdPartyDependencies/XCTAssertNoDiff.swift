//
//  XCTAssertNoDiff.swift
//
//
//  Created by Igor Malyarov on 23.04.2023.
//

import CustomDump
import XCTest

func XCTAssertNoDiff<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) where T: Equatable {
    
    do {
        let expression1 = try expression1()
        let expression2 = try expression2()
        let message = message()
        
        XCTAssertNoDifference(
            expression1,
            expression2,
            message,
            file: file,
            line: line
        )
    } catch {
        XCTFail(
                """
                Assert failed with error "\(error)"
                """,
                file: file,
                line: line
        )
    }
}

final class XCTAssertNoDiffTests: XCTestCase {
    
    /// A test to keep code coverage from dropping on `XCTAssertNoDiff` happy paths.
    func test_XCTAssertNoDiff_couldFail() throws {
        
        let failing: (_ int: Int) throws -> Int = {
            
            throw NSError(domain: "XCTAssertNoDiff", code: $0)
        }
        
        try XCTExpectFailure {
            XCTAssertNoDiff(0, try failing(1))
        }
    }
}
