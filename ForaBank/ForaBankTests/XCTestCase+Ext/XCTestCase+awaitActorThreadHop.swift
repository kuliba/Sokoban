//
//  XCTestCase+awaitActorThreadHop.swift
//  VortexTests
//
//  Created by Igor Malyarov on 16.10.2024.
//

import XCTest

extension XCTestCase {
    
    func awaitActorThreadHop(
        timeout: TimeInterval = 0.05
    ) {
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}
