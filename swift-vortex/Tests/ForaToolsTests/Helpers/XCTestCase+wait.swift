//
//  XCTestCase+wait.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.08.2024.
//

import XCTest

extension XCTestCase {
    
    func wait(timeout: TimeInterval = 0.05) {
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}
