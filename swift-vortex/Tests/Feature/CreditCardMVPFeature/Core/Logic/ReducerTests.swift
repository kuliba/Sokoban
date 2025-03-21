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
    case notifyOTP(OTP, String)
}

extension Effect: Equatable where OTP: Equatable, ConfirmApplicationPayload: Equatable {}

final class Reducer<ApplicationSuccess, ConfirmApplicationPayload, OTP> {}

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
    
    func test_applicationResult_shouldChangeState_onAlertFailure() {
        
        let state = makeState(otp: makeOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event) {
            
            $0.applicationResult = .failure(.init(message: message, type: .alert))
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onAlertFailure() {
        
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
    
    func test_applicationResult_shouldChangeState_onInformerFailure() {
        
        let state = makeState(otp: makeOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event) {
            
            $0.applicationResult = .failure(.init(message: message, type: .informer))
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onInformerFailure() {
        
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
    
    func test_applicationResult_shouldNotChangeState_onOTPFailure() {
        
        let otp = makeOTP()
        let state = makeState(otp: otp)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event)
    }
    
    func test_applicationResult_shouldDeliverEffect_onOTPFailure() {
        
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
    
    func test_applicationResult_shouldChangeState_onSuccess() {
        
        let state = makeState(otp: makeOTP())
        let success = makeApplicationSuccess()
        let event = makeApplicationResultSuccess(success: success)
        
        assert(state, event: event) {
            
            $0.applicationResult = .success(success)
        }
    }
    
    func test_applicationResult_shouldNotDeliverEffect_onSuccess() {
        
        let state = makeState(otp: makeOTP())
        let event = makeApplicationResultSuccess()
        
        assert(state, event: event, delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Reducer<ApplicationSuccess, ConfirmApplicationPayload, OTP>
    private typealias State = CreditCardMVPCoreTests.State<ApplicationSuccess, OTP>
    private typealias Effect = CreditCardMVPCoreTests.Effect<ConfirmApplicationPayload, OTP>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
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
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
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
