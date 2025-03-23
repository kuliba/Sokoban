//
//  VerifiableApplicationReducerTests.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

import StateMachines

struct VerifiableApplication<ApplicationStatus, Verification, Failure: Error> {
    
    var application: ApplicationState = .pending
    var verification: Verification
    
    typealias ApplicationState = StateMachines.LoadState<ApplicationStatus, Failure>
}

extension VerifiableApplication: Equatable where ApplicationStatus: Equatable, Verification: Equatable, Failure: Equatable {}

enum VerifiableApplicationEvent<VerificationEvent> {
    
    case verification(VerificationEvent)
}

extension VerifiableApplicationEvent: Equatable where VerificationEvent: Equatable {}

enum VerifiableApplicationEffect<VerificationEffect> {
    
    case verification(VerificationEffect)
}

extension VerifiableApplicationEffect: Equatable where VerificationEffect: Equatable {}

final class VerifiableApplicationReducer<ApplicationStatus, Verification, VerificationEvent, VerificationEffect, Failure: Error> {
    
    private let verificationReduce: VerificationReduce
    
    init(
        verificationReduce: @escaping VerificationReduce
    ) {
        self.verificationReduce = verificationReduce
    }
    
    typealias VerificationReduce = (Verification, VerificationEvent) -> (Verification, VerificationEffect?)
}

extension VerifiableApplicationReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .verification(verificationEvent):
            reduce(&state, &effect, with: verificationEvent)
        }
        
        return (state, effect)
    }
}

extension VerifiableApplicationReducer {
    
    typealias State = VerifiableApplication<ApplicationStatus, Verification, Failure>
    typealias Event = VerifiableApplicationEvent<VerificationEvent>
    typealias Effect = VerifiableApplicationEffect<VerificationEffect>
}

private extension VerifiableApplicationReducer {
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with verificationEvent: VerificationEvent
    ) {
        _ = verificationReduce(state.verification, verificationEvent)
    }
}

import XCTest

final class VerifiableApplicationReducerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, verification) = makeSUT()
        
        XCTAssertEqual(verification.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - verification
    
    func test_verification_shouldCallVerificationReduceWithVerification() {
        
        let (sut, verification) = makeSUT()
        let verificationState = makeVerification()
        let state = makeState(verification: verificationState)
        let verificationEvent = makeVerificationEvent()
        
        _ = sut.reduce(state, .verification(verificationEvent))
        
        XCTAssertNoDiff(verification.payloads.map(\.0), [verificationState])
        XCTAssertNoDiff(verification.payloads.map(\.1), [verificationEvent])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = VerifiableApplicationReducer<ApplicationStatus, Verification, VerificationEvent, VerificationEffect, Failure>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias VerificationSpy = CallSpy<(Verification, VerificationEvent), (Verification, VerificationEffect?)>
    
    private func makeSUT(
        stub: (Verification, VerificationEffect?)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        verification: VerificationSpy
    ) {
        let verification = VerificationSpy(stubs: [
            stub ?? (makeVerification(), makeVerificationEffect())
        ])
        let sut = SUT(verificationReduce: verification.call)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(verification, file: file, line: line)
        
        return (sut, verification)
    }
    
    private func makeState(
        application: State.ApplicationState = .loading(nil),
        verification: Verification? = nil
    ) -> State {
        
        return .init(
            application: application,
            verification: verification ?? makeVerification()
        )
    }
    
    private struct ApplicationStatus: Equatable {
        
        let value: String
    }
    
    private func makeApplicationStatus(
        _ value: String = anyMessage()
    ) -> ApplicationStatus {
        
        return .init(value: value)
    }
    
    private struct Verification: Equatable {
        
        let value: String
    }
    
    private func makeVerification(
        _ value: String = anyMessage()
    ) -> Verification {
        
        return .init(value: value)
    }
    
    private struct VerificationEvent: Equatable {
        
        let value: String
    }
    
    private func makeVerificationEvent(
        _ value: String = anyMessage()
    ) -> VerificationEvent {
        
        return .init(value: value)
    }
    
    private struct VerificationEffect: Equatable {
        
        let value: String
    }
    
    private func makeVerificationEffect(
        _ value: String = anyMessage()
    ) -> VerificationEffect {
        
        return .init(value: value)
    }
    
    private struct Failure: Error, Equatable {
        
        let value: String
    }
    
    private func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        event: Event,
        updateStateToExpected: ((inout State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> State {
        
        let sut = sut ?? makeSUT(file: file, line: line).sut
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(String(describing: expectedState)), but got \(String(describing: receivedState)) instead.",
            file: file, line: line
        )
        
        return receivedState
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        event: Event,
        delivers expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line).sut
        
        let (_, receivedEffect): (State, Effect?) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
