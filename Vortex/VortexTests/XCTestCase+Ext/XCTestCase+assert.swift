//
//  XCTestCase+assert.swift
//  VortexTests
//
//  Created by Igor Malyarov on 12.11.2023.
//

import XCTest

extension XCTestCase {
    
    func assert<T: Equatable, E: Error & Equatable>(
        _ receivedResults: [Result<T, E>],
        equals expectedResults: [Result<T, E>],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(receivedResults.count, expectedResults.count, "\nExpected \(expectedResults.count) values, but got \(receivedResults.count)", file: file, line: line)
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, element in
                
                switch element {
                case let (
                    .failure(receivedError),
                    .failure(expectedError)
                ):
                    XCTAssertNoDiff(receivedError, expectedError, file: file, line: line)
                    
                case let (
                    .success(received),
                    .success(expected)
                ):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                default:
                    XCTFail("\nExpected \(element.1) at index \(index), but got \(element.0)", file: file, line: line)
                }
            }
    }
}
