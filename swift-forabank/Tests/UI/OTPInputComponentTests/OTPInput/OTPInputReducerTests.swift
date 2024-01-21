//
//  OTPInputReducerTests.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent
import RxViewModel
import XCTest

extension OTPInputReducer: Reducer {}

final class OTPInputReducerTests: XCTestCase {
    
    // MARK: - CountdownEvent
    
    private func makeInput(
        countdown: CountdownState,
        otpField: OTPFieldState
    ) -> OTPInputState.Input {
        
        .init(
            countdown: .completed,
            otpField: .init()
        )
    }
    
    func test_countdownEvent_shouldDeliverCountdownReduceState() {
        
        var input = makeInput(countdown: .completed, otpField: .init())
        let state: State = .input(input)
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
        let state: State = .input(input)
        let sut = makeSUT(
            countdownReducerStub: (running(5), .init(.initiate))
        )
        
        assert(sut: sut, .countdown(.start), on: state, effect: .countdown(.initiate))
    }
    
    // MARK: - OTPFieldEvent
    
    func test_otpFieldEvent_shouldDeliverOTPFieldReduceState() {
        
        var input = makeInput(countdown: .completed, otpField: .init())
        let state: State = .input(input)
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
        let state: State = .input(input)
        let sut = makeSUT(
            otpFieldReducerStub: (.init(), .submitOTP(message))
        )
        
        assert(sut: sut, .otpField(.confirmOTP), on: state, effect: submitOTP(message))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OTPInputReducer
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
    
}
