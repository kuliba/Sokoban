//
//  XCTestCase+_assert.swift
//  
//
//  Created by Igor Malyarov on 09.11.2023.
//

import Fetcher
import XCTest

extension XCTestCase {
    
    func expect<Payload, Success: Equatable, Failure: Error>(
        _ sut: any Fetcher<Payload, Success, Failure>,
        payload: Payload,
        toDeliver expectedResults: [Result<Success, Failure>],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [Result<Success, Failure>]()
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(payload) {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        _assert(receivedResults, equals: expectedResults, file: file, line: line)
    }
    
    func _assert<T: Equatable, E: Error>(
        _ receivedResults: [Result<T, E>],
        equals expectedResults: [Result<T, E>],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(receivedResults.count, expectedResults.count, "\nExpected \(expectedResults.count) values, bit got \(receivedResults.count).", file: file, line: line)
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, element in
                
                switch element {
                case let (
                    .failure(received as NSError),
                    .failure(expected as NSError)
                ):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                case let (.success(received), .success(expected)):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                default:
                    XCTFail("Expected \(element.1), but got \(element.0).", file: file, line: line)
                }
            }
    }
    
    func _assert<T: Equatable, E: Error & Equatable>(
        _ receivedResults: [Result<T, E>],
        equals expectedResults: [Result<T, E>],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(receivedResults.count, expectedResults.count, "\nExpected \(expectedResults.count) values, bit got \(receivedResults.count).", file: file, line: line)
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, element in
                
                switch element {
                case let (
                    .failure(received),
                    .failure(expected)
                ):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                case let (.success(received), .success(expected)):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                default:
                    XCTFail("Expected \(element.1), but got \(element.0).", file: file, line: line)
                }
            }
    }
}
