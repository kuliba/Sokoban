//
//  XCTestCase+wait.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

import XCTest

extension XCTestCase {
    
    func wait(timeout: TimeInterval = 0.05) {
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func wait(
        delay: TimeInterval = 0.05,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line,
        action: @escaping () throws -> Void
    ) {
        let exp = expectation(description: "wait for async execution")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            do {
                try action()
                exp.fulfill()
            } catch {
                XCTFail("Failure \(error).", file: file, line: line)
            }
        }
        
        wait(for: [exp], timeout: timeout)
    }
}
