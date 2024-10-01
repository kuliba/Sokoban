//
//  FailedPaymentProviderPickerFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 23.09.2024.
//

import PayHub
import XCTest

class FailedPaymentProviderPickerFlowTests: XCTestCase {
    
    struct Destination: Equatable {
        
        let value: String
    }
    
    func makeDestination(
        _ value: String = anyMessage()
    ) -> Destination {
        
        return .init(value: value)
    }
}

final class FailedPaymentProviderPickerFlowEffectHandlerTests: FailedPaymentProviderPickerFlowTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, makeDestination) = makeSUT()
        
        XCTAssertNoDiff(makeDestination.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - select
    
    func test_select_detailPay_shouldCallMakeDestination() {
        
        let (sut, makeDestination) = makeSUT()
        
        sut.handleEffect(.select(.detailPay)) { _ in }
        
        XCTAssertNoDiff(makeDestination.callCount, 1)
    }
    
    func test_select_detailPay_shouldDeliverDestination() {
        
        let destination = makeDestination()
        let (sut, makeDestination) = makeSUT()
        
        expect(sut, with: .select(.detailPay), toDeliver: .destination(destination)) {
            
            makeDestination.complete(with: destination)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FailedPaymentProviderPickerFlowEffectHandler<Destination>
    private typealias MakeDestinationSpy = Spy<Void, Destination>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeDestination: MakeDestinationSpy
    ) {
        let makeDestination = MakeDestinationSpy()
        let sut = SUT(microServices: .init(
            makeDestination: makeDestination.process(completion:)
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, makeDestination)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
