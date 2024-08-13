//
//  ServicePaymentFlowEffectHandlerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.07.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class ServicePaymentFlowEffectHandlerTests: ServicePaymentFlowTests {
    
    func test_delay_shouldDelayEventForInterval() {
        
        let delayedEvent: SUT.Event = notify(.awaitingPaymentRestartConfirmation)
        let interval = DispatchTimeInterval.milliseconds(100)
        let (sut, scheduler) = makeSUT()
        var receivedEvent: SUT.Event?
        
        sut.handleEffect(.delay(delayedEvent, for: interval)) { receivedEvent = $0 }
        
        XCTAssertNil(receivedEvent)
        
        scheduler.advance(to: .init(.now() + interval))
        
        XCTAssertNoDiff(receivedEvent, delayedEvent)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ServicePaymentFlowEffectHandler
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let scheduler = DispatchQueue.test
        let sut = SUT(scheduler: scheduler.eraseToAnyScheduler())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, scheduler)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedEvent: SUT.Event,
        for effect: SUT.Effect,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) {
            
            XCTAssertNoDiff(expectedEvent, $0, "Expected \(expectedEvent), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
