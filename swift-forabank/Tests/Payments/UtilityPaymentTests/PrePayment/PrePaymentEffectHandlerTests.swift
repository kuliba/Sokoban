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

final class PrePaymentEffectHandler<LastPayment, Operator, Response> {
    
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
    typealias StartPaymentResult = Result<Response, ServiceFailure>
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (Payload, @escaping StartPaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrePaymentEvent<LastPayment, Operator, Response>
    typealias Effect = PrePaymentEffect<LastPayment, Operator>
}

private extension PrePaymentEffectHandler {
    
    func startPayment(
        _ payload: Effect.StartPaymentPayload,
        _ dispatch: @escaping Dispatch
    ) {
        switch payload {
        case let .last(lastPayment):
            startPayment(.last(lastPayment)) {
                
                switch $0 {
                case let .failure(serviceFailure):
                    dispatch(.paymentStarted(.failure(serviceFailure)))
                    
                case let .success(response):
                    dispatch(.paymentStarted(.success(response)))
                }
            }
            
        case let .operator(`operator`):
            fatalError("can't handle `operator` case with \(`operator`) - can't start payment, need to select service first")
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
    
    func test_startPayment_shouldDeliverConnectivityErrorOnStartPaymentConnectivityErrorFailure_lastPayment() {
        
        let effect: Effect = .startPayment(.last(makeLastPayment()))
        let (sut, startPayment) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.failure(.connectivityError)), on: {
            
            startPayment.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_startPayment_shouldDeliverServerErrorOnStartPaymentServerErrorFailure_lastPayment() {
        
        let effect: Effect = .startPayment(.last(makeLastPayment()))
        let message = anyMessage()
        let (sut, startPayment) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.failure(.serverError(message))), on: {
            
            startPayment.complete(with: .failure(.serverError(message)))
        })
    }
    
    func test_startPayment_shouldDeliverStartPaymentResponseOnSuccess_lastPayment() {
        
        let effect: Effect = .startPayment(.last(makeLastPayment()))
        let response = makeResponse()
        let (sut, startPayment) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.success(response)), on: {
            
            startPayment.complete(with: .success(response))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrePaymentEffectHandler<LastPayment, Operator, StartPaymentResponse>
    
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias StartPaymentSpy = Spy<SUT.Payload, SUT.StartPaymentResult>
    
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
    
    private func makeResponse(
        _ value: String = UUID().uuidString
    ) -> StartPaymentResponse {
        
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

private struct StartPaymentResponse: Equatable {
    
    var value: String
    
    var id: String { value }
}
