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
        
        let (sut, spy, _) = makeSUT()
        let remoteService = sut.remoteService
        
        remoteService.process(1) { _ in }
        
        XCTAssertNoDiff(spy.messages, [
            "RemoteService: Created GET request any.url for input \"1\"."
        ])
    }
    
    func test_shouldLogURLRequestNonNilBodyCreation() throws {
        
        var urlRequest = URLRequest(url: anyURL())
        urlRequest.httpBody = try anyJSON("abcdef")
        let (sut, spy, _) = makeSUT(
            createRequestStub: .success(urlRequest)
        )
        let remoteService = sut.remoteService
        
        remoteService.process(1) { _ in }
        
        XCTAssertNoDiff(spy.messages, [
            "RemoteService: Created GET request any.url for input \"1\".",
            "RemoteService: request body: {\"data\":\"abcdef\"}"
        ])
    }
    
    func test_shouldLogShouldLogMapResponseSuccess() {
        
        let (sut, spy, perform) = makeSUT()
        let remoteService = sut.remoteService
        let exp = expectation(description: "wait for completion")
        
        remoteService.process(1) { _ in
            exp.fulfill()
        }
        perform.complete(with: .success((anyData(), anyHTTPURLResponse())))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            "RemoteService: Created GET request any.url for input \"1\".",
            "RemoteService: mapResponse success: abc."
        ])
    }
    
    func test_shouldLogShouldLogMapResponseFailure() {
        
        let (sut, spy, perform) = makeSUT(mapResponseStub: .failure(anyError("any")))
        let remoteService = sut.remoteService
        let exp = expectation(description: "wait for completion")
        
        remoteService.process(1) { _ in
            exp.fulfill()
        }
        perform.complete(with: .success((anyData(), anyHTTPURLResponse())))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            "RemoteService: Created GET request any.url for input \"1\".",
            "RemoteService: mapResponse failure: any: statusCode: 200, data: nil."
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
    
    private final class LogSpy {
        
        private(set) var messages = [String]()
        
        func log(_ message: String) {
            
            self.messages.append(message)
        }
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
