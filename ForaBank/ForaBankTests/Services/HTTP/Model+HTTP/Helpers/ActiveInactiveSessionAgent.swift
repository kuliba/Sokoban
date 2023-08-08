//
//  ActiveInactiveSessionAgent.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.08.2023.
//

import Combine
@testable import ForaBank
import XCTest

final class ActiveInactiveSessionAgent: SessionAgentProtocol {
    
    let action: PassthroughSubject<Action, Never> = .init()
    let sessionState: CurrentValueSubject<SessionState, Never> = .init(.inactive)
    
    func activate() {
        
        let token = UUID().uuidString
        let csrfAgent = CSRFAgentDummy.dummy
        let credentials: SessionCredentials = .init(
            token: token,
            csrfAgent: csrfAgent
        )
        let activeState = SessionState.active(
            start: 0,
            credentials: credentials
        )
        
        sessionState.send(activeState)
    }
    
    func deactivate() {
        
        sessionState.send(.inactive)
    }
}

final class ActiveInactiveSessionAgentTests: XCTestCase {
    
    func test_sessionAgent_activateDeactivate_shouldSetToken() {
        
        let sessionAgent = ActiveInactiveSessionAgent()
        let model: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent
        )
        
        XCTAssertNil(model.token)
        
        sessionAgent.activate()
        XCTAssertNotNil(model.token)
        
        sessionAgent.deactivate()
        XCTAssertNil(model.token)
    }

}
