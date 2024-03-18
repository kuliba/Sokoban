//
//  PaymentsTransfersFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment
import XCTest

final class PaymentsTransfersFlowEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, utilityFlowSpy) = makeSUT()
        
        XCTAssertEqual(utilityFlowSpy.callCount, 0)
    }
    
    // MARK: - utilityFlow
    
    func test_utilityFlow_shouldCallUtilityFlowEffectHandlerWithEffect() {
        
        let (sut, utilityFlowSpy) = makeSUT()
        
        sut.handleEffect(.utilityFlow(.initiate)) { _ in }
        
        XCTAssertNoDiff(utilityFlowSpy.messages.map(\.effect), [.initiate])
    }
    
    func test_utilityFlow_shouldDispatchLoadedFailureEventFromUtilityFlowEffectHandler() {
        
        let event = UtilityEvent.loaded(.failure)
        let (sut, utilityFlowSpy) = makeSUT()

        expect(sut, with: .utilityFlow(.initiate), toDeliver: .utilityFlow(event)) {
            
            utilityFlowSpy.complete(with: event)
        }
    }
    
    func test_utilityFlow_shouldDispatchLoadedSuccessEventFromUtilityFlowEffectHandler() {
        
        let event = UtilityEvent.loaded(.success([makeLastPayment()], [makeOperator()]))
        let (sut, utilityFlowSpy) = makeSUT()

        expect(sut, with: .utilityFlow(.initiate), toDeliver: .utilityFlow(event)) {
            
            utilityFlowSpy.complete(with: event)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersFlowEffectHandler<LastPayment, Operator, Service, StartPaymentResponse>
    
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias UtilityFlowEffectHandleSpy = EffectHandlerSpy<UtilityEvent, UtilityEffect>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        utilityFlowSpy: UtilityFlowEffectHandleSpy
    ) {
        let utilityFlowSpy = UtilityFlowEffectHandleSpy()
        
        let sut = SUT(utilityFlowHandleEffect: utilityFlowSpy.handleEffect(_:_:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, utilityFlowSpy)
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
