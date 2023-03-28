//
//  ActiveSessionAgentStubTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.02.2023.
//

@testable import ForaBank
import XCTest

#if MOCK
final class ActiveSessionAgentStubTests: XCTestCase {
    
    func test_init() {
        
        let sut = ActiveSessionAgentStub()
        let state: SessionState = sut.sessionState.value
        
        switch state {
        case .active:
            break
            
        default:
            XCTFail("Expected active state, got \(state) instead.")
        }
    }
}
#endif
