//
//  PrePaymentEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 09.03.2024.
//

import PrePaymentPicker
import UtilityPayment
import XCTest

typealias ServiceFailure = UtilityPayment.ServiceFailure

final class PrePaymentEffectHandler<LastPayment, Operator> {
    
    private let startPayment: StartPayment
    
    init(
        startPayment: @escaping StartPayment
    ) {
        self.startPayment = startPayment
    }
}

extension PrePaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .startPayment(payload):
            startPayment(payload, dispatch)
        }
    }
}

extension PrePaymentEffectHandler {
    
    typealias Payload = Effect.StartPaymentPayload
    typealias StartPaymentResult = Result<Never, ServiceFailure>
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (Payload, @escaping StartPaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrePaymentEvent<LastPayment, Operator>
    typealias Effect = PrePaymentEffect<LastPayment, Operator>
}

private extension PrePaymentEffectHandler {
    
    func startPayment(
        _ payload: Effect.StartPaymentPayload,
        _ dispatch: @escaping Dispatch
    ) {
        startPayment(payload) {
            
            switch $0 {
            case let .failure(serviceFailure):
                dispatch(.startPayment(.failure(serviceFailure)))
                
            
            }
        }
    }
}

final class PrePaymentEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, startPayment) = makeSUT()
        
        XCTAssertEqual(startPayment.callCount, 0)
    }
    
    // MARK: - startPayment
    
    func test_startPayment_shouldCallStartPayment_lastPayment() {
        
        let lastPayment = makeLastPayment()
        let effect: Effect = .startPayment(.last(lastPayment))
        let (sut, startPayment) = makeSUT()
        
        sut.handleEffect(effect) { _ in }
        
        XCTAssertNoDiff(startPayment.messages.map(\.payload), [.last(lastPayment)])
    }
    
    func test_startPayment_shouldCallStartPayment_operator() {
        
        let `operator` = makeOperator()
        let effect: Effect = .startPayment(.operator(`operator`))
        let (sut, startPayment) = makeSUT()
        
        sut.handleEffect(effect) { _ in }
        
        XCTAssertNoDiff(startPayment.messages.map(\.payload), [.operator(`operator`)])
    }
    
    func test_startPayment_shouldDeliverConnectivityErrorOnStartPaymentConnectivityErrorFailure_lastPayment() {
        
        let lastPayment = makeLastPayment()
        let effect: Effect = .startPayment(.last(lastPayment))
        let (sut, startPayment) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .startPayment(.failure(.connectivityError)), on: {
            
            startPayment.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_startPayment_shouldDeliverServerErrorOnStartPaymentServerErrorFailure_lastPayment() {
        
        let lastPayment = makeLastPayment()
        let effect: Effect = .startPayment(.last(lastPayment))
        let message = anyMessage()
        let (sut, startPayment) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .startPayment(.failure(.serverError(message))), on: {
            
            startPayment.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrePaymentEffectHandler<LastPayment, Operator>
    
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias StartPaymentSpy = Spy<Effect.StartPaymentPayload, SUT.StartPaymentResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        startPayment: StartPaymentSpy
    ) {
        let startPayment = StartPaymentSpy()
        let sut = SUT(
            startPayment: startPayment.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(startPayment, file: file, line: line)
        
        return (sut, startPayment)
    }
    
    private func makeLastPayment(
        _ value: String = UUID().uuidString
    ) -> LastPayment {
        
        .init(value: value)
    }
    
    private func makeOperator(
        _ value: String = UUID().uuidString
    ) -> Operator {
        
        .init(value: value)
    }

    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvents: Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}

private struct LastPayment: Equatable {
    
    var value: String
}

private struct Operator: Equatable, Identifiable {
    
    var value: String
    
    var id: String { value }
}

