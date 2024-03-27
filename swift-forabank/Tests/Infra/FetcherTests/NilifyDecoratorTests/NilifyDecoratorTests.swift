//
//  NilifyDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 27.03.2024.
//

import XCTest

final class NilifyDecorator<Payload, Response, Failure: Error> {
    
    private let decoratee: Decoratee
    
    init(decoratee: @escaping Decoratee) {
        
        self.decoratee = decoratee
    }
}

extension NilifyDecorator {
    
    func process(
        _ payload: Payload,
        _ completion: @escaping Completion
    ) {
        decoratee(payload) { [weak self] in
            
            guard self != nil else { return }
            
            completion(try? $0.get())
        }
    }
}

extension NilifyDecorator {
    
    typealias DecorateeCompletion = (Result<Response, Failure>) -> Void
    typealias Decoratee = (Payload, @escaping DecorateeCompletion) -> Void
    
    typealias Completion = (Response?) -> Void
}

final class NilifyDecoratorTests: XCTestCase {
    
    func test_shouldCallWithPayload() {
        
        let payload = makePayload()
        let (sut, decoratee) = makeSUT()
        
        sut.process(payload) { _ in }
        
        XCTAssertNoDiff(decoratee.payloads, [payload])
    }
    
    func test_shouldDeliverNilOnFailure() {
        
        expect(nil, on: .failure(anyError()))
    }
    
    func test_shouldDeliverResponseOnSuccess() {
        
        let response = makeResponse()
        expect(response, on: .success(response))
    }
    
    func test_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        (sut, decoratee) = makeSUT()
        var receivedResponses = [Response?]()
        
        sut?.process(makePayload()) { receivedResponses.append($0) }
        sut = nil
        decoratee.complete(with: .failure(anyError()))
        
        XCTAssert(receivedResponses.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NilifyDecorator<Payload, Response, Error>
    private typealias Decoratee = Spy<Payload, Result<Response, Error>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: Decoratee
    ) {
        let decoratee = Decoratee()
        let sut = SUT(decoratee: decoratee.process)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        
        return (sut, decoratee)
    }
    
    private func makePayload(
        value: String = UUID().uuidString
    ) -> Payload {
        
        .init(value: value)
    }
    
    private func makeResponse(
        value: String = UUID().uuidString
    ) -> Response {
        
        .init(value: value)
    }
    
    private struct Payload: Equatable {
        
        let value: String
    }
    
    private struct Response: Equatable {
        
        let value: String
    }
    
    private func expect(
        with payload: Payload? = nil,
        _ expectedResponse: Response?,
        on decorateeResult: Result<Response, Error>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        let (sut, decoratee) = makeSUT()
        
        sut.process(payload ?? makePayload()) {
            
            XCTAssertNoDiff($0, expectedResponse, "\nExpected \(String(describing: expectedResponse)), got \(String(describing: $0)) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        decoratee.complete(with: decorateeResult)
        
        wait(for: [exp], timeout: 1)
    }
}
