//
//  ReducerTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

struct LoadFailure<FailureType>: Error {
    
    let message: String
    let type: FailureType
}

extension LoadFailure: Equatable where FailureType: Equatable {}

struct State<ApplicationSuccess, OTP> {
    
    let otp: OTP?
    var applicationResult: ApplicationResult?
}

extension State {
    
    typealias ApplicationResult = Result<ApplicationSuccess, LoadFailure<FailureType>>
    
    enum FailureType {
        
        case alert, informer
    }
}

extension State: Equatable where ApplicationSuccess: Equatable, OTP: Equatable {}

enum Event<ApplicationSuccess> {
    
    case applicationResult(ApplicationResult)
    case `continue`
}

extension Event {
    
    typealias ApplicationResult = Result<ApplicationSuccess, LoadFailure<FailureType>>
    
    enum FailureType {
        
        case alert, informer, otp
    }
}

extension Event: Equatable where ApplicationSuccess: Equatable {}

enum Effect<ConfirmApplicationPayload, OTP> {
    
    case confirmApplication(ConfirmApplicationPayload)
    case loadOTP
    case notifyOTP(OTP, String)
}

extension Effect: Equatable where OTP: Equatable, ConfirmApplicationPayload: Equatable {}

final class Reducer<ApplicationSuccess, ConfirmApplicationPayload, OTP> {
    
    private let isValid: IsValid
    private let makeApplicationPayload: MakeApplicationPayload
    
    init(
        isValid: @escaping IsValid,
        makeApplicationPayload: @escaping MakeApplicationPayload
    ) {
        self.isValid = isValid
        self.makeApplicationPayload = makeApplicationPayload
    }
    
    typealias IsValid = (State) -> Bool
    typealias MakeApplicationPayload = (State) -> ConfirmApplicationPayload?
}

extension Reducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .applicationResult(applicationResult):
            reduce(&state, &effect, applicationResult)
            
        case .continue:
            reduceContinue(&state, &effect)
        }
        
        return (state, effect)
    }
}

extension Reducer {
    
    typealias State = CreditCardMVPCoreTests.State<ApplicationSuccess, OTP>
    typealias Event = CreditCardMVPCoreTests.Event<ApplicationSuccess>
    typealias Effect = CreditCardMVPCoreTests.Effect<ConfirmApplicationPayload, OTP>
}

private extension Reducer {
    
