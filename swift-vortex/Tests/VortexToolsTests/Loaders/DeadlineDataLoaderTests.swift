//
//  DeadlineDataLoaderTests.swift
//
//
//  Created by Igor Malyarov on 07.03.2025.
//

import CombineSchedulers
import VortexTools
import XCTest

final class DeadlineDataLoaderTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, asyncLoader, syncLoader, _) = makeSUT()
        
        XCTAssertEqual(asyncLoader.callCount, 0)
        XCTAssertEqual(syncLoader.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_load_shouldCallAsyncLoader() {
        
        let (sut, asyncLoader, _,_) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(asyncLoader.callCount, 1)
    }
    
    func test_load_shouldDeliverLocal_onAsyncLoaderResponseOutsideOfInterval() {
        
        let syncValue = makeValue()
        let (sut, asyncLoader, _, scheduler) = makeSUT(
            interval: .milliseconds(100),
            syncLoader: syncValue
        )
        
        expect(sut: sut, toDeliver: syncValue) {
            
            scheduler.advance(by: .milliseconds(101))
            asyncLoader.complete(with: makeValue())
            XCTAssertNotNil(sut)
        }
    }
    
    func test_load_shouldDeliverLocal_onAsyncLoaderFailureInsideInterval() {
        
        let syncValue = makeValue()
        let (sut, asyncLoader, _, scheduler) = makeSUT(
            interval: .milliseconds(100),
            syncLoader: syncValue
        )
        
        expect(sut: sut, toDeliver: syncValue) {
            
            scheduler.advance(by: .milliseconds(99))
            asyncLoader.complete(with: nil)
        }
    }
    
    func test_load_shouldDeliverAsyncLoad_onAsyncLoaderResponseInsideInterval() {
        
        let asyncValue = makeValue()
        let (sut, asyncLoader, _, scheduler) = makeSUT(
            interval: .milliseconds(100)
        )
        
        expect(sut: sut, toDeliver: asyncValue) {
            
            scheduler.advance(by: .milliseconds(99))
            asyncLoader.complete(with: asyncValue)
        }
    }
    
    func test_raceCondition_multipleAsyncLoaderCallbacks_triggeredConcurrently() {
        
        let iterations = 1_000
        var failureCount = 0
        let queue = DispatchQueue.global()
        
        for _ in 0..<iterations {
            
            let syncValue = makeValue()
            let syncLoader = SyncLoader(stubs: [syncValue])
            
            let asyncValue = makeValue()
            let asyncLoader = AsyncLoader()
            
            let sut = SUT(
                interval: .milliseconds(1),
                asyncLoader: asyncLoader.process,
                syncLoader: syncLoader.call,
                scheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
            
            let exp = expectation(description: "load completion")
            exp.expectedFulfillmentCount = 1
            var completionCount = 0
            
            sut.load { _ in
                
                completionCount += 1
                exp.fulfill()
            }
            
            let concurrentCalls = 10
            let group = DispatchGroup()
            
            for _ in 0..<concurrentCalls {
                
                group.enter()
                queue.async {
                    asyncLoader.complete(with: asyncValue)
                    group.leave()
                }
            }
            
            group.wait()
            
            wait(for: [exp], timeout: 0.1)
            if completionCount != 1 {
                failureCount += 1
            }
        }
        
        XCTAssertEqual(failureCount, 0, "Race condition detected in \(failureCount) out of \(iterations) iterations")
    }
    
    // MARK: - Helpers
    
    private typealias SUT = DeadlineDataLoader<Value>
    private typealias AsyncLoader = Spy<Void, Value?>
    private typealias SyncLoader = CallSpy<Void, Value>
    
    private func makeSUT(
        interval: SUT.Interval = .milliseconds(999),
        syncLoader: Value? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        asyncLoader: AsyncLoader,
        syncLoader: SyncLoader,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let asyncLoader = AsyncLoader()
        let syncLoader = SyncLoader(stubs: [syncLoader ?? makeValue()])
        let scheduler = DispatchQueue.test
        
        let sut = SUT(
            interval: interval,
            asyncLoader: asyncLoader.process,
            syncLoader: syncLoader.call,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(asyncLoader, file: file, line: line)
        trackForMemoryLeaks(syncLoader, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, asyncLoader, syncLoader, scheduler)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
    
    private func expect(
        sut: SUT,
        toDeliver expectedValues: Value...,
        on action: () -> Void,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        var receivedValues = [Value]()
        
        sut.load {
            
            receivedValues.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
        
        XCTAssertNoDiff(receivedValues, expectedValues, "Expected \(expectedValues), but got \(receivedValues) instead.", file: file, line: line)
    }
}
