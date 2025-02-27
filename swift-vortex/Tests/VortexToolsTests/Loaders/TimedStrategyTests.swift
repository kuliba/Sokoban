//
//  TimedStrategyTests.swift
//  
//
//  Created by Nikolay Pochekuev on 21.02.2025.
//

import CombineSchedulers
import VortexTools
import XCTest

final class TimedStrategyTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, remote, local, _) = makeSUT()
        
        XCTAssertEqual(remote.callCount, 0)
        XCTAssertEqual(local.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_load_shouldCallRemote() {
        
        let (sut, remote, _,_) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(remote.callCount, 1)
    }
    
    func test_load_shouldDeliverLocal_onRemoteResponseOutsideOfInterval() {
        
        let localValue = makeValue()
        let (sut, remote, _, scheduler) = makeSUT(
            interval: .milliseconds(100),
            local: localValue
        )
        
        expect(sut: sut, toDeliver: localValue) {
            
            scheduler.advance(by: .milliseconds(101))
            remote.complete(with: makeValue())
            XCTAssertNotNil(sut)
        }
    }
    
    func test_load_shouldDeliverLocal_onRemoteFailureInsideInterval() {
        
        let localValue = makeValue()
        let (sut, remote, _, scheduler) = makeSUT(
            interval: .milliseconds(100),
            local: localValue
        )
        
        expect(sut: sut, toDeliver: localValue) {
            
            scheduler.advance(by: .milliseconds(99))
            remote.complete(with: nil)
        }
    }
    
    func test_load_shouldDeliverRemote_onRemoteResponseInsideInterval() {
        
        let remoteValue = makeValue()
        let (sut, remote, _, scheduler) = makeSUT(
            interval: .milliseconds(100)
        )
        
        expect(sut: sut, toDeliver: remoteValue) {
            
            scheduler.advance(by: .milliseconds(99))
            remote.complete(with: remoteValue)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TimedStrategy<Value>
    private typealias Remote = Spy<Void, Value?>
    private typealias Local = CallSpy<Void, Value>
    
    private func makeSUT(
        interval: SUT.Interval = .milliseconds(999),
        local: Value? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        remote: Remote,
        local: Local,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let remote = Remote()
        let local = Local(stubs: [local ?? makeValue()])
        let scheduler = DispatchQueue.test
        
        let sut = SUT(
            interval: interval,
            remote: remote.process,
            local: local.call,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(remote, file: file, line: line)
        trackForMemoryLeaks(local, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, remote, local, scheduler)
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
