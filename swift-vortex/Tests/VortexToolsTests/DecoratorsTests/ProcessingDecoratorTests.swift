//
//  ProcessingDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

import VortexTools
import XCTest

final class ProcessingDecoratorTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, decoratee, processor) = makeSUT()
        
        XCTAssertEqual(decoratee.callCount, 0)
        XCTAssertEqual(processor.callCount, 0)
    }
    
    // MARK: - load
    
    func test_load_shouldCallDecorateeWithPayload() {
        
        let payload = makePayload()
        let (sut, decoratee, _) = makeSUT()
        
        sut.load(payload) { _ in }
        
        XCTAssertNoDiff(decoratee.payloads, [payload])
    }
    
    func test_load_shouldNotCallProcessorOnDecorateeFailure() {
        
        let (sut, decoratee, processor) = makeSUT()
        
        sut.load(makePayload()) { _ in }
        decoratee.complete(with: nil)
        
        XCTAssertTrue(processor.payloads.isEmpty)
    }
    
    func test_load_shouldCallProcessorWithDecorateeSuccess() {
        
        let response = makeResponse()
        let (sut, decoratee, processor) = makeSUT()
        
        sut.load(makePayload()) { _ in }
        decoratee.complete(with: response)
        
        XCTAssertNoDiff(processor.payloads, [response])
    }
    
    func test_load_shouldDeliverFailureOnDecorateeFailure() {
        
        let (sut, decoratee, _) = makeSUT()
        
        expect(sut: sut, toDeliver: nil) {
            
            decoratee.complete(with: nil)
        }
    }
    
    func test_load_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        (sut, decoratee, _) = makeSUT()
        var result: Response?
        
        sut?.load(makePayload()) { result = $0 }
        sut = nil
        decoratee.complete(with: nil)
        
        XCTAssertNil(result)
    }
    
    func test_load_shouldDeliverFailureOnDecorateeSuccessProcessorFailure() {
        
        let (sut, decoratee, processor) = makeSUT()
        
        expect(sut: sut, toDeliver: nil) {
            
            decoratee.complete(with: makeResponse())
            processor.complete(with: nil)
        }
    }
    
    func test_load_shouldNotDeliverProcessorResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        let processor: Processor
        (sut, decoratee, processor) = makeSUT()
        var result: Response?
        
        sut?.load(makePayload()) { result = $0 }
        decoratee.complete(with: makeResponse())
        sut = nil
        processor.complete(with: nil)
        
        XCTAssertNil(result)
    }
    
    func test_load_shouldDeliverResponseOnDecorateeSuccessProcessorSuccess() {
        
        let response = makeResponse()
        let (sut, decoratee, processor) = makeSUT()
        
        expect(sut: sut, toDeliver: response) {
            
            decoratee.complete(with: response)
            processor.complete(with: response)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ProcessingDecorator<Payload, Response>
    private typealias Decoratee = Spy<Payload, Response?>
    private typealias Processor = Spy<Response, Response?>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: Decoratee,
        processor: Processor
    ) {
        let decoratee = Decoratee()
        let processor = Processor()
        let sut = SUT(
            decoratee: decoratee.process,
            processor: processor.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        
        return (sut, decoratee, processor)
    }
    
    private struct Payload: Equatable {
        
        let value: String
    }
    
    private func makePayload(
        _ value: String = anyMessage()
    ) -> Payload {
        
        return .init(value: value)
    }
    
    private struct Response: Equatable {
        
        let value: String
    }
    
    private func makeResponse(
        _ value: String = anyMessage()
    ) -> Response {
        
        return .init(value: value)
    }
    
    private func expect(
        sut: SUT,
        with payload: Payload? = nil,
        toDeliver expected: Response?,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        sut.load(payload ?? makePayload()) {
            
            XCTAssertNoDiff($0, expected, "Expected \(String(describing: expected)), but got \(String(describing: $0)) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
