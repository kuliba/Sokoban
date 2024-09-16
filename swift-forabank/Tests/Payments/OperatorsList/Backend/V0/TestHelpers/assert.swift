//
//  assert.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import XCTest

func assert<T: Equatable, E: Equatable>(
    _ receivedResult: Result<T, E>,
    equals expectedResult: Result<T, E>,
    file: StaticString = #file,
    line: UInt = #line
) {
    switch (receivedResult, expectedResult) {
    case let (.failure(receivedError), .failure(expectedError)):
        XCTAssertNoDiff(receivedError, expectedError, file: file, line: line)
        
    case let (.success(receivedValue), .success(expectedValue)):
        XCTAssertNoDiff(receivedValue, expectedValue, file: file, line: line)

    default:
        XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
    }
}

func assert<E: Equatable>(
    _ receivedResult: Result<Void, E>,
    equals expectedResult: Result<Void, E>,
    file: StaticString = #file,
    line: UInt = #line
) {
    switch (receivedResult, expectedResult) {
    case let (
        .failure(received),
        .failure(expected)
    ):
        XCTAssertNoDiff(received, expected, file: file, line: line)
        
    case (
        .success(()),
        .success(())
    ):
        break
        
    default:
        XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
    }
}
