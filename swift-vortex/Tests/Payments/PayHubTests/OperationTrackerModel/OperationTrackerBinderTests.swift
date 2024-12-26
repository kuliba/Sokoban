//
//  OperationTrackerBinderTests.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import CombineSchedulers
import PayHub
import XCTest

final class OperationTrackerBinderTests: XCTestCase {
    
    func test_start_shouldEmitResponse() {
        
        let response = makeResponse()
        let (sut, startSpy, responseSpy) = makeSUT()
        
        sut.start()
        startSpy.complete(with: response)
        startSpy.complete(with: response, at: 1)
        
        XCTAssertNoDiff(responseSpy.payloads, [response])
    }
    
    func test_tracker_binder_false() {
        
        typealias ProcessSpy = Spy<Bool, Value>
        typealias ReceiveSpy = CallSpy<Value, Void>
        
        let startSpy = StartSpy()
        let processSpy = ProcessSpy()
        let receiveSpy = ReceiveSpy()
        let scheduler: AnySchedulerOf<DispatchQueue> = .immediate
        
        let tracker = OperationTrackerModel(
            start: startSpy.process(completion:),
            scheduler: scheduler
        )
        let publisher = tracker.$state
            .compactMap(\.isTerminated)
            .eraseToAnyPublisher()
        
        let binder = StateValueBinder(
            publisher: publisher,
            process: processSpy.process(_:completion:),
            receive: receiveSpy.call(payload:)
        )
        let binding = binder.bind()
        
        tracker.event(.start)
        
        let response = makeResponse()
        let value = makeValue()
        
        startSpy.complete(with: nil)
        processSpy.complete(with: value)
        
        XCTAssertNoDiff(processSpy.payloads, [false])
        XCTAssertNoDiff(receiveSpy.payloads, [value])
        
        XCTAssertNotNil(binding)
    }
    
    func test_tracker_binder_true() {
        
        typealias ProcessSpy = Spy<Bool, Value>
        typealias ReceiveSpy = CallSpy<Value, Void>
        
        let startSpy = StartSpy()
        let processSpy = ProcessSpy()
        let receiveSpy = ReceiveSpy()
        let scheduler: AnySchedulerOf<DispatchQueue> = .immediate
        
        let tracker = OperationTrackerModel(
            start: startSpy.process(completion:),
            scheduler: scheduler
        )
        let publisher = tracker.$state
            .compactMap(\.isTerminated)
            .eraseToAnyPublisher()
        
        let binder = StateValueBinder(
            publisher: publisher,
            process: processSpy.process(_:completion:),
            receive: receiveSpy.call(payload:)
        )
        let binding = binder.bind()
        
        tracker.event(.start)
        
        let response = makeResponse()
        let value = makeValue()
        
        startSpy.complete(with: response)
        processSpy.complete(with: value)
        
        XCTAssertNoDiff(processSpy.payloads, [true])
        XCTAssertNoDiff(receiveSpy.payloads, [value])
        
        XCTAssertNotNil(binding)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OperationTrackerBinder<ResponseSpy, Response>
    private typealias StartSpy = Spy<Void, Response?>
    private typealias ResponseSpy = CallSpy<Response?, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        startSpy: StartSpy,
        responseSpy: ResponseSpy
    ) {
        let startSpy = StartSpy()
        let responseSpy = ResponseSpy()
        let sut = SUT(
            start: startSpy.process(completion:),
            client: .init(),
            receive: { _ in { responseSpy.call(payload: $0) }},
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(startSpy, file: file, line: line)
        trackForMemoryLeaks(responseSpy, file: file, line: line)
        
        return (sut, startSpy, responseSpy)
    }
    
    private struct Response: Equatable {
        
        let value: String
    }
    
    private func makeResponse(
        _ value: String = anyMessage()
    ) -> Response {
        
        return .init(value: value)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
}
