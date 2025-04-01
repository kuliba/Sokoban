//
//  SplashScreenEffectHandlerTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 01.04.2025.
//

import SplashScreenUI
import XCTest

final class SplashScreenEffectHandlerTests: SplashScreenTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, load) = makeSUT()
        
        XCTAssertEqual(load.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - requestUpdate
    
    func test_requestUpdate_shouldCallLoad() {
        
        let (sut, load) = makeSUT()
        
        sut.handleEffect(.requestUpdate) { _ in }
        
        XCTAssertEqual(load.callCount, 1)
    }
    
    func test_requestUpdate_shouldDeliverFailure_onLoadFailure() {
        
        let (sut, load) = makeSUT()
        
        expect(sut, with: .requestUpdate, toDeliver: .update(nil)) {
            
            load.complete(with: nil)
        }
    }
    
    func test_requestUpdate_shouldDeliverSuccess_onLoadSuccess() {
        
        let settings = makeSettings()
        let (sut, load) = makeSUT()
        
        expect(sut, with: .requestUpdate, toDeliver: .update(settings)) {
            
            load.complete(with: settings)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SplashScreenEffectHandler
    private typealias LoadSpy = Spy<Void, State.Settings?>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        load: LoadSpy
    ) {
        let load = LoadSpy()
        let sut = SUT(load: load.process(completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(load, file: file, line: line)
        
        return (sut, load)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
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
