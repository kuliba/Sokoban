//
//  ReducerTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

import CreditCardMVPCore
import XCTest

final class ReducerTests: LogicTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, makePayload) = makeSUT()
        
        XCTAssertEqual(makePayload.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - applicationResult: alert failure
    
    func test_applicationResult_shouldChangeState_onAlertFailure_noOTP() {
        
        let state = makeState(otp: .pending)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event) {
            
            $0.applicationResult = .failure(.init(message: message, type: .alert))
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onAlertFailure_noOTP() {
        
        let state = makeState(otp: .pending)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_applicationResult_shouldChangeState_onAlertFailure_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event) {
            
            $0.applicationResult = .failure(.init(message: message, type: .alert))
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onAlertFailure_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event, delivers: nil)
    }
    
    // MARK: - applicationResult: informer failure
    
    func test_applicationResult_shouldChangeState_onInformerFailure_noOTP() {
        
        let state = makeState(otp: .pending)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event) {
            
            $0.applicationResult = .failure(.init(message: message, type: .informer))
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onInformerFailure_noOTP() {
        
        let state = makeState(otp: .pending)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_applicationResult_shouldChangeState_onInformerFailure_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event) {
            
            $0.applicationResult = .failure(.init(message: message, type: .informer))
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onInformerFailure_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event, delivers: nil)
    }
    
    // MARK: - applicationResult: otp failure
    
    func test_applicationResult_shouldNotChangeState_onOTPFailure_noOTP() {
        
        let state = makeState(otp: .pending)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event)
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onOTPFailure_noOTP() {
        
        let state = makeState(otp: .pending)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_applicationResult_shouldNotChangeState_onOTPFailure_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event)
    }
    
    func test_applicationResult_shouldDeliverEffect_onOTPFailure_withOTP() throws {
        
        let otp = presentOTP()
        let state = makeState(otp: otp)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        try assert(state, event: event, delivers: .notifyOTP(XCTUnwrap(otp.success), message))
    }
    
    // MARK: - applicationResult: success
    
    func test_applicationResult_shouldChangeState_onSuccess_noOTP() {
        
        let state = makeState(otp: .pending)
        let success = makeApplicationSuccess()
        let event = makeApplicationResultSuccess(success: success)
        
        assert(state, event: event) {
            
            $0.applicationResult = .success(success)
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onSuccess_noOTP() {
        
        let state = makeState(otp: .pending)
        let event = makeApplicationResultSuccess()
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_applicationResult_shouldChangeState_onSuccess_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let success = makeApplicationSuccess()
        let event = makeApplicationResultSuccess(success: success)
        
        assert(state, event: event) {
            
            $0.applicationResult = .success(success)
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onSuccess_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let event = makeApplicationResultSuccess()
        
        assert(state, event: event, delivers: nil)
    }
    
    // MARK: - continue
    
    func test_continue_shouldNotChangeState_onInvalidState_noOTP() {
        
        let state = makeState(otp: .pending)
        let (sut, _) = makeSUT(isValid: { _ in false })
        
        assert(sut: sut, state, event: .continue)
    }
    
    func test_continue_shouldNotDeliverEffect_onInvalidState_noOTP() {
        
        let state = makeState(otp: .pending)
        let (sut, _) = makeSUT(isValid: { _ in false })
        
        assert(sut: sut, state, event: .continue, delivers: nil)
    }
    
    func test_continue_shouldNotChangeState_onInvalidState_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let (sut, _) = makeSUT(isValid: { _ in false })
        
        assert(sut: sut, state, event: .continue)
    }
    
    func test_continue_shouldNotDeliverEffect_onInvalidState_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let (sut, _) = makeSUT(isValid: { _ in false })
        
        assert(sut: sut, state, event: .continue, delivers: nil)
    }
    
    func test_continue_shouldChangeState_onValidState_noOTP() {
        
        let state = makeState(otp: .pending)
        let (sut, _) = makeSUT(isValid: { _ in true })
        
        assert(sut: sut, state, event: .continue) {
            
            $0.otp = .loading(nil)
        }
    }
    
    func test_continue_shouldDeliverEffect_onValidState_noOTP() {
        
        let state = makeState(otp: .pending)
        let (sut, _) = makeSUT(isValid: { _ in true })
        
        assert(sut: sut, state, event: .continue, delivers: .loadOTP)
    }
    
    func test_continue_shouldNotCallMakePayloadWithState_onValidState_noOTP() {
        
        let state = makeState(otp: .pending)
        let (sut, makePayload) = makeSUT(isValid: { _ in true })
        
        _ = sut.reduce(state, .continue)
        
        XCTAssertEqual(makePayload.callCount, 0)
    }
    
    func test_continue_shouldNotChangeState_onValidState_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let (sut, _) = makeSUT(isValid: { _ in true })
        
        assert(sut: sut, state, event: .continue)
    }
    
    func test_continue_shouldCallMakePayloadWithState_onValidState_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let (sut, makePayload) = makeSUT(isValid: { _ in true })
        
        _ = sut.reduce(state, .continue)
        
        XCTAssertNoDiff(makePayload.payloads, [state])
    }
    
    func test_continue_shouldNotDeliverEffect_onValidState_withOTP() {
        
        let state = makeState(otp: presentOTP())
        let (sut, _) = makeSUT(applicationPayload: nil, isValid: { _ in true })
        
        assert(sut: sut, state, event: .continue, delivers: nil)
    }
    
    func test_continue_shouldDeliverEffect_onValidState_withOTP() {
        
        let payload = makePayload()
        let state = makeState(otp: presentOTP())
        let (sut, _) = makeSUT(applicationPayload: payload, isValid: { _ in true })
        
        assert(sut: sut, state, event: .continue, delivers: .apply(payload))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Reducer<ApplicationPayload, ApplicationSuccess, OTP>
    private typealias State = CreditCardMVPCore.State<ApplicationSuccess, OTP>
    private typealias Event = CreditCardMVPCore.Event<ApplicationSuccess, OTP>
    private typealias Effect = CreditCardMVPCore.Effect<ApplicationPayload, OTP>
    private typealias MakePayloadSpy = CallSpy<State, ApplicationPayload?>
    
    private func makeSUT(
        applicationPayload: ApplicationPayload? = nil,
        isValid: @escaping (State) -> Bool = { _ in false },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makePayload: MakePayloadSpy
    ) {
        let makePayload = MakePayloadSpy(stubs: [applicationPayload])
        
        let sut = SUT(
            isValid: isValid,
            makeApplicationPayload: makePayload.call
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makePayload, file: file, line: line)
        
        return (sut, makePayload)
    }
    
    private struct OTP: Equatable {
        
        let value: String
    }
    
    private func makeOTP(
        _ value: String = anyMessage()
    ) -> OTP {
        
        return .init(value: value)
    }
    
    private func presentOTP(
        _ value: String = anyMessage()
    ) -> State.OTPState {
        
        return .completed(.init(value: value))
    }
    
    private func makeState(
        applicationResult: State.ApplicationResult? = nil,
        otp: State.OTPState
    ) -> State {
        
        return .init(applicationResult: applicationResult, otp: otp)
    }
    
    private func makeApplicationResultFailure(
        message: String = anyMessage(),
        type: Event.ApplicationFailure
    ) -> Event {
        
        return .applicationResult(.failure(.init(
            message: message,
            type: type
        )))
    }
    
    private func makeApplicationResultSuccess(
        success: ApplicationSuccess? = nil
    ) -> Event {
        
        return .applicationResult(.success(success ?? makeApplicationSuccess()))
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
