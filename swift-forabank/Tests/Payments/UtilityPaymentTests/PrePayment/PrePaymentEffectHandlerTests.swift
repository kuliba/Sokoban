//
//  PrePaymentEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 09.03.2024.
//

import PrePaymentPicker
import UtilityPayment
import XCTest

final class PrePaymentEffectHandler<LastPayment, Operator> {
    
    
}

extension PrePaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension PrePaymentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrePaymentEvent<LastPayment, Operator>
    typealias Effect = PrePaymentEffect
}

final class PrePaymentEffectHandlerTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = PrePaymentEffectHandler<LastPayment, Operator>
    
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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

