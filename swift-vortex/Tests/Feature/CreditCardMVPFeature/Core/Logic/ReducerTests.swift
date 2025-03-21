//
//  ReducerTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

struct LoadFailure: Error, Equatable {
    
    let message: String
    let type: FailureType
    
    enum FailureType {
        
        case alert, informer, otp
    }
}

struct State<OTP> {
    
    let otp: OTP?
}

extension State: Equatable where OTP: Equatable {}

enum Event: Equatable {
    
    case orderResult(OrderResult)
    
    typealias OrderResult = Result<OK, LoadFailure>
    struct OK: Equatable {}
}

enum Effect<OTP> {
    
    case notifyOTP(OTP, String)
}

extension Effect: Equatable where OTP: Equatable {}

final class Reducer<OTP> {}

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
    
    typealias State = CreditCardMVPCoreTests.State<OTP>
    typealias Event = CreditCardMVPCoreTests.Event
    typealias Effect = CreditCardMVPCoreTests.Effect<OTP>
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
                break
            case .informer:
                break
            case .otp:
                effect = state.otp.map { .notifyOTP($0, failure.message) }
            }
            
        case let .success(success):
            break
        }
    }
}

import XCTest

final class ReducerTests: XCTestCase {
    
    // MARK: - orderResult
    
    func test_orderResult_shouldNotChangeState_onOTPFailure() {
        
        let state = makeState()
        let message = anyMessage()
        let event = makeOrderResultFailure(message: message, type: .otp)
        
        assert(state, event: event)
    }
    
    func test_orderResult_shouldDeliverEffect_onOTPFailure() {
        
        let otp = makeOTP()
        let state = makeState(otp: otp)
        let message = anyMessage()
        let event = makeOrderResultFailure(message: message, type: .otp)
        
        assert(state, event: event, delivers: .notifyOTP(otp, message))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Reducer<OTP>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        otp: OTP? = nil
    ) -> SUT.State {
        
        return .init(otp: otp ?? makeOTP())
    }
    
    private struct OTP: Equatable {
        
        let value: String
    }
    
    private func makeOTP(
        _ value: String = anyMessage()
    ) -> OTP {
        
        return .init(value: value)
    }
    
    private func makeOrderResultFailure(
        message: String = anyMessage(),
        type: LoadFailure.FailureType
    ) -> SUT.Event {
        
        return .orderResult(.failure(.init(
            message: message,
            type: type
        )))
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
