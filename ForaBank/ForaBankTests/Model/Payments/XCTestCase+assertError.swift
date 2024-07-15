//
//  XCTestCase+assertError.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 15.07.2024.
//

import XCTest

extension XCTestCase {
    func assert<T, E: LocalizedError>(
        _ thrownError: T,
        throws error: E,
        in file: StaticString = #file,
        line: UInt = #line
    ) {
        print("TTTTTT \(thrownError)")

        print("EEEEEEE \(error)")
        
        XCTAssertTrue(
            thrownError is E,
            "Unexpected error type: \(type(of: thrownError))",
            file: file, line: line
        )

        XCTAssertEqual(
            (thrownError as? E)?.errorDescription, error.errorDescription,
            file: file, line: line
        )
    }
}
