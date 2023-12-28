//
//  assert.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import XCTest

func assert<T: Equatable>(
    _ receivedResult: Result<T, MappingError>,
    equals expectedResult: Result<T, MappingError>,
    file: StaticString = #file,
    line: UInt = #line
) {
    switch (receivedResult, expectedResult) {
    case let (
        .failure(received),
        .failure(expected)
    ):
        XCTAssertNoDiff(received, expected, file: file, line: line)
        
    case let (
        .success(received),
        .success(expected)
    ):
        XCTAssertNoDiff(received, expected, file: file, line: line)
        
    default:
        XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
    }
}
