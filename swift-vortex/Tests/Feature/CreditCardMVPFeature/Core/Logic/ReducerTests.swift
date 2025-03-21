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

struct State: Equatable {}

enum Event: Equatable {
    
    case orderResult(OrderResult)
    
    typealias OrderResult = Result<OK, LoadFailure>
    struct OK: Equatable {}
}

enum Effect: Equatable {}

final class Reducer {
    
    private let otpWitness: OTPWitness
    
    init(otpWitness: @escaping OTPWitness) {
     
        self.otpWitness = otpWitness
    }
    
    typealias OTPWitness = (State) -> ((String) -> Void)?
}

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
    
    typealias State = CreditCardMVPCoreTests.State
    typealias Event = CreditCardMVPCoreTests.Event
    typealias Effect = CreditCardMVPCoreTests.Effect
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
                // TODO: - side effect, aim to make pure func
                otpWitness(state)?(failure.message)
            }
            
        case let .success(success):
            break
        }
    }
}

import XCTest

final class ReducerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spy) = makeSUT()
                
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_reduce_shouldNotifyOTP_onOTPFailure() {
        
        let message = anyMessage()
        let state = makeState()
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(state, .orderResult(.failure(.init(message: message, type: .otp))))
        
        XCTAssertNoDiff(spy.payloads, [message])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Reducer
    private typealias OTPSpy = CallSpy<String, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: OTPSpy
    ) {
        let spy = OTPSpy(stubs: [()])
        let sut = SUT(otpWitness: { _ in spy.call(payload:) })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeState(
    ) -> State {
        
        return .init()
    }
}
