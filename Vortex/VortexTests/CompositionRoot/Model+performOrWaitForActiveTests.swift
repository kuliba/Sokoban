//
//  Model+performOrWaitForActiveTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.10.2024.
//

import Combine
import CombineSchedulers
@testable import ForaBank
import XCTest

final class Model_performOrWaitForActiveTests: XCTestCase {
    
    func test_shouldExecuteWorkOnActiveSession() {
        
        let exp = expectation(description: "wait for work")
        let (sut, _, cancellable) = makeSUT(
            sessionState: active(),
            work: exp.fulfill
        )
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotExecuteWorkOnInactiveSession() {
        
        let exp = expectation(description: "wait for work")
        exp.isInverted = true
        let (sut, _, cancellable) = makeSUT(
            sessionState: .inactive,
            work: exp.fulfill
        )
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldExecuteWorkOnceSessionFlipToActiveFromInactive() {
        
        let exp = expectation(description: "wait for work")
        let (sut, sessionAgent, cancellable) = makeSUT(
            sessionState: .inactive,
            work: exp.fulfill
        )
        
        sessionAgent.sessionState.value = active()
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(cancellable)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Model
    
    private func makeSUT(
        sessionState: SessionState,
        work: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        sessionAgent: SessionAgentEmptyMock,
        cancellable: AnyCancellable
    ) {
        let sessionAgent = SessionAgentEmptyMock()
        sessionAgent.sessionState.value = sessionState
        
        let sut = SUT.mockWithEmptyExcept(sessionAgent: sessionAgent)
        let cancellable = sut.performOrWaitForActive(work)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(sessionAgent, file: file, line: line)
        trackForMemoryLeaks(cancellable, file: file, line: line)
        
        return (sut, sessionAgent, cancellable)
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
