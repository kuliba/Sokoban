//
//  VerifiableApplicationReducerTests.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

import CreditCardMVPCore
import XCTest

final class VerifiableApplicationReducerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, application, verification) = makeSUT()
        
        XCTAssertEqual(application.callCount, 0)
        XCTAssertEqual(verification.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - application
    
    func test_application_shouldCallApplicationReduceWithApplication() {
        
        let (sut, application, _) = makeSUT()
        let applicationState = makeApplication()
        let state = makeState(applicationState: applicationState)
        let applicationEvent = makeApplicationEvent()
        
        _ = sut.reduce(state, .application(applicationEvent))
        
        XCTAssertNoDiff(application.payloads.map(\.0), [applicationState])
        XCTAssertNoDiff(application.payloads.map(\.1), [applicationEvent])
    }
    
    func test_application_shouldDeliverApplicationReduceState() {
        
        let applicationState = makeApplication()
        let (sut, _,_) = makeSUT(applicationStub: (applicationState, nil))
        
        assert(sut: sut, makeState(), event: .application(makeApplicationEvent())) {
            
            $0.applicationState = applicationState
        }
    }
    
    func test_application_shouldDeliverApplicationReduceEffect() {
        
        let applicationEffect = makeApplicationEffect()
        let (sut, _,_) = makeSUT(applicationStub: (makeApplication(), applicationEffect))
        
        assert(sut: sut, makeState(), event: .application(makeApplicationEvent()), delivers: .application(applicationEffect))
    }
    
    func test_application_shouldDeliverApplicationReduceNilEffect() {
        
        let (sut, _,_) = makeSUT(applicationStub: (makeApplication(), nil))
        
        assert(sut: sut, makeState(), event: .application(makeApplicationEvent()), delivers: nil)
    }
    
    // MARK: - verification
    
    func test_verification_shouldCallVerificationReduceWithVerification() {
        
        let (sut, _, verification) = makeSUT()
        let verificationState = makeVerification()
        let state = makeState(verification: verificationState)
        let verificationEvent = makeVerificationEvent()
        
        _ = sut.reduce(state, .verification(verificationEvent))
        
        XCTAssertNoDiff(verification.payloads.map(\.0), [verificationState])
        XCTAssertNoDiff(verification.payloads.map(\.1), [verificationEvent])
    }
    
    func test_verification_shouldDeliverVerificationReduceState() {
        
        let verificationState = makeVerification()
        let (sut, _,_) = makeSUT(stub: (verificationState, nil))
        
        assert(sut: sut, makeState(), event: .verification(makeVerificationEvent())) {
            
            $0.verification = verificationState
        }
    }
    
    func test_verification_shouldDeliverVerificationReduceEffect() {
        
        let verificationEffect = makeVerificationEffect()
        let (sut, _,_) = makeSUT(stub: (makeVerification(), verificationEffect))
        
        assert(sut: sut, makeState(), event: .verification(makeVerificationEvent()), delivers: .verification(verificationEffect))
    }
    
    func test_verification_shouldDeliverVerificationReduceNilEffect() {
        
        let (sut, _,_) = makeSUT(stub: (makeVerification(), nil))
        
        assert(sut: sut, makeState(), event: .verification(makeVerificationEvent()), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = VerifiableApplicationReducer<ApplicationStatus, Verification, VerificationEvent, VerificationEffect, Failure>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias ApplicationSpy = CallSpy<(State.ApplicationState, Event.ApplicationEvent), (State.ApplicationState, Effect.ApplicationEffect?)>
    private typealias VerificationSpy = CallSpy<(Verification, VerificationEvent), (Verification, VerificationEffect?)>
    
    private func makeSUT(
        applicationStub: (State.ApplicationState, Effect.ApplicationEffect?)? = nil,
        stub: (Verification, VerificationEffect?)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        applicationSpy: ApplicationSpy,
        verification: VerificationSpy
    ) {
        let application = ApplicationSpy(stubs: [
            applicationStub ?? (.loading(nil), .load)
        ])
        let verification = VerificationSpy(stubs: [
            stub ?? (makeVerification(), makeVerificationEffect())
        ])
        let sut = SUT(
            applicationReduce: application.call,
            verificationReduce: verification.call
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(application, file: file, line: line)
        trackForMemoryLeaks(verification, file: file, line: line)
        
        return (sut, application, verification)
    }
    
    private func makeState(
        applicationState: State.ApplicationState = .loading(nil),
        verification: Verification? = nil
    ) -> State {
        
        return .init(
            applicationState: applicationState,
            verification: verification ?? makeVerification()
        )
    }
    
    private func makeApplication(
        _ status: ApplicationStatus? = nil
    ) -> State.ApplicationState {
        
        return .completed(status ?? makeApplicationStatus())
    }
    
    private struct ApplicationStatus: Equatable {
        
        let value: String
    }
    
    private func makeApplicationStatus(
        _ value: String = anyMessage()
    ) -> ApplicationStatus {
        
        return .init(value: value)
    }
    
    private func makeApplicationEvent(
        _ value: String = anyMessage()
    ) -> Event.ApplicationEvent {
        
        return .load
    }
    
    private func makeApplicationEffect(
        _ value: String = anyMessage()
    ) -> Effect.ApplicationEffect {
        
        return .load
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
