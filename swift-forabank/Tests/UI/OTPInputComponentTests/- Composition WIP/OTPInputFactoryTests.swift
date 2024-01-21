//
//  OTPInputFactoryTests.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent
import XCTest

final class OTPInputFactoryTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_,_, initiateSpy, submitOTPSpy) = makeSUT()
        
        XCTAssertEqual(initiateSpy.callCount, 0)
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
        
        let (sut, viewModel, _, initiateSpy, _) = makeSUT()
        let stateSpy = ValueSpy(viewModel.$state)
        
        viewModel.event(prepare())
        initiateSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .failure(.connectivityError)
        ])
        
        XCTAssertNotNil(sut)
    }
    
    func test_submitOTPFailureFlow() {
        
        let duration = 33
        let (sut, viewModel, timerSpy, initiateSpy, submitOTPSpy) = makeSUT(duration: duration)
        let stateSpy = ValueSpy(viewModel.$state)
        
        viewModel.event(prepare())
        initiateSpy.complete(with: .success(()))
        timerSpy.tick()
        timerSpy.tick()
        viewModel.event(.otpField(.edit("12345")))
        viewModel.event(.otpField(.confirmOTP))
        viewModel.event(.otpField(.edit("654321")))
        viewModel.event(.otpField(.confirmOTP))
        submitOTPSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting(duration: duration),
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
        let (sut, viewModel, timerSpy, initiateSpy, submitOTPSpy) = makeSUT(duration: duration)
        let stateSpy = ValueSpy(viewModel.$state)
        
        viewModel.event(prepare())
        initiateSpy.complete(with: .success(()))
        timerSpy.tick()
        timerSpy.tick()
        timerSpy.tick()
        viewModel.event(.otpField(.edit("12345")))
        viewModel.event(.otpField(.confirmOTP))
        viewModel.event(.otpField(.edit("654321")))
        viewModel.event(.otpField(.confirmOTP))
        submitOTPSpy.complete(with: .success(()))
        
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting(duration: duration),
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
    
    // MARK: - Helpers
    
    private typealias SUT = OTPInputFactory
    private typealias State = OTPInputState
    private typealias Event = OTPInputEvent
    private typealias Effect = OTPInputEffect
    
    private typealias InitiateSpy = Spy<Void, CountdownEffectHandler.InitiateResult>
    private typealias SubmitOTPSpy = Spy<OTPFieldEffectHandler.SubmitOTPPayload, OTPFieldEffectHandler.SubmitOTPResult>
    
    private func makeSUT(
        duration: Int = 5,
        length: Int = 6,
        initialState: OTPInputState? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        viewModel: OTPInputViewModel,
        timerSpy: TimerSpy,
        initiateSpy: InitiateSpy,
        submitOTPSpy: SubmitOTPSpy
    ) {
        let (sut, timerSpy, initiateSpy, submitOTPSpy) = makeSUT(
            duration: duration,
            file: file, line: line
        )
        let initialState = initialState ?? makeState()
        let viewModel = sut.make(
            initialOTPInputState: initialState,
            duration: duration,
            otpLength: length,
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(viewModel, file: file, line: line)
        trackForMemoryLeaks(timerSpy, file: file, line: line)
        trackForMemoryLeaks(initiateSpy, file: file, line: line)
        trackForMemoryLeaks(submitOTPSpy, file: file, line: line)
        
        return (sut, viewModel, timerSpy, initiateSpy, submitOTPSpy)
    }
    
    private func makeSUT(
        duration: Int = 5,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        timerSpy: TimerSpy,
        initiateSpy: InitiateSpy,
        submitOTPSpy: SubmitOTPSpy
    ) {
        let timerSpy = TimerSpy(duration: duration)
        let initiateSpy = InitiateSpy()
        let submitOTPSpy = SubmitOTPSpy()
        
        let sut = SUT(
            initiate: initiateSpy.process(completion:),
            submitOTP: submitOTPSpy.process(_:completion:),
            timer: timerSpy
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(timerSpy, file: file, line: line)
        trackForMemoryLeaks(initiateSpy, file: file, line: line)
        trackForMemoryLeaks(submitOTPSpy, file: file, line: line)
        
        return (sut, timerSpy, initiateSpy, submitOTPSpy)
    }
    
    private func makeState(
        countdown: CountdownState = .completed,
        otpField: OTPFieldState = .init()
    ) -> State {
        
        .input(.init(countdown: countdown, otpField: otpField))
    }
}
