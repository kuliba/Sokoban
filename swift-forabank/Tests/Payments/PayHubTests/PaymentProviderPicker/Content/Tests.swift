//
//  Tests.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

import Combine
import CombineSchedulers
import XCTest

final class Tests: XCTestCase {
    
    func test_shouldDebounceForGivenInterval() {
        
        let (sut, scheduler, subject, spy) = makeSUT(for: .milliseconds(200))
        XCTAssertNoDiff(spy.payloads, [])
        
        subject.send("abc")
        
        XCTAssertNoDiff(spy.payloads, [])
        
        scheduler.advance(by: .milliseconds(199))
        
        XCTAssertNoDiff(spy.payloads, [])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.payloads, ["abc"])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldRemoveDuplicates() {
        
        let (sut, scheduler, subject, spy) = makeSUT()
        
        subject.send("abc")
        subject.send("abc")
        scheduler.advance(by: .milliseconds(300))
        
        XCTAssertNoDiff(spy.payloads, ["abc"])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldDeliverEmptyText() {
        
        let (sut, scheduler, subject, spy) = makeSUT()
        
        subject.send("abc")
        scheduler.advance(by: .milliseconds(300))
        
        subject.send("")
        scheduler.advance(by: .milliseconds(300))
        
        XCTAssertNoDiff(spy.payloads, ["abc", ""])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnyCancellable
    private typealias Subject = PassthroughSubject<String, Never>
    private typealias TextSpy = CallSpy<String, Void>
    
    private func makeSUT(
        for dueTime: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(300),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        scheduler: TestSchedulerOf<DispatchQueue>,
        subject: Subject,
        spy: TextSpy
    ) {
        let scheduler = DispatchQueue.test
        let subject = Subject()
        let spy = TextSpy()
        
        let sut = subject
            .debounce(for: dueTime, scheduler: scheduler)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak spy] in spy?.call(payload: $0) }
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(subject, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, scheduler, subject, spy)
    }
}
