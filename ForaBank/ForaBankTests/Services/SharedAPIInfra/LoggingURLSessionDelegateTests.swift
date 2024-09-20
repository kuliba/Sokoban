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
        let url = anyURL()
        let task = session.dataTask(with: .init(url: url))
        
        sut.urlSession?(session, task: task, didCompleteWithError: URLSessionDelegateError())
        
        XCTAssertNoDiff(spy.events.map(\.level), [.error])
        XCTAssertNoDiff(spy.events.map(\.category), [.network])
        XCTAssertNoDiff(spy.events.map(\.message), ["URLSessionTask: Optional(\(url.absoluteString)) did complete with error: session error"])
    }
    
    func test_didCompleteWithError_nil_shouldLogEvent() {
        
        let (sut, spy, session) = makeSUT()
        let url = anyURL()
        let task = session.dataTask(with: .init(url: url))
        
        sut.urlSession?(session, task: task, didCompleteWithError: nil)

        XCTAssertNoDiff(spy.events.map(\.level), [.error])
        XCTAssertNoDiff(spy.events.map(\.category), [.network])
        XCTAssertNoDiff(spy.events.map(\.message), ["URLSessionTask: Optional(\(url.absoluteString)) did complete with error: no error"])
    }
    
    // MARK: - Helpers
    
    final class URLSessionDelegateTask: URLSessionTask {}
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: URLSessionTaskDelegate,
        spy: LoggerSpy,
        session: URLSession
    ) {
        let spy = LoggerSpy()
        let sut = LoggingURLSessionDelegate(log: spy.log(level:category:message:file:line:))
        let session = URLSession.shared
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy, session)
    }
    
    private struct URLSessionDelegateError: LocalizedError {
        
        var errorDescription: String? { "session error" }
    }
}

final class LoggerSpy: LoggerAgentProtocol {
    
    typealias Event = (level: LoggerAgentLevel, category: LoggerAgentCategory, message: String)
    
    private(set) var events = [Event]()
    var callCount: Int { events.count }
    
    func log(level: LoggerAgentLevel, category: LoggerAgentCategory, message: String, file: StaticString, line: UInt) {
        
        events.append((level, category, message))
    }
}
