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
    var orderResult: OrderResult?
}

extension State {
    
    typealias OrderResult = Result<ApplicationSuccess, LoadFailure<FailureType>>
    
    enum FailureType {
        
        case alert, informer
    }
}

extension State: Equatable where ApplicationSuccess: Equatable, OTP: Equatable {}

enum Event<ApplicationSuccess> {
    
    case orderResult(OrderResult)
}

extension Event {
    
    typealias OrderResult = Result<ApplicationSuccess, LoadFailure<FailureType>>
    
    enum FailureType {
        
        case alert, informer, otp
    }
}

extension Event: Equatable where ApplicationSuccess: Equatable {}

enum Effect<OTP, ConfirmApplicationPayload> {
    
    case confirmApplication(ConfirmApplicationPayload)
    case notifyOTP(OTP, String)
}

extension Effect: Equatable where OTP: Equatable, ConfirmApplicationPayload: Equatable {}

final class Reducer<ApplicationSuccess, OTP, ConfirmApplicationPayload> {}

extension Reducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .orderResult(orderResult):
            reduce(&state, &effect, orderResult)
        }
        
        return (state, effect)
    }
}

extension Reducer {
    
    typealias State = CreditCardMVPCoreTests.State<ApplicationSuccess, OTP>
    typealias Event = CreditCardMVPCoreTests.Event<ApplicationSuccess>
    typealias Effect = CreditCardMVPCoreTests.Effect<OTP, ConfirmApplicationPayload>
}

private extension Reducer {
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        _ orderResult: Event.OrderResult
    ) {
        switch orderResult {
        case let .failure(failure):
            switch failure.type {
            case .alert:
                state.orderResult = .failure(.init(
                    message: failure.message,
                    type: .alert
                ))
                
            case .informer:
                state.orderResult = .failure(.init(
                    message: failure.message,
                    type: .informer
                ))
                
            case .otp:
                effect = state.otp.map { .notifyOTP($0, failure.message) }
            }
            
        case let .success(success):
            state.orderResult = .success(success)
        }
    }
}

import XCTest

final class ReducerTests: LogicTests {
    
    // MARK: - orderResult: alert failure
    
    func test_orderResult_shouldChangeState_onAlertFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event) {
            
            $0.orderResult = .failure(.init(message: message, type: .alert))
        }
    }
    
    func test_orderResult_shouldNotDeliverEffect_onAlertFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_orderResult_shouldChangeState_onAlertFailure() {
        
        let state = makeState(otp: makeOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event) {
            
            $0.orderResult = .failure(.init(message: message, type: .alert))
        }
    }
    
    func test_orderResult_shouldNotDeliverEffect_onAlertFailure() {
        
        let state = makeState(otp: makeOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .alert)
        
        assert(state, event: event, delivers: nil)
    }
    
    // MARK: - orderResult: informer failure
    
    func test_orderResult_shouldChangeState_onInformerFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event) {
            
            $0.orderResult = .failure(.init(message: message, type: .informer))
        }
    }
    
    func test_orderResult_shouldNotDeliverEffect_onInformerFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_orderResult_shouldChangeState_onInformerFailure() {
        
        let state = makeState(otp: makeOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event) {
            
            $0.orderResult = .failure(.init(message: message, type: .informer))
        }
    }
    
    func test_orderResult_shouldNotDeliverEffect_onInformerFailure() {
        
        let state = makeState(otp: makeOTP())
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .informer)
        
        assert(state, event: event, delivers: nil)
    }
    
    // MARK: - orderResult: otp failure
    
    func test_orderResult_shouldNotChangeState_onOTPFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event)
    }
    
    func test_orderResult_shouldNotDeliverEffect_onOTPFailure_noOTP() {
        
        let state = makeState(otp: nil)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_orderResult_shouldNotChangeState_onOTPFailure() {
        
        let otp = makeOTP()
        let state = makeState(otp: otp)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event)
    }
    
    func test_orderResult_shouldDeliverEffect_onOTPFailure() {
        
        let otp = makeOTP()
        let state = makeState(otp: otp)
        let message = anyMessage()
        let event = makeApplicationResultFailure(message: message, type: .otp)
        
        assert(state, event: event, delivers: .notifyOTP(otp, message))
    }
    
    // MARK: - orderResult: success
    
    func test_orderResult_shouldChangeState_onSuccess_noOTP() {
        
        let state = makeState(otp: nil)
        let success = makeApplicationSuccess()
        let event = makeApplicationResultSuccess(orderSuccess: success)
        
        assert(state, event: event) {
            
            $0.orderResult = .success(success)
        }
    }
    
    func test_orderResult_shouldNotDeliverEffect_onSuccess_noOTP() {
        
        let state = makeState(otp: nil)
        let event = makeApplicationResultSuccess()
        
        assert(state, event: event, delivers: nil)
    }
    
    func test_orderResult_shouldChangeState_onSuccess() {
        
        let state = makeState(otp: makeOTP())
        let success = makeApplicationSuccess()
        let event = makeApplicationResultSuccess(orderSuccess: success)
        
        assert(state, event: event) {
            
            $0.orderResult = .success(success)
        }
    }
    
    func test_orderResult_shouldNotDeliverEffect_onSuccess() {
        
        let state = makeState(otp: makeOTP())
        let event = makeApplicationResultSuccess()
        
        assert(state, event: event, delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Reducer<ApplicationSuccess, OTP, ConfirmApplicationPayload>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        otp: OTP? = nil,
        orderResult: SUT.State.OrderResult? = nil
    ) -> SUT.State {
        
        return .init(otp: otp, orderResult: orderResult)
    }
    
    private struct OTP: Equatable {
        
        let value: String
    }
    
    private func makeOTP(
        _ value: String = anyMessage()
    ) -> OTP {
        
        return .init(value: value)
    }
    
    private func makeApplicationResultFailure(
        message: String = anyMessage(),
        type: SUT.Event.FailureType
    ) -> SUT.Event {
        
        return .orderResult(.failure(.init(
            message: message,
            type: type
        )))
    }
    
    private func makeApplicationResultSuccess(
        orderSuccess: ApplicationSuccess? = nil
    ) -> SUT.Event {
        
        return .orderResult(.success(orderSuccess ?? makeApplicationSuccess()))
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
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
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let (_, receivedEffect): (SUT.State, SUT.Effect?) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
