//
//  PushUpdateFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import UtilityPayment
import XCTest

final class PushUpdateFlowEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, pushSpy, updateSpy) = makeSUT()
        
        XCTAssertEqual(pushSpy.callCount, 0)
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    // MARK: - Push
    
    func test_shouldCallPushWithPushEffect() {
        
        let (sut, pushSpy, updateSpy) = makeSUT()
        
        sut.handleEffect(.push(.push)) { _ in }
        
        XCTAssertEqual(pushSpy.payloads, [.push])
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    func test_shouldDeliverPushEvent() {
        
        let event = PushEvent.push
        let (sut, pushSpy, _) = makeSUT()
        
        expect(sut, with: .push(.push), toDeliver: .push(event)) {
            
            pushSpy.complete(with: event)
        }
    }
    
    // MARK: - Update
    
    func test_shouldCallUpdateWithUpdateEffect() {
        
        let (sut, pushSpy, updateSpy) = makeSUT()
        
        sut.handleEffect(.update(.update)) { _ in }
        
        XCTAssertEqual(pushSpy.callCount, 0)
        XCTAssertEqual(updateSpy.payloads, [.update])
    }
    
    func test_shouldDeliverUpdateEvent() {
        
        let event = UpdateEvent.update
        let (sut, _, updateSpy) = makeSUT()
        
        expect(sut, with: .update(.update), toDeliver: .update(event)) {
            
            updateSpy.complete(with: event)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PushUpdateFlowEffectHandler<PushEvent, UpdateEvent, PushEffect, UpdateEffect>
    
    private typealias State = UtilityFlow
    private typealias Event = PushUpdateFlowEvent<PushEvent, UpdateEvent>
    private typealias Effect = PushUpdateFlowEffect<PushEffect, UpdateEffect>
    
    private typealias PushSpy = Spy<PushEffect, PushEvent>
    private typealias UpdateSpy = Spy<UpdateEffect, UpdateEvent>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        pushSpy: PushSpy,
        updateSpy: UpdateSpy
    ) {
        let pushSpy = PushSpy()
        let updateSpy = UpdateSpy()
        
        let sut = SUT(
            push: pushSpy.process(_:completion:),
            update: updateSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(pushSpy, file: file, line: line)
        trackForMemoryLeaks(updateSpy, file: file, line: line)
        
        return (sut, pushSpy, updateSpy)
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

