//
//  Scheduler+scheduledTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.10.2024.
//

import Combine
import CombineSchedulers
@testable import ForaBank
import XCTest

final class Scheduler_scheduledWorkWithPayloadAndResponseTests: XCTestCase {
    
    func test_scheduled_shouldScheduleWorkWithPayload() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        sut(42) { _ in }
        scheduler.advance()
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertEqual(spy.payloads.first, 42)
    }
    
    func test_scheduled_shouldDeliverResponse() {
        
        let response = anyMessage()
        let (sut, spy, scheduler) = makeSUT()
        
        expect(sut, toDeliver: response) {
            
            scheduler.advance()
            spy.complete(with: response)
        }
    }
    
    // MARK: - Helpers
    
    typealias Payload = Int
    typealias Response = String
    typealias WorkWithPayloadAndResponse = (Payload, @escaping (Response) -> Void) -> Void
    private typealias SUT = WorkWithPayloadAndResponse
    private typealias WorkSpy = Spy<Payload, Response, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: WorkSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let spy = WorkSpy()
        let scheduler = DispatchQueue.test
        let sut: SUT = scheduler.scheduled(spy.process)
        
        return (sut, spy, scheduler)
    }
    
    private func expect(
        _ sut: SUT,
        with payload: Payload = .random(in: 1...100),
        toDeliver expectedResponse: Response,
        on action: () -> Void,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut(payload) {
            
            XCTAssertNoDiff($0, expectedResponse, file: #file, line: #line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}

final class Scheduler_scheduledWorkWithResponseTests: XCTestCase {
    
    func test_scheduled_shouldScheduleWork() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        sut() { _ in }
        scheduler.advance()
        
        XCTAssertEqual(spy.callCount, 1)
    }
    
    func test_scheduled_shouldDeliverResponse() {
        
        let response = anyMessage()
        let (sut, spy, scheduler) = makeSUT()
        
        expect(sut, toDeliver: response) {
            
            scheduler.advance()
            spy.complete(with: response)
        }
    }
    
    // MARK: - Helpers
    
    typealias Payload = Void
    typealias Response = String
    typealias WorkWithResponse = (@escaping (Response) -> Void) -> Void
    private typealias SUT = WorkWithResponse
    private typealias WorkSpy = Spy<Payload, Response, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: WorkSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let spy = WorkSpy()
        let scheduler = DispatchQueue.test
        let sut: SUT = scheduler.scheduled(spy.process)
        
        return (sut, spy, scheduler)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResponse: Response,
        on action: () -> Void,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut {
            
            XCTAssertNoDiff($0, expectedResponse, file: #file, line: #line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}

final class Scheduler_scheduledWorkWithPayloadTests: XCTestCase {
    
    func test_scheduled_shouldScheduleWorkWithPayload() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        sut(42) { }
        scheduler.advance()
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertEqual(spy.payloads.first, 42)
    }
    
    func test_scheduled_shouldDeliverResponse() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        expect(sut) {
            
            scheduler.advance()
            spy.complete(with: ())
        }
    }
    
    // MARK: - Helpers
    
    typealias Payload = Int
    typealias Response = Void
    typealias WorkWithPayload = (Payload, @escaping () -> Void) -> Void
    private typealias SUT = WorkWithPayload
    private typealias WorkSpy = Spy<Payload, Response, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: WorkSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let spy = WorkSpy()
        let scheduler = DispatchQueue.test
        let sut: SUT = scheduler.scheduled { payload, completion in
            
            spy.process(payload, completion: completion)
        }
        
        return (sut, spy, scheduler)
    }
    
    private func expect(
        _ sut: SUT,
        with payload: Payload = .random(in: 1...100),
        on action: () -> Void,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        sut(payload) { exp.fulfill() }
        action()
        wait(for: [exp], timeout: timeout)
    }
}

final class Scheduler_scheduledWorkTests: XCTestCase {
    
    func test_scheduled_shouldScheduleWorkWithPayload() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        sut { }
        scheduler.advance()
        
        XCTAssertEqual(spy.callCount, 1)
    }
    
    func test_scheduled_shouldDeliverResponse() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        expect(sut) {
            
            scheduler.advance()
            spy.complete(with: ())
        }
    }
    
    // MARK: - Helpers
    
    typealias Payload = Void
    typealias Response = Void
    typealias Work = (@escaping () -> Void) -> Void
    private typealias SUT = Work
    private typealias WorkSpy = Spy<Payload, Response, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: WorkSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let spy = WorkSpy()
        let scheduler = DispatchQueue.test
        let sut: SUT = scheduler.scheduled { completion in
            
            spy.process { completion() }
        }
        
        return (sut, spy, scheduler)
    }
    
    private func expect(
        _ sut: SUT,
        on action: () -> Void,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        sut { exp.fulfill() }
        action()
        wait(for: [exp], timeout: timeout)
    }
}