    func reduceContinue(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        guard isValid(state) else { return }
        
        effect = state.otp == nil ? .loadOTP : makeApplicationPayload(state).map { .confirmApplication($0) }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        _ applicationResult: Event.ApplicationResult
    ) {
        switch applicationResult {
        case let .failure(failure):
            switch failure.type {
            case .alert:
                state.applicationResult = .failure(.init(
                    message: failure.message,
                    type: .alert
                ))
                
            case .informer:
                state.applicationResult = .failure(.init(
                    message: failure.message,
                    type: .informer
                ))
                
            case .otp:
                effect = state.otp.map { .notifyOTP($0, failure.message) }
            }
            
        case let .success(success):
            state.applicationResult = .success(success)
        }
    }
}

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
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event) {
            
            $0.applicationResult = .failure(.init(message: message, type: .alert))
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onAlertFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_applicationResult_shouldChangeState_onAlertFailure_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event) {
            
            $0.applicationResult = .failure(.init(message: message, type: .alert))
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onAlertFailure_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event, delivers: nil)
    }
    
    // MARK: - applicationResult: informer failure
    
    func test_applicationResult_shouldChangeState_onInformerFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event) {
            
            $0.applicationResult = .failure(.init(message: message, type: .informer))
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onInformerFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_applicationResult_shouldChangeState_onInformerFailure_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event) {
            
            $0.applicationResult = .failure(.init(message: message, type: .informer))
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onInformerFailure_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event, delivers: nil)
    }
    
    // MARK: - applicationResult: otp failure
    
    func test_applicationResult_shouldNotChangeState_onOTPFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event)
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onOTPFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_applicationResult_shouldNotChangeState_onOTPFailure_withOTP() {
        
        let otp = makeOTP()
        let state = makeState(otp: otp)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event)
    }
    
    func test_applicationResult_shouldDeliverEffect_onOTPFailure_withOTP() {
        
        let otp = makeOTP()
        let state = makeState(otp: otp)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event, delivers: .notifyOTP(otp, message))
    }
    
    // MARK: - applicationResult: success
    
    func test_applicationResult_shouldChangeState_onSuccess_noOTP() {
        
        let state = makeState(otp: nil)
        let success = makeApplicationSuccess()
        let event = makeApplicationResultSuccess(success: success)
        
        assert(state, event: event) {
            
            $0.applicationResult = .success(success)
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onSuccess_noOTP() {
        
        let state = makeState(otp: nil)
        let event = makeApplicationResultSuccess()
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_applicationResult_shouldChangeState_onSuccess_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let success = makeApplicationSuccess()
        let event = makeApplicationResultSuccess(success: success)
        
        assert(state, event: event) {
            
            $0.applicationResult = .success(success)
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onSuccess_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let event = makeApplicationResultSuccess()
        
        assert(state, event: event, delivers: nil)
    }
    
    // MARK: - continue
    
    func test_continue_shouldNotChangeState_onInvalidState_noOTP() {
        
        let state = makeState(otp: nil)
        let (sut, _) = makeSUT(isValid: { _ in false })
        
        assert(sut: sut, state, event: .continue)
    }
    
    func test_continue_shouldNotDeliverEffect_onInvalidState_noOTP() {
        
        let state = makeState(otp: nil)
        let (sut, _) = makeSUT(isValid: { _ in false })
        
        assert(sut: sut, state, event: .continue, delivers: nil)
    }
    
    func test_continue_shouldNotChangeState_onInvalidState_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let (sut, _) = makeSUT(isValid: { _ in false })
        
        assert(sut: sut, state, event: .continue)
    }
    
    func test_continue_shouldNotDeliverEffect_onInvalidState_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let (sut, _) = makeSUT(isValid: { _ in false })
        
        assert(sut: sut, state, event: .continue, delivers: nil)
    }
    
    func test_continue_shouldNotChangeState_onValidState_noOTP() {
        
        let state = makeState(otp: nil)
        let (sut, _) = makeSUT(isValid: { _ in true })
        
        assert(sut: sut, state, event: .continue)
    }
    
    func test_continue_shouldDeliverEffect_onValidState_noOTP() {
        
        let state = makeState(otp: nil)
        let (sut, _) = makeSUT(isValid: { _ in true })
        
        assert(sut: sut, state, event: .continue, delivers: .loadOTP)
    }
    
    func test_continue_shouldNotCallMakePayloadWithState_onValidState_noOTP() {
        
        let state = makeState(otp: nil)
        let (sut, makePayload) = makeSUT(isValid: { _ in true })
        
        _ = sut.reduce(state, .continue)
        
        XCTAssertEqual(makePayload.callCount, 0)
    }
    
    func test_continue_shouldNotChangeState_onValidState_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let (sut, _) = makeSUT(isValid: { _ in true })
        
        assert(sut: sut, state, event: .continue)
    }
    
    func test_continue_shouldCallMakePayloadWithState_onValidState_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let (sut, makePayload) = makeSUT(isValid: { _ in true })
        
        _ = sut.reduce(state, .continue)
        
        XCTAssertNoDiff(makePayload.payloads, [state])
    }
    
    func test_continue_shouldNotDeliverEffect_onValidState_withOTP() {
        
        let state = makeState(otp: makeOTP())
        let (sut, _) = makeSUT(applicationPayload: nil, isValid: { _ in true })
        
        assert(sut: sut, state, event: .continue, delivers: nil)
    }
    
    func test_continue_shouldDeliverEffect_onValidState_withOTP() {
        
        let payload = makePayload()
        let state = makeState(otp: makeOTP())
        let (sut, _) = makeSUT(applicationPayload: payload, isValid: { _ in true })
        
        assert(sut: sut, state, event: .continue, delivers: .confirmApplication(payload))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Reducer<ApplicationSuccess, ConfirmApplicationPayload, OTP>
    private typealias State = CreditCardMVPCoreTests.State<ApplicationSuccess, OTP>
    private typealias Effect = CreditCardMVPCoreTests.Effect<ConfirmApplicationPayload, OTP>
    private typealias MakePayloadSpy = CallSpy<State, ConfirmApplicationPayload?>
    
    private func makeSUT(
        applicationPayload: ConfirmApplicationPayload? = nil,
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
    
    private func makeState(
        otp: OTP? = nil,
        applicationResult: State.ApplicationResult? = nil
    ) -> State {
        
        return .init(otp: otp, applicationResult: applicationResult)
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
