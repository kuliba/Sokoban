//
//  XCTestCase+assert.swift
//  
//
//  Created by Igor Malyarov on 08.10.2023.
//

import XCTest

extension XCTestCase {
    
    func assert<T: Equatable, E: Error>(
        _ receivedResults: [Result<T, E>],
        equalsTo expectedResults: [Result<T, E>],
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            receivedResults.count,
            expectedResults.count,
            "Received \(receivedResults.count) values, but expected \(expectedResults.count).",
            file: file, line: line
        )
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, value in
                
                let (received, expected) = value
                
                switch (received, expected) {
                case let (
                    .failure(received as NSError),
                    .failure(expected as NSError)
                ):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                case let (
                    .success(received),
                    .success(expected)
                ):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                default:
                    XCTFail(
                        "\nReceived \(received) values, but expected \(expected) at index \(index).",
                        file: file, line: line
                    )
                }
            }
    }
    
    func assertVoid<E: Error>(
        _ receivedResults: [Result<Void, E>],
        equalsTo expectedResults: [Result<Void, E>],
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            receivedResults.count,
            expectedResults.count,
            "Received \(receivedResults.count) values, but expected \(expectedResults.count).",
            file: file, line: line
        )
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, value in
                
                let (received, expected) = value
                
                switch (received, expected) {
                case let (.failure(received as NSError), .failure(expected as NSError)):
                    XCTAssertEqual(received, expected, file: file, line: line)
                    
                case (.success, .success):
                    break
                    
                default:
                    XCTFail(
                        "Received \(received) values, but expected \(expected) at index  \(index).",
                        file: file, line: line
                    )
                }
            }
    }
}
