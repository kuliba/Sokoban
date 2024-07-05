//
//  TimedOTPInputViewModelTests.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent
import Combine
import XCTest

final class TimedOTPInputViewModelTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldCallTimerWithStopOnInitialStateNil() {
        
        let (_,_, timerSpy, _,_) = makeSUT(initialState: nil)
        
        XCTAssertNoDiff(timerSpy.messages, [.stop])
    }
    
    func test_init_shouldNotCallReducerOnInitialStateNil() {
        
        let (_,_,_, reducerSpy, _) = makeSUT(initialState: nil)
        
        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    func test_init_shouldCallTimerWithStopOnInitialStateComplete() {
        
        let initialState = makeState(countdown: .completed)
        let (_,_, timerSpy, _,_) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(timerSpy.messages, [.stop])
    }
    
    func test_init_shouldNotCallReducerOnInitialStateComplete() {
        
        let initialState = makeState(countdown: .completed)
        let (_,_,_, reducerSpy, _) = makeSUT(initialState: initialState)
        
        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    func test_init_shouldCallTimerWithStartOnInitialStateStarting() {
        
        let initialState = makeState(countdown: .starting(duration: 22))
        let (_,_, timerSpy, _,_) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(timerSpy.messages, [.start])
    }
    
    func test_init_shouldNotCallReducerOnInitialStateStarting() {
        
        let initialState = makeState(countdown: .starting(duration: 22))
        let (_,_,_, reducerSpy, _) = makeSUT(initialState: initialState)
        
        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    func test_init_shouldCallTimerWithStopOnInitialFailure() {
        
        let initialState = makeState(countdown: .failure(.connectivityError))
        let (_,_, timerSpy, _,_) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(timerSpy.messages, [.stop])
    }
    
    func test_init_shouldNotCallReducerOnInitialStateFailure() {
        
        let initialState = makeState(countdown: .failure(.connectivityError))
        let (_,_,_, reducerSpy, _) = makeSUT(initialState: initialState)
        
        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    func test_init_shouldNotCallTimerOnInitialStateRunningAtDuration() {
        
        let duration = 7
        let initialState = makeState(
            countdown: .running(remaining: duration)
        )
        let (_,_, timerSpy, _,_) = makeSUT(
            duration: duration,
            initialState: initialState
        )
                
        XCTAssertEqual(timerSpy.callCount, 0)
    }
    
    func test_init_shouldNotCallReducerOnInitialStateRunningAtDuration() {
        
        let duration = 7
        let initialState = makeState(
            countdown: .running(remaining: duration)
        )
        let (_,_,_, reducerSpy, _) = makeSUT(
            duration: duration,
            initialState: initialState,
            reducerStub: (makeState(), nil)
        )
        
        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    func test_init_shouldNotCallTimerOnInitialStateRunningRemainingLessThanDuration() {
        
        let duration = 7
        let initialState = makeState(
            countdown: .running(remaining: duration - 1)
        )
        let (_,_, timerSpy, _,_) = makeSUT(
            duration: duration,
            initialState: initialState
        )
        
        XCTAssertNoDiff(timerSpy.messages, [])
    }
    
    func test_init_shouldNotCallReducerOnInitialStateRunningRemainingLessThanDuration() {
        
        let duration = 7
        let initialState = makeState(
            countdown: .running(remaining: duration - 1)
        )
        let (_,_,_, reducerSpy, _) = makeSUT(
            duration: duration,
            initialState: initialState
        )
        
        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    func test_init_shouldNotCallTimerOnInitialStateRunningRemainingZero() {
        
        let duration = 7
        let initialState = makeState(
            countdown: .running(remaining: 0)
        )
        let (_,_, timerSpy, _,_) = makeSUT(
            duration: duration,
            initialState: initialState
        )
        
        XCTAssertNoDiff(timerSpy.messages, [])
    }
    
    func test_init_shouldNotCallReducerOnInitialStateRunningRemainingZero() {
        
        let duration = 7
        let initialState = makeState(
            countdown: .running(remaining: 0)
        )
        let (_,_,_, reducerSpy, _) = makeSUT(
            duration: duration,
            initialState: initialState
        )
        
        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    // MARK: - start & tick flow
    
    func test_start_tick_flow() {
        
        let duration = 4
        let (sut, stateSpy, timerSpy, reducerSpy, effectHandlerSpy) = makeSUT(
            duration: duration,
            reducerStub:
                (makeState(countdown: .starting(duration: 4)), nil),
                (makeState(countdown: .running(remaining: 4)), nil),
                (makeState(countdown: .running(remaining: 3)), nil),
                (makeState(countdown: .running(remaining: 2)), nil),
                (makeState(countdown: .running(remaining: 1)), nil),
                (makeState(countdown: .running(remaining: 0)), nil)
        )
        
        sut.event(.countdown(.start))
        timerSpy.tick()
        timerSpy.tick()
        timerSpy.tick()
        timerSpy.tick()
        
        XCTAssertNoDiff(timerSpy.messages, [.stop, .start])
        XCTAssertNoDiff(reducerSpy.messages.map(\.event), [
            .countdown(.start),
            .countdown(.tick),
            .countdown(.tick),
            .countdown(.tick),
            .countdown(.tick),
        ])
        
        XCTAssertEqual(effectHandlerSpy.callCount, 0)

        XCTAssertNoDiff(stateSpy.values.map(\.status), [
            completed(),
            starting(4),
            running(4),
            running(3),
            running(2),
            running(1),
        ])
    }
    
    func test_otpInput_codeObserver_shouldSendEventEdit() {
        
        let subject = PassthroughSubject<String, Never>()
        
        let (_,_,_, reducerSpy, _) = makeSUT(
                duration: 4,
                codeObserver: subject.eraseToAnyPublisher(),
                reducerStub:
                    (makeState(countdown: .starting(duration: 4)), nil)
            )
        
        subject.send("123456")

        XCTAssertNoDiff(
            reducerSpy.messages.map({ $0.event }),
            [.otpField(.edit("123456"))]
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TimedOTPInputViewModel
    private typealias State = OTPInputState
    private typealias Event = OTPInputEvent
    private typealias Effect = OTPInputEffect
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias OTPInputReducerSpy = ReducerSpy<State, Event, Effect>
    private typealias OTPInputEffectHandlerSpy = EffectHandlerSpy<Event, Effect>
    
    private typealias ReducerStub = (State, Effect?)
    
    private func makeSUT(
        duration: Int = 5,
        length: Int = 6,
        initialState: OTPInputState? = nil,
        codeObserver: AnyPublisher<String, Never> = Empty().eraseToAnyPublisher(),
        reducerStub: ReducerStub...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        timerSpy: TimerSpy,
        reducerSpy: OTPInputReducerSpy,
        effectHandlerSpy: OTPInputEffectHandlerSpy
    ) {
        let timerSpy = TimerSpy(duration: duration)
        let reducerSpy = OTPInputReducerSpy(stub: reducerStub)
        let effectHandlerSpy = OTPInputEffectHandlerSpy()
        let initialState = initialState ?? makeState()
        let viewModel = OTPInputViewModel(
            initialState: initialState,
            reduce: reducerSpy.reduce(_:_:),
            handleEffect: effectHandlerSpy.handleEffect(_:_:),
            scheduler: .immediate
        )
        let sut = SUT(
            viewModel: viewModel,
            timer: timerSpy,
            codeObserver: codeObserver,
            scheduler: .immediate
        )
        let stateSpy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        trackForMemoryLeaks(viewModel, file: file, line: line)
        trackForMemoryLeaks(timerSpy, file: file, line: line)
        trackForMemoryLeaks(reducerSpy, file: file, line: line)
        trackForMemoryLeaks(effectHandlerSpy, file: file, line: line)
        
        return (sut, stateSpy, timerSpy, reducerSpy, effectHandlerSpy)
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
