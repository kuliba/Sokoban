//
//  PaymentsTransfersFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import XCTest

final class PaymentsTransfersFlowEffectHandlerTests: PaymentsTransfersFlowTests {
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersFlowEffectHandler
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT(microServices: .init(
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var receivedEvents = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            receivedEvents.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(receivedEvents, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
