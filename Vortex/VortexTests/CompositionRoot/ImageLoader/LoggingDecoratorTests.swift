//
//  LoggingDecoratorTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.07.2024.
//

@testable import ForaBank
import ForaTools
import XCTest

final class LoggingDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        var logs = [String]()
        let (_, decoratee) = makeSUT { _, message, _,_ in
            
            logs.append(message)
        }
        
        XCTAssertTrue(logs.isEmpty)
        XCTAssertEqual(decoratee.callCount, 0)
    }
    
    func test_load_shouldLogRequest() {
        
        var logs = [(LoggerAgentLevel, String, StaticString, UInt)]()
        let log: SUT.Log = { level, message, file, line in
            
            logs.append((level, message, file, line))
        }
        let (sut, _) = makeSUT(log: log)
        
        sut.load(42) { _ in }
        
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.0, .info)
        XCTAssertEqual(logs.first?.1, "Load request: 42.")
    }
    
    func test_load_shouldLogResultSuccess() {
        
        var logs = [(LoggerAgentLevel, String, StaticString, UInt)]()
        let log: SUT.Log = { level, message, file, line in
            
            logs.append((level, message, file, line))
        }
        let (sut, decoratee) = makeSUT(log: log)
        
        var capturedResponse: Result<Response, LoadError>?
        sut.load(42) { capturedResponse = $0 }
        decoratee.complete(with: .success("Test Response"))
        
        XCTAssertEqual(logs.count, 2)
        XCTAssertEqual(logs.last?.0, .info)
        XCTAssertEqual(logs.last?.1, "Load result: success(\"Test Response\").")
        XCTAssertEqual(capturedResponse, .success("Test Response"))
    }
    
    func test_load_shouldLogResultFailure() throws {
        
        var logs = [(LoggerAgentLevel, String, StaticString, UInt)]()
        let log: SUT.Log = { level, message, file, line in
            
            logs.append((level, message, file, line))
        }
        let (sut, decoratee) = makeSUT(log: log)
        
        var capturedResponse: Result<Response, LoadError>?
        sut.load(42) { capturedResponse = $0 }
        decoratee.complete(with: .failure(.init()))
        
        XCTAssertEqual(logs.count, 2)
        XCTAssertEqual(logs.last?.0, .info)
        try XCTAssertTrue(XCTUnwrap(logs.last?.1.contains("Load result: failure")))
        XCTAssertEqual(capturedResponse, .failure(.init()))
    }
    
    func test_load_shouldDeliverDecorateeResultSuccess() {
        
        let response = anyMessage()
        let (sut, decoratee) = makeSUT(log: { _,_,_,_ in })
        let exp = expectation(description: "wait for completion")
        
        sut.load(42) {
            
            switch $0 {
            case .failure:
                XCTFail("Expected success, got failure instead.")
                
            case let .success(success):
                XCTAssertNoDiff(success, response)
            }
            
            exp.fulfill()
        }
        decoratee.complete(with: .success(response))
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldDeliverDecorateeResultFailure() {
        
        let (sut, decoratee) = makeSUT(log: { _,_,_,_ in })
        let exp = expectation(description: "wait for completion")
        
        sut.load(42) {
            
            switch $0 {
            case let .failure(failure):
                XCTAssertNoDiff(failure, .init())
                
            case let .success(success):
                XCTFail("Expected failure, got \(success) instead.")
            }
            
            exp.fulfill()
        }
        decoratee.complete(with: .failure(.init()))
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoggingDecorator<Payload, Result<Response, LoadError>>
    private typealias Payload = Int
    private typealias Response = String
    private typealias Decoratee = Spy<Payload, Response, LoadError>
    
    private func makeSUT(
        log: @escaping SUT.Log,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: Decoratee
    ) {
        
        let decoratee = Decoratee()
        let sut = SUT(decoratee: decoratee, log: log)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        
        return (sut, decoratee)
    }
    
    private struct LoadError: Error, Equatable {}
}

extension Spy: ForaTools.Loader {
    
    func load(
        _ payload: Payload,
        _ completion: @escaping (Result) -> Void
    ) {
        process(payload, completion: completion)
    }
}
