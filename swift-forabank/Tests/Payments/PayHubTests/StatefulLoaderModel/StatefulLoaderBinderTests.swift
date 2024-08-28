//
//  StatefulLoaderBinderTests.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import PayHub
import XCTest

final class StatefulLoaderBinderTests: XCTestCase {
    
    func test_load_shouldEmitResponse() {
        
        let response = makeResponse()
        let (sut, loadSpy, responseSpy) = makeSUT()
        
        sut.load()
        loadSpy.complete(with: response)
        loadSpy.complete(with: response, at: 1)
        
        XCTAssertNoDiff(responseSpy.payloads, [response])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = StatefulLoaderBinder<ResponseSpy, Response>
    private typealias LoadSpy = Spy<Void, Response>
    private typealias ResponseSpy = CallSpy<Response?, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy,
        responseSpy: ResponseSpy
    ) {
        let loadSpy = LoadSpy()
        let responseSpy = ResponseSpy()
        let sut = SUT(
            load: loadSpy.process(completion:),
            client: .init(),
            receive: { _ in { responseSpy.call(payload: $0) }},
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(responseSpy, file: file, line: line)
        
        return (sut, loadSpy, responseSpy)
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
