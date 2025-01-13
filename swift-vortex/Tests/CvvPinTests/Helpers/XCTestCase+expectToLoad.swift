//
//  XCTestCase+expectToLoad.swift
//  
//
//  Created by Igor Malyarov on 15.07.2023.
//

import CvvPin
import XCTest

extension XCTestCase {
    
    typealias LoadResult = SessionCodeLoader.Result
    
    func expect(
        _ sut: SessionCodeLoader,
        toLoad expectedResult: LoadResult,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(received as NSError?), .failure(expected as NSError?)):
                XCTAssertEqual(received, expected, file: file, line: line)
                
            case let (.success(received), .success(expected)):
                XCTAssertEqual(received, expected, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
