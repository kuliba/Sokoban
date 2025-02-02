//
//  UpdatingLoadDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 19.01.2025.
//

import XCTest
import VortexTools

final class UpdatingLoadDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, decoratee, update) = makeSUT()
        
        XCTAssertEqual(decoratee.callCount, 0)
        XCTAssertEqual(update.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldCallUpdateWithLoading() {
        
        let payload = makePayload()
        let (sut, _, update) = makeSUT()
        
        sut.load(payload) { _ in }
        
        XCTAssertNoDiff(update.payloads, [
            .init(payload: payload, state: .loading)
        ])
    }
    
    func test_load_shouldCallDecorateeWithPayload() {
        
        let payload = makePayload()
        let (sut, decoratee, _) = makeSUT()
        
        sut.load(payload) { _ in }
        
        XCTAssertNoDiff(decoratee.payloads, [payload])
    }
    
    func test_load_shouldCallUpdateWithFailedOnFailure() {
        
        let payload = makePayload()
        let (sut, decoratee, update) = makeSUT()
        
        expect(sut: sut, with: payload, toDeliver: .failure(anyError())) {
            
            decoratee.complete(with: .failure(anyError()))
            XCTAssertNoDiff(update.payloads, [
                .init(payload: payload, state: .loading),
                .init(payload: payload, state: .failed)
            ])
        }
    }
    
    func test_load_shouldDeliverFailureOnFailure() {
        
        let (sut, decoratee, _) = makeSUT()
        
        expect(sut: sut, with: makePayload(), toDeliver: .failure(anyError())) {
            
            decoratee.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldCallUpdateWithCompletedOnSuccess() {
        
        let payload = makePayload()
        let response = makeResponse()
        let (sut, decoratee, update) = makeSUT()
        
        expect(sut: sut, with: payload, toDeliver: .success(response)) {
            
            decoratee.complete(with: .success(response))
            XCTAssertNoDiff(update.payloads, [
                .init(payload: payload, state: .loading),
                .init(payload: payload, state: .completed)
            ])
        }
    }
    
    func test_load_shouldDeliverResponseOnSuccess() {
        
        let response = makeResponse()
        let (sut, decoratee, _) = makeSUT()
        
        expect(sut: sut, with: makePayload(), toDeliver: .success(response)) {
            
            decoratee.complete(with: .success(response))
        }
    }
    
    func test_load_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        (sut, decoratee, _) = makeSUT()
        var received = [Result<Response, Error>]()
        
        sut?.load(makePayload()) { received.append($0) }
        sut = nil
        decoratee.complete(with: .failure(anyError()))
        
        XCTAssertTrue(received.isEmpty)
    }
    
    func test_load_shouldNotDeliverCompletionStateOnInstanceDeallocation() {
        
        let payload = makePayload()
        var sut: SUT?
        let decoratee: Decoratee
        let update: UpdateSpy
        (sut, decoratee, update) = makeSUT()
        var received = [Result<Response, Error>]()
        
        sut?.load(payload) { received.append($0) }
        sut = nil
        decoratee.complete(with: .failure(anyError()))
        
        XCTAssertNoDiff(update.payloads, [
            .init(payload: payload, state: .loading)
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UpdatingLoadDecorator<Payload, Response>
    private typealias Decoratee = Spy<Payload, Result<Response, Error>>
    private typealias UpdateSpy = CallSpy<Update, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: Decoratee,
        update: UpdateSpy
    ) {
        let decoratee = Decoratee()
        let update = UpdateSpy(stubs: .init(repeating: (), count: 10))
        let sut = SUT(
            decoratee: decoratee.process,
            update: { update.call(payload: .init(payload: $0, state: $1)) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(update, file: file, line: line)
        
        return (sut, decoratee, update)
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
    
    private struct Update: Equatable {
        
        let payload: Payload
        let state: LoadState
    }
    
    private func expect(
        sut: SUT,
        with payload: Payload,
        toDeliver expectedResult: Result<Response, Error>,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for process completion")
        
        sut.load(payload) {
            
            switch ($0, expectedResult) {
            case (.failure, .failure):
                break
                
            case let (.success(received), .success(expected)):
                XCTAssertNoDiff(received, expected, "Expected \(expected) failed parameters, but got \(received) instead.", file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) failed parameters, but got \($0) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
