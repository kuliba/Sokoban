//
//  AnyPublisher+loadTests.swift
//  
//
//  Created by Igor Malyarov on 28.08.2024.
//

import Combine
import ForaTools
import XCTest

final class AnyPublisher_loadTests: XCTestCase {
    
    func test_load_shouldNotDeliverValueInitially() {
        
        let (_, spy, _) = makeSUT()
        
        XCTAssertTrue(spy.values.isEmpty)
    }
    
    func test_load_shouldNotCallLoadOnStateChangeToFailed() {
        
        let (subject, spy, loadSpy) = makeSUT()
        
        subject.send(.failed)
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertNotNil(spy)
    }
    
    func test_load_shouldNotCallLoadOnStateChangeToLoading() {
        
        let (subject, spy, loadSpy) = makeSUT()
        
        subject.send(.loading)
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertNotNil(spy)
    }
    
    func test_load_shouldCallLoadOnStateChangeToLoaded() {
        
        let (subject, spy, loadSpy) = makeSUT()
        
        subject.send(.loaded)
        
        XCTAssertEqual(loadSpy.callCount, 1)
        XCTAssertNotNil(spy)
    }
    
    func test_load_shouldNotCallLoadOnStateChangeToNotStarted() {
        
        let (subject, spy, loadSpy) = makeSUT()
        
        subject.send(.notStarted)
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertNotNil(spy)
    }
    
    func test_load_shouldDeliverFailureValueOnStateChangeToFailed() {
        
        let failureValue = makeResponse()
        let (subject, spy, _) = makeSUT(failureValue: failureValue)
        
        subject.send(.failed)
        
        XCTAssertNoDiff(spy.values, [failureValue])
    }
    
    func test_load_shouldNotDeliverValueOnStateChangeToLoading() {
        
        let (subject, spy, _) = makeSUT()
        
        subject.send(.loading)
        
        XCTAssertTrue(spy.values.isEmpty)
    }
    
    func test_load_shouldDeliverLoadedValueOnStateChangeToLoaded() {
        
        let loadedValue = makeResponse()
        let (subject, spy, loadSpy) = makeSUT()
        
        subject.send(.loaded)
        loadSpy.complete(with: loadedValue)
        
        XCTAssertNoDiff(spy.values, [loadedValue])
    }
    
    func test_load_shouldNotDeliverValueOnStateChangeToNotStarted() {
        
        let (subject, spy, _) = makeSUT()
        
        subject.send(.notStarted)
        
        XCTAssertTrue(spy.values.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnyPublisher<OperationTrackerState, Never>
    private typealias Subject = PassthroughSubject<OperationTrackerState, Never>
    private typealias LoadSpy = Spy<Void, Response>
    
    private func makeSUT(
        failureValue: Response? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        subject: Subject,
        spy: ValueSpy<Response>,
        loadSpy: LoadSpy
    ) {
        let subject = Subject()
        let loadSpy = LoadSpy()
        let spy = ValueSpy(
            subject
                .eraseToAnyPublisher()
                .load(
                    loadSpy.process(completion:),
                    failureValue: failureValue ?? makeResponse()
                )
        )
        
        trackForMemoryLeaks(subject, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (subject, spy, loadSpy)
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
