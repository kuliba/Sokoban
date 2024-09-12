//
//  FireAndForgetDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 12.09.2024.
//

import ForaTools
import XCTest

final class FireAndForgetDecoratorTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, decoratee, decoration) = makeSUT()
        
        XCTAssertEqual(decoratee.callCount, 0)
        XCTAssertEqual(decoration.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - decorate
    
    func test_shouldCallDecorateeWithPayload() {
        
        let payload = makePayload()
        let (sut, decoratee, _) = makeSUT()
        
        sut(payload) { _ in }
        
        XCTAssertNoDiff(decoratee.payloads, [payload])
    }
    
    func test_shouldDeliverFailureOnDecorateeFailure() {
        
        let failure = makeFailure()
        let (sut, decoratee, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(failure)) {
            
            decoratee.complete(with: .failure(failure))
        }
    }
    
    func test_shouldDeliverSuccessOnDecorateeSuccess() {
        
        let response = makeResponse()
        let (sut, decoratee, _) = makeSUT()
        
        expect(sut, toDeliver: .success(response)) {
            
            decoratee.complete(with: .success(response))
        }
    }
    
    func test_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        (sut, decoratee, _) = makeSUT()
        let exp = expectation(description: "should not complete")
        exp.isInverted = true
        
        sut?(makePayload()) { _ in exp.fulfill() }
        sut = nil
        decoratee.complete(with: .failure(makeFailure()))
        
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_shouldNotCallDecorationOnDecorateeFailure() {
        
        let failure = makeFailure()
        let (sut, decoratee, decoration) = makeSUT()
        
        expect(sut, toDeliver: .failure(failure)) {
            
            decoratee.complete(with: .failure(failure))
            XCTAssertEqual(decoration.callCount, 0)
        }
    }
    
    func test_shouldCallDecorationOnDecorateeSuccess() {
        
        let response = makeResponse()
        let (sut, decoratee, decoration) = makeSUT()
        
        expect(sut, toDeliver: .success(response)) {
            
            decoratee.complete(with: .success(response))
            XCTAssertNoDiff(decoration.payloads, [response])
        }
    }
    
    func test_decorateeShouldCompleteBeforeDecoration() {
        
        let (sut, decoratee, decoration) = makeSUT()
        let decorateeExp = expectation(description: "wait for decoratee completion")
        let decorationExp = expectation(description: "wait for decoration completion")
        
        sut(makePayload()) { _ in decorateeExp.fulfill() }
        
        decoratee.complete(with: .success(makeResponse()))
        
        wait(for: [decorateeExp], timeout: 1)
        
        decoration.complete(with: ())
        decorationExp.fulfill()
        
        wait(for: [decorationExp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FireAndForgetDecorator<Payload, Response, Failure>
    private typealias Decoratee = Spy<Payload, Result<Response, Failure>>
    private typealias Decoration = Spy<Response, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: Decoratee,
        decoration: Decoration
    ) {
        let decoratee = Decoratee()
        let decoration = Decoration()
        let sut = SUT(
            decoratee: decoratee.process(_:completion:),
            decoration: decoration.process(payload:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(decoration, file: file, line: line)
        
        return (sut, decoratee, decoration)
    }
    
    private struct Failure: Error, Equatable {
        
        let value: String
    }
    
    private func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
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
        _ sut: SUT,
        with payload: Payload? = nil,
        toDeliver expectedResult: Result<Response, Failure>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut(payload ?? makePayload()) {
            
            XCTAssertNoDiff($0, expectedResult, "Expected \(expectedResult), got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
