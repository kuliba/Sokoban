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
    
    // MARK: - flows
    
    func test_initiateFailureFlow() {
        
        let (binder, sut, _, initiateSpy, _) = makeSUT(initialOTPInputState: completed())
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
        
        let duration = 33
        let (binder, sut, timerSpy, initiateSpy, submitOTPSpy) = makeSUT(
            duration: duration,
            initialOTPInputState: completed()
        )
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
            .starting(duration: duration),
            running(32),
            running(31),
            running(31, otpField: text("12345")),
            running(31, otpField: completed("654321")),
            runningInflight(31, "654321"),
            .failure(.connectivityError)
        ])
        
        XCTAssertNotNil(binder)
    }
    
    func test_successFlow() {
        
        let duration = 33
        let (binder, sut, timerSpy, initiateSpy, submitOTPSpy) = makeSUT(
            duration: duration,
            initialOTPInputState: completed()
        )
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
            .starting(duration: duration),
            running(32),
            running(31),
            running(30),
        ])
        
        sut.event(.otpField(.edit("12345")))
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting(duration: duration),
            running(32),
            running(31),
            running(30),
            running(30, otpField: text("12345")),
        ])
        
        sut.event(.otpField(.confirmOTP))
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting(duration: duration),
            running(32),
            running(31),
            running(30),
            running(30, otpField: text("12345")),
        ])
        
        sut.event(.otpField(.edit("654321")))
        XCTAssertNoDiff(stateSpy.values, [
            completed(),
            completed(),
            .starting(duration: duration),
            running(32),
            running(31),
            running(30),
            running(30, otpField: text("12345")),
            running(30, otpField: completed("654321")),
        ])
        
        sut.event(.otpField(.confirmOTP))
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
        ])
        
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
        initialOTPInputState: OTPInputState? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        binder: Binder,
        sut: SUT,
        timerSpy: TimerSpy,
        initiateSpy: InitiateSpy,
        submitOTPSpy: SubmitOTPSpy
    ) {
        let initialOTPInputState = initialOTPInputState ?? .starting(duration: duration)
        
        let timerSpy = TimerSpy(duration: duration)
        let initiateSpy = InitiateSpy()
        let submitOTPSpy = SubmitOTPSpy()
        let sut: SUT = .default(
            initialOTPInputState: initialOTPInputState,
            timer: timerSpy,
            duration: duration,
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
}
