//
//  RootViewModelFactory+runOnEachNextActiveSessionTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 16.12.2024.
//

import Combine
@testable import Vortex
import XCTest

final class RootViewModelFactory_runOnEachNextActiveSessionTests: RootViewModelFactoryTests {
    
    func test_shouldNotRunOnInactiveSession() {
        
        let (sut, _, spy) = makeSUT(sessionState: .inactive)
        let cancellable = sut.runOnEachNextActiveSession(spy.call)
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotRunOnSessionFlipToActive() {
        
        let (sut, sessionAgent, spy) = makeSUT(sessionState: .inactive)
        let cancellable = sut.runOnEachNextActiveSession(spy.call)
        
        sessionAgent.activate()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotRunOnSessionFlipToInactiveAfterActive() {
        
        let (sut, sessionAgent, spy) = makeSUT(sessionState: .inactive)
        let cancellable = sut.runOnEachNextActiveSession(spy.call)
        
        sessionAgent.activate()
        sessionAgent.deactivate()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotRunOnSessionFlipToActivatingAfterActive() {
        
        let (sut, sessionAgent, spy) = makeSUT(sessionState: .inactive)
        let cancellable = sut.runOnEachNextActiveSession(spy.call)
        
        sessionAgent.activate()
        sessionAgent.sessionState.send(.activating)
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotRunOnSessionFlipToExpiredAfterActive() {
        
        let (sut, sessionAgent, spy) = makeSUT(sessionState: .inactive)
        let cancellable = sut.runOnEachNextActiveSession(spy.call)
        
        sessionAgent.activate()
        sessionAgent.expire()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotRunOnSessionFlipToFailedAfterActive() {
        
        let (sut, sessionAgent, spy) = makeSUT(sessionState: .inactive)
        let cancellable = sut.runOnEachNextActiveSession(spy.call)
        
        sessionAgent.activate()
        sessionAgent.fail()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldRunOnSessionFlipToActiveAgain() {
        
        let (sut, sessionAgent, spy) = makeSUT(sessionState: .inactive)
        let cancellable = sut.runOnEachNextActiveSession(spy.call)
        
        sessionAgent.activate()
        sessionAgent.expire()
        sessionAgent.activate()
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldRunOnSessionFlipToYetActiveAgain() {
        
        let (sut, sessionAgent, spy) = makeSUT(sessionState: .inactive)
        let cancellable = sut.runOnEachNextActiveSession(spy.call)
        
        sessionAgent.activate()
        sessionAgent.deactivate()
        sessionAgent.activate()
        sessionAgent.expire()
        sessionAgent.activate()
        
        XCTAssertEqual(spy.callCount, 2)
        XCTAssertNotNil(cancellable)
    }
    
    // MARK: - Helpers
    
    private typealias WorkSpy = CallSpy<Void, Void>
    
    private func makeSUT(
        sessionState: SessionState = .inactive,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        sessionAgent: SessionAgentEmptyMock,
        spy: WorkSpy
    ) {
        let sessionAgent = SessionAgentEmptyMock()
        sessionAgent.sessionState.value = sessionState
        let model: Model = .mockWithEmptyExcept(sessionAgent: sessionAgent)
        let sut = makeSUT(model: model).sut
        let spy = WorkSpy(stubs: .init(repeating: (), count: 5))
        
        trackForMemoryLeaks(sessionAgent, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, sessionAgent, spy)
    }
}

// MARK: - DSL

extension SessionAgentEmptyMock {
    
    func activate() {
        
        sessionState.send(active())
    }
    
    func deactivate() {
        
        sessionState.send(.inactive)
    }
    
    func expire() {
        
        sessionState.send(.expired)
    }
    
    func fail(error: Error = anyError()) {
        
        sessionState.send(.failed(error))
    }
    
    func startActivating() {
        
        sessionState.send(.activating)
    }
    
    private func active() -> SessionState {
        
        return .active(
            start: .infinity,
            credentials: .init(
                token: anyMessage(),
                csrfAgent: CSRFAgentDummy.dummy
            )
        )
    }
}
