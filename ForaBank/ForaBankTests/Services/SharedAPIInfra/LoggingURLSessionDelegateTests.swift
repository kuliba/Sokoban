//
//  LoggingURLSessionDelegateTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 31.07.2023.
//

@testable import ForaBank
import XCTest

final class LoggingURLSessionDelegateTests: XCTestCase {
    
    func test_didBecomeInvalidWithError_shouldLogEvent() {
        
        let (sut, spy, session) = makeSUT()
        
        sut.urlSession?(session, didBecomeInvalidWithError: URLSessionDelegateError())
        
        XCTAssertNoDiff(spy.events.map(\.level), [.error])
        XCTAssertNoDiff(spy.events.map(\.category), [.network])
        XCTAssertNoDiff(spy.events.map(\.message), ["URL Session did become invalid with error: session error"])
    }
    
    func test_didBecomeInvalidWithError_nil_shouldLogEvent() {
        
        let (sut, spy, session) = makeSUT()
        
        sut.urlSession?(session, didBecomeInvalidWithError: nil)
        
        XCTAssertNoDiff(spy.events.map(\.level), [.error])
        XCTAssertNoDiff(spy.events.map(\.category), [.network])
        XCTAssertNoDiff(spy.events.map(\.message), ["URL Session did become invalid with error: no error"])
    }
    
    func test_didCompleteWithError_shouldLogEvent() {
        
        let (sut, spy, session) = makeSUT()
        let task = session.dataTask(with: .init(url: anyURL()))
        
        sut.urlSession?(session, task: task, didCompleteWithError: URLSessionDelegateError())
        
        XCTAssertNoDiff(spy.events.map(\.level), [.error])
        XCTAssertNoDiff(spy.events.map(\.category), [.network])
        XCTAssertNoDiff(spy.events.map(\.message), ["URLSessionTask: Optional(any.url) did complete with error: session error"])
    }
    
    func test_didCompleteWithError_nil_shouldLogEvent() {
        
        let (sut, spy, session) = makeSUT()
        let task = session.dataTask(with: .init(url: anyURL()))
        
        sut.urlSession?(session, task: task, didCompleteWithError: nil)

        XCTAssertNoDiff(spy.events.map(\.level), [.error])
        XCTAssertNoDiff(spy.events.map(\.category), [.network])
        XCTAssertNoDiff(spy.events.map(\.message), ["URLSessionTask: Optional(any.url) did complete with error: no error"])
    }
    
    // MARK: - Helpers
    
    final class URLSessionDelegateTask: URLSessionTask {}
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: URLSessionTaskDelegate,
        spy: LoggingSpy,
        session: URLSession
    ) {
        let spy = LoggingSpy()
        let sut = LoggingURLSessionDelegate(log: spy.log(level:category:message:file:line:))
        let session = URLSession.shared
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy, session)
    }
    
    private final class LoggingSpy: LoggerAgentProtocol {
        
        typealias Event = (level: LoggerAgentLevel, category: LoggerAgentCategory, message: String)
        
        private(set) var events = [Event]()
        
        func log(level: LoggerAgentLevel, category: LoggerAgentCategory, message: String, file: StaticString, line: UInt) {
            
            events.append((level, category, message))
        }
    }
    
    private struct URLSessionDelegateError: LocalizedError {
        
        var errorDescription: String? { "session error" }
    }
}
