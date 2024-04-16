//
//  TimedOTPInputViewModelIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent
import XCTest

final class TimedOTPInputViewModelIntegrationTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_,_, initiateOTPSpy, submitOTPSpy) = makeSUT()
        
        XCTAssertEqual(initiateOTPSpy.callCount, 0)
        XCTAssertEqual(submitOTPSpy.callCount, 0)
    }
    
    func test_init_shouldCallTimerWithStopOnCompleted() {
        
        let (_,_, timerSpy, _,_) = makeSUT(
            initialState: completed()
        )
        
        XCTAssertNoDiff(timerSpy.messages, [.stop])
    }
    
    // MARK: - flow
    
    func test_initiateFailureFlow() {
        
        let (sut, stateSpy, _, initiateOTPSpy, _) = makeSUT()
        
        sut.event(prepare())
        initiateOTPSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(stateSpy.values.map(\.status), [
            completed(),
            .failure(.connectivityError)
        ])
        
        XCTAssertNotNil(sut)
    }
    
    func test_submitOTPFailureFlow() {
        
        let duration = 33
        let (sut, stateSpy, timerSpy, initiateOTPSpy, submitOTPSpy) = makeSUT(duration: duration)
        
        sut.event(prepare())
        initiateOTPSpy.complete(with: .success(()))
        timerSpy.tick()
        timerSpy.tick()
        sut.event(.otpField(.edit("12345")))
        sut.event(.otpField(.confirmOTP))
        sut.event(.otpField(.edit("654321")))
        sut.event(.otpField(.confirmOTP))
        submitOTPSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(stateSpy.values.map(\.status), [
            completed(),
            starting(duration),
            running(32),
            running(31),
            running(31, otpField: text("12345")),
            running(31, otpField: completed("654321")),
            runningInflight(31, "654321"),
            .failure(.connectivityError)
        ])
        
        XCTAssertNotNil(sut)
    }
    
    func test_successFlow() {
        
        let duration = 33
        let (sut, stateSpy, timerSpy, initiateOTPSpy, submitOTPSpy) = makeSUT(duration: duration)
        
        sut.event(prepare())
        initiateOTPSpy.complete(with: .success(()))
        timerSpy.tick()
        timerSpy.tick()
        timerSpy.tick()
        sut.event(.otpField(.edit("12345")))
        sut.event(.otpField(.confirmOTP))
        sut.event(.otpField(.edit("654321")))
        sut.event(.otpField(.confirmOTP))
        submitOTPSpy.complete(with: .success(()))
        
        XCTAssertNoDiff(stateSpy.values.map(\.status), [
            completed(),
            starting(duration),
            running(32),
            running(31),
            running(30),
            running(30, otpField: text("12345")),
            running(30, otpField: completed("654321")),
            runningInflight(30, "654321"),
            .validOTP
        ])
        
        XCTAssertNotNil(sut)
    }
    
    #warning("add similar tests for reducer")
    func test_confirmOTP_shouldNotFireTwice() {
        
        let duration = 33
        let (sut, stateSpy, timerSpy, initiateOTPSpy, submitOTPSpy) = makeSUT(duration: duration)
        
        sut.event(prepare())
        initiateOTPSpy.complete(with: .success(()))
        timerSpy.tick()
        sut.event(.otpField(.edit("654321")))
        sut.event(.otpField(.confirmOTP))
        sut.event(.otpField(.confirmOTP))
        submitOTPSpy.complete(with: .success(()))
        
        XCTAssertNoDiff(stateSpy.values.map(\.status), [
            completed(),
            starting(duration),
            running(32),
            running(32, otpField: completed("654321")),
            runningInflight(32, "654321"),
            .validOTP
        ])
        
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TimedOTPInputViewModel
    private typealias State = OTPInputState
    private typealias Event = OTPInputEvent
    private typealias Effect = OTPInputEffect

    private typealias StateSpy = ValueSpy<State>
    
    private typealias InitiateOTPSpy = Spy<Void, CountdownEffectHandler.InitiateOTPResult>
    private typealias SubmitOTPSpy = Spy<OTPFieldEffectHandler.SubmitOTPPayload, OTPFieldEffectHandler.SubmitOTPResult>

    private func makeSUT(
        duration: Int = 5,
        initialState: OTPInputState? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        timerSpy: TimerSpy,
        initiateOTPSpy: InitiateOTPSpy,
        submitOTPSpy: SubmitOTPSpy
    ) {
        let timerSpy = TimerSpy(duration: duration)
        let initiateOTPSpy = InitiateOTPSpy()
        let submitOTPSpy = SubmitOTPSpy()
        
        let initialState = initialState ?? makeState()
        let otpInputViewModel = OTPInputViewModel.default(
            initialState: initialState,
            duration: duration,
            initiateOTP: initiateOTPSpy.process(completion:),
            submitOTP: submitOTPSpy.process(_:completion:),
            scheduler: .immediate
        )
        let sut = SUT(
            viewModel: otpInputViewModel,
            timer: timerSpy,
            scheduler: .immediate
        )
        let stateSpy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        trackForMemoryLeaks(otpInputViewModel, file: file, line: line)
        trackForMemoryLeaks(timerSpy, file: file, line: line)
        trackForMemoryLeaks(initiateOTPSpy, file: file, line: line)
        trackForMemoryLeaks(submitOTPSpy, file: file, line: line)
        
        return (sut, stateSpy, timerSpy, initiateOTPSpy, submitOTPSpy)
    }
    
    private func makeState(
        phoneNumber: State.PhoneNumberMask = .init(anyMessage()),
        countdown: CountdownState = .completed,
        otpField: OTPFieldState = .init()
    ) -> State {
        
        .init(
            phoneNumber: phoneNumber,
            status: .input(.init(countdown: countdown, otpField: otpField))
        )
    }
}
