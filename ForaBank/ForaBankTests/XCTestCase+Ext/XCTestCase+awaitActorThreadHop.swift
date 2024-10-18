//
//  XCTestCase+awaitActorThreadHop.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 16.10.2024.
//

import XCTest

extension XCTestCase {
    
    func awaitActorThreadHop(
        timeout: TimeInterval = 0.1
    ) {
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
}
