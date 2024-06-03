//
//  LoggingRemoteServiceDecoratorTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.11.2023.
//

@testable import ForaBank
import XCTest

final class LoggingRemoteServiceDecoratorTests: XCTestCase {
    
    func test_init_shouldNotMessageLogger() {
        
        let (_, spy, _) = makeSUT()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_shouldLogURLRequestCreation() {
        
        let url = anyURL()
        let (sut, spy, _) = makeSUT(
            createRequestStub: .success(.init(url: url))
        )
        let remoteService = sut.remoteService
        
        remoteService.process(1) { _ in }
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "RemoteService: Created request: URL: \(url.absoluteString), Method: GET, Headers: [], Body: empty body.")
        ])
    }
    
    func test_shouldLogURLRequestNonNilBodyCreation() throws {
        
        let url = anyURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = try anyJSON("abcdef")
        let (sut, spy, _) = makeSUT(
            createRequestStub: .success(urlRequest)
        )
        let remoteService = sut.remoteService
        
        remoteService.process(1) { _ in }
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, #"RemoteService: Created request: URL: \#(url.absoluteString), Method: GET, Headers: [], Body: {"data":"abcdef"}."#),
        ])
    }
    
    func test_shouldLogShouldLogMapResponseSuccess() {
        
        let url = anyURL()
        let (sut, spy, perform) = makeSUT(
            createRequestStub: .success(.init(url: url))
        )
        let remoteService = sut.remoteService
        let exp = expectation(description: "wait for completion")
        
        remoteService.process(1) { _ in
            exp.fulfill()
        }
        perform.complete(with: .success((anyData(), anyHTTPURLResponse())))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "RemoteService: Created request: URL: \(url.absoluteString), Method: GET, Headers: [], Body: empty body."),
            .init(.debug, .cache, "RemoteService: received response with statusCode 200, data: n/a.\nRemoteService: mapResponse success: String.")
        ])
    }
    
    func test_shouldLogShouldLogMapResponseFailure() {
        
        let url = anyURL()
        let (sut, spy, perform) = makeSUT(
            createRequestStub: .success(.init(url: url)),
            mapResponseStub: .failure(anyError("any"))
        )
        let remoteService = sut.remoteService
        let exp = expectation(description: "wait for completion")
        
        remoteService.process(1) { _ in
            exp.fulfill()
        }
        perform.complete(with: .success((anyData(), anyHTTPURLResponse())))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "RemoteService: Created request: URL: \(url.absoluteString), Method: GET, Headers: [], Body: empty body."),
            .init(.debug, .cache, "RemoteService: received response with statusCode 200, data: n/a.\nRemoteService: mapResponse failure: any.")
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoggingRemoteServiceDecorator<Int, String, Error, Error>
    private typealias Perform = PerformSpy<URLRequest, (Data, HTTPURLResponse)>
    
    private func makeSUT(
        createRequestStub: Result<URLRequest, Error> = .success(.init(url: anyURL())),
        mapResponseStub: Result<String, Error> = .success("abc"),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LogSpy,
        perform: Perform
    ) {
        let spy = LogSpy()
        let perform = Perform()
        let sut = SUT(
            createRequest: { _ in try createRequestStub.get() },
            performRequest: perform.perform,
            mapResponse: { _ in mapResponseStub },
            log: { message,_,_ in spy.log(message) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(perform, file: file, line: line)
        
        return (sut, spy, perform)
    }
    
    private final class PerformSpy<Payload, Response> {
        
        typealias Message = (payload: Payload, completion: Completion)
        typealias Result = Swift.Result<Response, Error>
        typealias Completion = (Result) -> Void
        
        private(set) var messages = [Message]()
        
        func perform(
            payload: Payload,
            completion: @escaping Completion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(
            with result: Result,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private func anyJSON(
        _ value: String = UUID().uuidString
    ) throws -> Data {
        
        try JSONSerialization.data(withJSONObject: [
            "data": value
        ] as [String: String])
    }
    
    private func anyError(_ message: String = "any error") -> Error {
        
        AnyError(message: message)
    }
    
    private struct AnyError: Error, CustomStringConvertible {
        
        let message: String
        
        var description: String { message }
    }
}
