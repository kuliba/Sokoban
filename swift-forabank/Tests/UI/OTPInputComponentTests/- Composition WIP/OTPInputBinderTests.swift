//
//  OTPInputBinderTests.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent
import XCTest

final class OTPInputBinderTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldCallTimerWithStopOnInitialStateNil() {
        
        let (_, timerSpy, _,_) = makeSUT(initialState: nil)
        
        XCTAssertNoDiff(timerSpy.messages, [.stop])
    }
    
    func test_init_shouldNotCallReducerOnInitialStateNil() {
        
        let (_,_, reducerSpy, _) = makeSUT(initialState: nil)
        
        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    func test_init_shouldCallTimerWithStopOnInitialStateComplete() {
        
        let initialState = makeState(countdown: .completed)
        let (_, timerSpy, _,_) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(timerSpy.messages, [.stop])
    }
    
    func test_init_shouldNotCallReducerOnInitialStateComplete() {
        
        let initialState = makeState(countdown: .completed)
        let (_,_, reducerSpy, _) = makeSUT(initialState: initialState)
        
        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    func test_init_shouldCallTimerWithStopOnInitialFailure() {
        
        let initialState = makeState(countdown: .failure(.connectivityError))
        let (_, timerSpy, _,_) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(timerSpy.messages, [.stop])
    }
    
    func test_init_shouldNotCallReducerOnInitialStateFailure() {
        
        let initialState = makeState(countdown: .failure(.connectivityError))
        let (_,_, reducerSpy, _) = makeSUT(initialState: initialState)
        
        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    func test_init_shouldCallTimerWithStartOnInitialStateRunningAtDuration() {
        
        let duration = 7
        let initialState = makeState(
            countdown: .running(remaining: duration)
        )
        let (_, timerSpy, _,_) = makeSUT(
            duration: duration,
            initialState: initialState
        )
        
        XCTAssertNoDiff(timerSpy.messages, [.start])
    }
    
    func test_init_shouldCallReducerWithTickOnInitialStateRunningAtDuration() {
        
        let duration = 7
        let initialState = makeState(
            countdown: .running(remaining: duration)
        )
        let (_, timerSpy, reducerSpy, _) = makeSUT(
            duration: duration,
            initialState: initialState,
            reducerStub: [(makeState(), nil)]
        )
        
        timerSpy.complete()
        
        XCTAssertNoDiff(reducerSpy.messages.map(\.event), [.countdown(.tick)])
    }
    
    func test_init_shouldNotCallTimerOnInitialStateRunningRemainingLessThanDuration() {
        
        let duration = 7
        let initialState = makeState(
            countdown: .running(remaining: duration - 1)
        )
        let (_, timerSpy, _,_) = makeSUT(
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
        let (_,_, reducerSpy, _) = makeSUT(
            duration: duration,
            initialState: initialState
        )

        XCTAssertEqual(reducerSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OTPInputBinder
    private typealias State = OTPInputState
    private typealias Event = OTPInputEvent
    private typealias Effect = OTPInputEffect
    
    private typealias OTPInputReducerSpy = ReducerSpy<OTPInputState, OTPInputEvent, OTPInputEffect>
    private typealias OTPInputEffectHandlerSpy = EffectHandlerSpy<OTPInputEvent, OTPInputEffect>
    
    private typealias ReducerStub = (OTPInputState, OTPInputEffect?)
    
    private func makeSUT(
        duration: Int = 5,
        initialState: OTPInputState? = nil,
        reducerStub: [ReducerStub] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        timerSpy: TimerSpy,
        reducerSpy: OTPInputReducerSpy,
        effectHandlerSpy: OTPInputEffectHandlerSpy
    ) {
        
        let timerSpy = TimerSpy()
        let initialState = initialState ?? makeState()
        let reducerSpy = OTPInputReducerSpy(stub: reducerStub)
        let effectHandlerSpy = OTPInputEffectHandlerSpy()
        let viewModel = OTPInputViewModel(
            initialState: initialState,
            reduce: reducerSpy.reduce(_:_:),
            handleEffect: effectHandlerSpy.handleEffect(_:_:),
            scheduler: .immediate
        )
        let sut = SUT(
            timer: timerSpy,
            duration: duration,
            viewModel: viewModel
        )
        
        trackForMemoryLeaks(reducerSpy, file: file, line: line)
        trackForMemoryLeaks(effectHandlerSpy, file: file, line: line)
        trackForMemoryLeaks(viewModel, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, timerSpy, reducerSpy, effectHandlerSpy)
    }
    
    private func makeState(
        countdown: CountdownState = .completed,
        otpField: OTPFieldState = .init()
    ) -> State {
        
        .init(countdown: countdown, otpField: otpField)
    }
    
    private final class TimerSpy: TimerProtocol {
        
        private var completions = [Completion]()
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func start(
            every interval: TimeInterval,
            onRun completion: @escaping Completion
        ) {
            completions.append(completion)
            messages.append(.start)
        }
        
        func stop() {
            
            messages.append(.stop)
        }
        
        func complete(
            at index: Int = 0
        ) {
            let completion = completions.remove(at: index)
            completion()
        }
        
        typealias Completion = () -> Void
        
        enum Message: Equatable {
            
            case start, stop
        }
    }
}
