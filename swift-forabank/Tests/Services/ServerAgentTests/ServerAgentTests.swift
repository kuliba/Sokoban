//
//  ServerAgentTests.swift
//  
//
//  Created by Igor Malyarov on 02.09.2023.
//

import ServerAgent
import XCTest

final class ServerAgentTests: XCTestCase {
    
    func test_init() {
        
        _ = ServerAgent(
            baseURL: "",
            encoder: .init(),
            decoder: .init(),
            logError: { _ in },
            logMessage: { _ in },
            sendAction: { _ in }
        )
    }
}
