//
//  OperationTrackerBinderTests.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

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
    
    // MARK: - Helpers
    
    private typealias SUT = OperationTrackerBinder<ResponseSpy, Response>
    private typealias StartSpy = Spy<Void, Response>
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
}
