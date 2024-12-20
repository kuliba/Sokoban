//
//  XCTestCase+ValueSpy+assert.swift
//  
//
//  Created by Igor Malyarov on 24.06.2023.
//

import XCTest

extension XCTestCase {
    
    func assert<T: Equatable>(
        _ received: [ValueSpy<T>.Event],
        _ expected: [ValueSpy<T>.Event],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            received.count,
            expected.count,
            "Received \(received.count) values, but expected \(expected.count).",
            file: file, line: line
        )
        
        zip(received, expected)
            .enumerated()
            .forEach { index, value in
                
                let (received, expected) = value
                
                switch (received, expected) {
                case (.failure, .failure),
                    (.finished, .finished):
                    break
                    
                case let (.value(received), .value(expected)):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                default:
                    XCTFail(
                        "Received \(received) values, but expected \(expected) at index  \(index).",
                        file: file, line: line
                    )
                }
            }
    }
}
