//
//  CodeInputReducerTests.swift
//
//
//  Created by Дмитрий Савушкин on 13.06.2024.
//

import OTPInputComponent
import RxViewModel
import XCTest

extension CodeInputReducer: Reducer {}

final class CodeInputReducerTests: XCTestCase {
    
    // MARK: - CountdownEvent
    
    func test_countdownEvent_shouldDeliverCountdownReduceState() {
        
        var input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            countdownReducerStub: (running(5), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state) {
            input.countdown = .running(remaining: 5)
            $0 = .input(input)
        }
    }
    
    func test_countdownEvent_shouldDeliverCountdownReduceEffect() {
        
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            countdownReducerStub: (running(5), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state, effect: .countdown(.initiate))
    }
    
    func test_countdownEvent_shouldDeliverConnectivityFailureOnCountdownConnectivityFailure() {
        
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            countdownReducerStub: (connectivityError(), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state) {
            $0 = .failure(.connectivityError)
        }
    }
    
    func test_countdownEvent_shouldDeliverCountdownReduceEffectOnCountdownConnectivityFailure() {
        
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            countdownReducerStub: (connectivityError(), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state, effect: .countdown(.initiate))
    }
    
    func test_countdownEvent_shouldDeliverServerFailureOnCountdownServerFailure() {
        
        let message = anyMessage()
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            countdownReducerStub: (serverError(message), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state) {
            $0 = .failure(.serverError(message))
        }
    }
    
    func test_countdownEvent_shouldDeliverCountdownReduceEffectOnCountdownServerFailure() {
        
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            countdownReducerStub: (connectivityError(), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state, effect: .countdown(.initiate))
    }
    
    func test_countdownEvent_shouldNotChangeStateOnFailure() {
        
        let state = makeState(.failure(.connectivityError))
        let sut = makeSUT(
            countdownReducerStub: (running(55), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state)
    }
    
    func test_countdownEvent_shouldNotDeliverCountdownReduceEffectOnFailure() {
        
        let state = makeState(.failure(.connectivityError))
        let sut = makeSUT(
            countdownReducerStub: (connectivityError(), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state, effect: nil)
    }
    
    func test_countdownEvent_shouldNotChangeStateOnValidOTP() {
        
        let state = makeState(.validOTP)
        let sut = makeSUT(
            countdownReducerStub: (running(55), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state)
    }
    
    func test_countdownEvent_shouldNotDeliverCountdownReduceEffectOnValidOTP() {
        
        let state = makeState(.validOTP)
        let sut = makeSUT(
            countdownReducerStub: (connectivityError(), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state, effect: nil)
    }
    
    // MARK: - OTPFieldEvent
    
    func test_otpFieldEvent_shouldDeliverOTPFieldReduceState() {
        
        var input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            otpFieldReducerStub: (.init(text: "12345"), .submitOTP("abcde"))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state) {
            input.otpField = .init(text: "12345")
            $0 = .input(input)
        }
    }
    
    func test_otpFieldEvent_shouldDeliverOTPFieldReduceEffect() {
        
        let message = anyMessage()
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            otpFieldReducerStub: (.init(), .submitOTP(message))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state, effect: submitOTP(message))
    }
    
    func test_otpFieldEvent_shouldDeliverConnectivityFailureOnCountdownConnectivityFailure() {
        
        let message = anyMessage()
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            otpFieldReducerStub: (connectivity(), .submitOTP(message))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state) {
            $0 = .failure(.connectivityError)
        }
    }
    
    func test_otpFieldEvent_shouldDeliverCountdownReduceEffectOnCountdownConnectivityFailure() {
        
        let message = anyMessage()
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            otpFieldReducerStub: (connectivity(), .submitOTP(message))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state, effect: submitOTP(message))
    }
    
    func test_otpFieldEvent_shouldDeliverServerFailureOnCountdownServerFailure() {
        
        let message = anyMessage()
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            otpFieldReducerStub: (server(message), .submitOTP(message))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state) {
            $0 = .failure(.serverError(message))
        }
    }
    
    func test_otpFieldEvent_shouldDeliverCountdownReduceEffectOnCountdownServerFailure() {
        
        let message = anyMessage()
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            otpFieldReducerStub: (server(message), .init(.submitOTP(message)))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state, effect: submitOTP(message))
    }
    
    func test_otpFieldEvent_shouldChangeStateToValidOTPOnCountdownValidOTP() {
        
        let message = anyMessage()
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            otpFieldReducerStub: (validOTP(), .submitOTP(message))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state) {
            $0 = .validOTP
        }
    }
    
    func test_otpFieldEvent_shouldDeliverCountdownReduceEffectOnCountdownValidOTP() {
        
        let message = anyMessage()
        let input = makeInput(countdown: .completed, otpField: .init())
        let state = makeState(.input(input))
        let sut = makeSUT(
            otpFieldReducerStub: (validOTP(), .init(.submitOTP(message)))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state, effect: submitOTP(message))
    }
    
    func test_otpFieldEvent_shouldNotChangeStateOnFailure() {
        
        let state = makeState(.failure(.connectivityError))
        let sut = makeSUT(
            otpFieldReducerStub: (.init(), .submitOTP(anyMessage()))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state)
    }
    
    func test_otpFieldEvent_shouldNotDeliverCountdownReduceEffectOnFailure() {
        
        let state = makeState(.failure(.connectivityError))
        let sut = makeSUT(
            otpFieldReducerStub: (.init(), .submitOTP(anyMessage()))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state, effect: nil)
    }
    
    func test_otpFieldEvent_shouldNotChangeStateOnValidOTP() {
        
        let state = makeState(.validOTP)
        let sut = makeSUT(
            otpFieldReducerStub: (.init(), .submitOTP(anyMessage()))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state)
    }
    
    func test_otpFieldEvent_shouldNotDeliverCountdownReduceEffectOnValidOTP() {
        
        let state = makeState(.validOTP)
        let sut = makeSUT(
            otpFieldReducerStub: (.init(), .submitOTP(anyMessage()))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CodeInputReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias CountdownReducerSpy = ReducerSpy<CountdownState, CountdownEvent, CountdownEffect>
    private typealias OTPFieldReducerSpy = ReducerSpy<OTPFieldState, OTPFieldEvent, OTPFieldEffect>
    
    private typealias CountdownReducerStub = (CountdownState, CountdownEffect?)
    private typealias OTPFieldReducerStub = (OTPFieldState, OTPFieldEffect?)
    
    private func makeSUT(
        countdownReducerStub: CountdownReducerStub...,
        otpFieldReducerStub: OTPFieldReducerStub...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let countdownReducer = CountdownReducerSpy(stub: countdownReducerStub)
        let otpFieldReducer = OTPFieldReducerSpy(stub: otpFieldReducerStub)
        
        let sut = SUT(
            countdownReduce: countdownReducer.reduce(_:_:),
            otpFieldReduce: otpFieldReducer.reduce(_:_:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: ((_ state: inout State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        _assertState(
            sut,
            event,
            on: state,
            updateStateToExpected: updateStateToExpected,
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
    
    private func makeInput(
        countdown: CountdownState,
        otpField: OTPFieldState
    ) -> CodeInputState.Status.Input {
        
        .init(
            countdown: .completed,
            otpField: .init()
        )
    }
}

private func makeState(
    _ status: CodeInputState.Status
) -> CodeInputReducer.State {
    
    status
}
