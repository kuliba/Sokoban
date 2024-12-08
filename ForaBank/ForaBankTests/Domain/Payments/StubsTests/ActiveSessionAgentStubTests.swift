//
//  ActiveSessionAgentStubTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 24.02.2023.
//

@testable import Vortex
import XCTest

final class ActiveSessionAgentStubTests: XCTestCase {
    
    func test_init() {
        
        let sut = ActiveSessionAgentStub()
        let state_: SessionState = sut.sessionState.value
        
        switch state_ {
        case .active:
            break
            
        default:
            XCTFail("Expected active state, got \(state_) instead.")
        }
    }
}
