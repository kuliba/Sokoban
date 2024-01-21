//
//  OTPInputBinderIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent
import XCTest

final class OTPInputBinderIntegrationTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallServices() {
        
        let (_,_,_, initiateSpy, submitOTPSpy) = makeSUT()
        
        XCTAssertEqual(initiateSpy.callCount, 0)
        XCTAssertEqual(submitOTPSpy.callCount, 0)
    }
    
    func test_init_shouldStartTimer() {
        
        let (_,_, timerSpy, _,_) = makeSUT()
        
        XCTAssertNoDiff(timerSpy.messages, [.start])
    }
    
    func test_init_shouldCallStopTimerOnComplete() {
        
        let initialOTPInputState = completed()
        let (_,_, timerSpy, _,_) = makeSUT(
            initialOTPInputState: initialOTPInputState
        )
        
        XCTAssertNoDiff(timerSpy.messages, [.stop])
    }
    
    // MARK: - flow
    
    func test_initiateFailureFlow() {
        
        let (binder, sut, timerSpy, initiateSpy, submitOTPSpy) = makeSUT(initialOTPInputState: completed())
        let stateSpy = ValueSpy(sut.$state)
        
        sut.event(prepare())
        initiateSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .failure(.connectivityError)
        ])
        
        XCTAssertNotNil(binder)
    }
    
    func test_submitOTPFailureFlow() {
        
        let (binder, sut, timerSpy, initiateSpy, submitOTPSpy) = makeSUT(initialOTPInputState: completed())
        let stateSpy = ValueSpy(sut.$state)
        
        sut.event(prepare())
        initiateSpy.complete(with: .success(()))
        timerSpy.tick()
        timerSpy.tick()
        sut.event(.otpField(.edit("12345")))
        sut.event(.otpField(.confirmOTP))
        sut.event(.otpField(.edit("654321")))
        sut.event(.otpField(.confirmOTP))
        submitOTPSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting,
            running(59),
            running(58),
            running(58, otpField: text("12345")),
            running(58, otpField: completed("654321")),
            runningInflight(58, "654321"),
            .failure(.connectivityError)
        ])
        
        XCTAssertNotNil(binder)
    }
    
    func test_successFlow() {
        
        let (binder, sut, timerSpy, initiateSpy, submitOTPSpy) = makeSUT(initialOTPInputState: completed())
        let stateSpy = ValueSpy(sut.$state)
        
        XCTAssertNoDiff(stateSpy.values, [completed()])
        
        sut.event(prepare())
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
        ])
        
        initiateSpy.complete(with: .success(()))
        timerSpy.tick()
        timerSpy.tick()
        timerSpy.tick()
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting,
            running(59),
            running(58),
            running(57),
        ])
        
        sut.event(.otpField(.edit("12345")))
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting,
            running(59),
            running(58),
            running(57),
            running(57, otpField: text("12345")),
        ])
        
        sut.event(.otpField(.confirmOTP))
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting,
            running(59),
            running(58),
            running(57),
            running(57, otpField: text("12345")),
        ])
        
        sut.event(.otpField(.edit("654321")))
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting,
            running(59),
            running(58),
            running(57),
            running(57, otpField: text("12345")),
            running(57, otpField: completed("654321")),
        ])
        
        sut.event(.otpField(.confirmOTP))
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting,
            running(59),
            running(58),
            running(57),
            running(57, otpField: text("12345")),
            running(57, otpField: completed("654321")),
            runningInflight(57, "654321"),
        ])
        
        submitOTPSpy.complete(with: .success(()))
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting,
            running(59),
            running(58),
            running(57),
            running(57, otpField: text("12345")),
            running(57, otpField: completed("654321")),
            runningInflight(57, "654321"),
            .validOTP
        ])
        
        XCTAssertNotNil(binder)
    }
    
    // MARK: - Helpers
    
    private typealias Binder = OTPInputBinder
    private typealias SUT = OTPInputViewModel
    
    private typealias InitiateSpy = Spy<Void, CountdownEffectHandler.InitiateResult>
    private typealias SubmitOTPSpy = Spy<OTPFieldEffectHandler.SubmitOTPPayload, OTPFieldEffectHandler.SubmitOTPResult>
    
    private func makeSUT(
        duration: Int = 55,
        length: Int = 6,
        initialOTPInputState: OTPInputState = .starting,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        binder: Binder,
        sut: SUT,
        timerSpy: TimerSpy,
        initiateSpy: InitiateSpy,
        submitOTPSpy: SubmitOTPSpy
    ) {
        let timerSpy = TimerSpy(duration: duration)
        let initiateSpy = InitiateSpy()
        let submitOTPSpy = SubmitOTPSpy()
        let sut: SUT = .default(
            initialOTPInputState: initialOTPInputState,
            timer: timerSpy,
            initiate: initiateSpy.process(completion:),
            submitOTP: submitOTPSpy.process(_:completion:),
            scheduler: .immediate
        )
        let binder = Binder(
            timer: timerSpy,
            duration: duration,
            otpInputViewModel: sut,
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(binder, file: file, line: line)
        trackForMemoryLeaks(timerSpy, file: file, line: line)
        trackForMemoryLeaks(initiateSpy, file: file, line: line)
        trackForMemoryLeaks(submitOTPSpy, file: file, line: line)
        
        return (binder, sut, timerSpy, initiateSpy, submitOTPSpy)
    }
    
    private func completed(
        otpField: OTPFieldState = .init()
    ) -> OTPInputState {
        
        .input(.init(
            countdown: .completed,
            otpField: otpField
        ))
    }
    
    private func running(
        _ remaining: Int,
        otpField: OTPFieldState = .init()
    ) -> OTPInputState {
        
        .input(.init(
            countdown: .running(remaining: remaining),
            otpField: otpField
        ))
    }
    
    private func runningInflight(
        _ remaining: Int,
        _ text: String
    ) -> OTPInputState {
        
        .input(.init(
            countdown: .running(remaining: remaining),
            otpField: .init(
                text: text,
                isInputComplete: true,
                status: .inflight
            )
        ))
    }
    
    private func text(
        _ text: String
    ) -> OTPFieldState {
        
        .init(text: text)
    }
    
    private func completed(
        _ text: String
    ) -> OTPFieldState {
        
        .init(text: text, isInputComplete: true)
    }
    
    private func inflight(
        _ text: String
    ) -> OTPFieldState {
        
        .init(text: text, isInputComplete: true, status: .inflight)
    }
    
    private func validOTP(
        _ text: String
    ) -> OTPFieldState {
        
        .init(text: text, isInputComplete: true, status: .validOTP)
    }
    
    private func prepare(
    ) -> OTPInputEvent {
        
        .countdown(.prepare)
    }
}
