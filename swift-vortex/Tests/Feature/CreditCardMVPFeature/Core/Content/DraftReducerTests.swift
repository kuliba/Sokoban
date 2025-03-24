//
//  DraftReducerTests.swift
//  
//
//  Created by Igor Malyarov on 23.03.2025.
//

import CreditCardMVPCore
import XCTest

final class DraftReducerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, application, verification) = makeSUT()
        
        XCTAssertEqual(application.callCount, 0)
        XCTAssertEqual(verification.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - application
    
    func test_application_shouldCallConsentReduceWithConsent() {
        
        let (sut, application, _) = makeSUT()
        let consent = makeConsent()
        let state = makeState(consent: consent)
        let consentEvent = makeConsentEvent()
        
        _ = sut.reduce(state, .consent(consentEvent))
        
        XCTAssertNoDiff(application.payloads.map(\.0), [consent])
        XCTAssertNoDiff(application.payloads.map(\.1), [consentEvent])
    }
    
    func test_application_shouldDeliverConsentReduceState() {
        
        let consent = makeConsent()
        let (sut, _,_) = makeSUT(consentStub: consent)
        
        assert(sut: sut, makeState(), event: .consent(makeConsentEvent())) {
            
            $0.consent = consent
        }
    }
    
    func test_consent_shouldDeliverConsentReduceNilEffect() {
        
        let (sut, _,_) = makeSUT(consentStub: makeConsent())
        
        assert(sut: sut, makeState(), event: .consent(makeConsentEvent()), delivers: nil)
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
        let (sut, _,_) = makeSUT(verificationStub: (verificationState, nil))
        
        assert(sut: sut, makeState(), event: .verification(makeVerificationEvent())) {
            
            $0.verification = verificationState
        }
    }
    
    func test_verification_shouldDeliverVerificationReduceEffect() {
        
        let verificationEffect = makeVerificationEffect()
        let (sut, _,_) = makeSUT(verificationStub: (makeVerification(), verificationEffect))
        
        assert(sut: sut, makeState(), event: .verification(makeVerificationEvent()), delivers: .verification(verificationEffect))
    }
    
    func test_verification_shouldDeliverVerificationReduceNilEffect() {
        
        let (sut, _,_) = makeSUT(verificationStub: (makeVerification(), nil))
        
        assert(sut: sut, makeState(), event: .verification(makeVerificationEvent()), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = DraftReducer<Consent, ConsentEvent, Content, Verification, VerificationEvent, VerificationEffect>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias ConsentSpy = CallSpy<(Consent, ConsentEvent), (Consent, Never?)>
    private typealias VerificationSpy = CallSpy<(Verification, VerificationEvent), (Verification, VerificationEffect?)>
    
    private func makeSUT(
        consentStub: Consent? = nil,
        verificationStub: (Verification, VerificationEffect?)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        consentSpy: ConsentSpy,
        verification: VerificationSpy
    ) {
        let consent = ConsentSpy(stubs: [
            (consentStub ?? makeConsent(), nil)
        ])
        let verification = VerificationSpy(stubs: [
            verificationStub ?? (makeVerification(), makeVerificationEffect())
        ])
        let sut = SUT(
            consentReduce: consent.call,
            verificationReduce: verification.call
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(consent, file: file, line: line)
        trackForMemoryLeaks(verification, file: file, line: line)
        
        return (sut, consent, verification)
    }
    
    private func makeState(
        consent: Consent? = nil,
        content: Content? = nil,
        verification: Verification? = nil
    ) -> State {
        
        return .init(
            consent: consent ?? makeConsent(),
            content: content ?? makeContent(),
            verification: verification ?? makeVerification()
        )
    }
    
    private struct Content: Equatable {
        
        let value: String
    }
    
    private func makeContent(
        _ value: String = anyMessage()
    ) -> Content {
        
        return .init(value: value)
    }
    
    private struct Consent: Equatable {
        
        let value: String
    }
    
    private func makeConsent(
        _ value: String = anyMessage()
    ) -> Consent {
        
        return .init(value: value)
    }
    
    private struct ConsentEvent: Equatable {
        
        let value: String
    }
    
    private func makeConsentEvent(
        _ value: String = anyMessage()
    ) -> ConsentEvent {
        
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
