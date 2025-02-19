//
//  LoadEffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 19.02.2025.
//

import XCTest

final class LoadEffectHandlerTests: LoadTests {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, load) = makeSUT()
        
        XCTAssertEqual(load.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_load_shouldCallLoad() {
        
        let (sut, load) = makeSUT()
        
        sut.handleEffect(.load) { _ in }
        
        XCTAssertEqual(load.callCount, 1)
    }
    
    func test_load_shouldDeliverFailure_onLoadFailure() {
        
        let failure = makeFailure()
        let (sut, load) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded(.failure(failure))) {
            
            load.complete(with: .failure(failure))
        }
    }
    
    func test_load_shouldDeliverSuccess_onLoadSuccess() {
        
        let success = makeSuccess()
        let (sut, load) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded(.success(success))) {
            
            load.complete(with: .success(success))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoadEffectHandler<Success, Failure>
    private typealias LoadSpy = Spy<Void, Result<Success, Failure>>
    
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
