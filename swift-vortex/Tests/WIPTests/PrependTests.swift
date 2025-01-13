//
//  PrependTests.swift
//
//
//  Created by Igor Malyarov on 13.12.2024.
//

import Combine
import CombineSchedulers
import XCTest

final class PrependTests: XCTestCase {
    
    func test_prepend() {
        
        let (subject, spy, scheduler) = makeSUT(delay: .milliseconds(200))
        XCTAssertNoDiff(spy.values, [])
        
        subject.send(123)
        XCTAssertNoDiff(spy.values, [nil])
        
        scheduler.advance(by: .milliseconds(199))
        XCTAssertNoDiff(spy.values, [nil])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(spy.values, [nil, 123])
    }
    
    // MARK: - Helpers
    
    private typealias Subject = PassthroughSubject<Int?, Never>
    private typealias Spy = ValueSpy<Int?>
    
    private func makeSUT(
        delay: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(300),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        subject: Subject,
        spy: Spy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let subject = Subject()
        let scheduler = DispatchQueue.test
        let spy = Spy(
            subject
                .flatMap {
                    
                    Just($0)
                        .delay(for: delay, scheduler: scheduler)
                        .prepend(nil)
                }
        )
        
        trackForMemoryLeaks(subject, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (subject, spy, scheduler)
    }
}
