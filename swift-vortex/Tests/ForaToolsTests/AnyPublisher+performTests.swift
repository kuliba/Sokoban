//
//  AnyPublisher+performTests.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import Combine
import ForaTools
import XCTest

final class AnyPublisher_performTests: XCTestCase {
    
    func test_perform_shouldNotDeliverValueInitially() {
        
        let (_, spy, _) = makeSUT()
        
        XCTAssertTrue(spy.values.isEmpty)
    }
    
    func test_perform_shouldNotCallLoadOnStateChangeToFailed() {
        
        let (subject, spy, performSpy) = makeSUT()
        
        subject.send(.failure)
        
        XCTAssertEqual(performSpy.callCount, 0)
        XCTAssertNotNil(spy)
    }
    
    func test_perform_shouldNotCallLoadOnStateChangeToLoading() {
        
        let (subject, spy, performSpy) = makeSUT()
        
        subject.send(.inflight)
        
        XCTAssertEqual(performSpy.callCount, 0)
        XCTAssertNotNil(spy)
    }
    
    func test_perform_shouldCallLoadOnStateChangeToLoaded() {
        
        let (subject, spy, performSpy) = makeSUT()
        
        subject.send(.success)
        
        XCTAssertEqual(performSpy.callCount, 1)
        XCTAssertNotNil(spy)
    }
    
    func test_perform_shouldNotCallLoadOnStateChangeToNotStarted() {
        
        let (subject, spy, performSpy) = makeSUT()
        
        subject.send(.notStarted)
        
        XCTAssertEqual(performSpy.callCount, 0)
        XCTAssertNotNil(spy)
    }
    
    func test_perform_shouldDeliverFailureValueOnStateChangeToFailed() {
        
        let failureValue = makeResponse()
        let (subject, spy, _) = makeSUT(failureValue: failureValue)
        
        subject.send(.failure)
        
        XCTAssertNoDiff(spy.values, [failureValue])
    }
    
    func test_perform_shouldNotDeliverValueOnStateChangeToLoading() {
        
        let (subject, spy, _) = makeSUT()
        
        subject.send(.inflight)
        
        XCTAssertTrue(spy.values.isEmpty)
    }
    
    func test_perform_shouldDeliverLoadedValueOnStateChangeToLoaded() {
        
        let performedValue = makeResponse()
        let (subject, spy, performSpy) = makeSUT()
        
        subject.send(.success)
        performSpy.complete(with: performedValue)
        
        XCTAssertNoDiff(spy.values, [performedValue])
    }
    
    func test_perform_shouldNotDeliverValueOnStateChangeToNotStarted() {
        
        let (subject, spy, _) = makeSUT()
        
        subject.send(.notStarted)
        
        XCTAssertTrue(spy.values.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnyPublisher<OperationTrackerState, Never>
    private typealias Subject = PassthroughSubject<OperationTrackerState, Never>
    private typealias PerformSpy = Spy<Void, Response>
    
    private func makeSUT(
        failureValue: Response? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        subject: Subject,
        spy: ValueSpy<Response>,
        performSpy: PerformSpy
    ) {
        let subject = Subject()
        let performSpy = PerformSpy()
        let spy = ValueSpy(
            subject
                .eraseToAnyPublisher()
                .perform(
                    performSpy.process(completion:),
                    failureValue: failureValue ?? makeResponse()
                )
        )
        
        trackForMemoryLeaks(subject, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(performSpy, file: file, line: line)
        
        return (subject, spy, performSpy)
    }
    
    private struct Response: Equatable {
        
        let value: String
    }
    
    private func makeResponse(
        _ value: String = anyMessage()
    ) -> Response {
        
        return .init(value: value)
    }
}
