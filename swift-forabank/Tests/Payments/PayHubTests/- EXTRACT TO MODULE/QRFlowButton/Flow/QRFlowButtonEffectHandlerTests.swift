//
//  QRFlowButtonEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import PayHub
import XCTest

final class QRFlowButtonEffectHandlerTests: QRFlowButtonTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, makeDestination) = makeSUT()
        
        XCTAssertEqual(makeDestination.callCount, 0)
    }
    
    func test_processButtonTap_shouldCallMakeDestination() {
        
        let (sut, makeDestination) = makeSUT()
        
        sut.handleEffect(.processButtonTap) { _ in }
        
        XCTAssertEqual(makeDestination.callCount, 1)
    }
    
    func test_processButtonTap_shouldDeliverDestination() {
        
        let destination = makeDestination()
        let (sut, makeDestination) = makeSUT()
        
        expect(sut, with: .processButtonTap, toDeliver: .setDestination(destination)) {
            
            makeDestination.complete(with: destination)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRFlowButtonEffectHandler<Destination>
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
        trackForMemoryLeaks(makeDestination, file: file, line: line)
        
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
