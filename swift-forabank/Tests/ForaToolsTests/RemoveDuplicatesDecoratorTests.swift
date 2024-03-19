//
//  RemoveDuplicatesDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 19.03.2024.
//

final class RemoveDuplicatesDecorator<Payload, Response>
where Payload: Equatable {
    
    private var lastPayload: Payload?
    
    func callAsFunction(_ f: @escaping F) -> F {
        
        return { [weak self] payload, completion in
            
            guard let self else { return }
            
            guard payload != lastPayload else { return }
            
            lastPayload = payload
            f(payload, completion)
        }
    }
}
extension RemoveDuplicatesDecorator {
    
    typealias Completion = (Response) -> Void
    typealias F = (Payload, @escaping Completion) -> Void
}

import XCTest

final class RemoveDuplicatesDecoratorTests: XCTestCase {
    
    func test_shouldNotCallTwiceWithSamePayload() {
        
        let payload = makePayload()
        let (sut, spy) = makeSUT()
        
        sut(spy.process)(payload) { _ in }
        sut(spy.process)(payload) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [payload])
    }
    
    func test_shouldCallWithDifferentPayload() {
        
        let firstPayload = makePayload()
        let lastPayload = makePayload()
        let (sut, spy) = makeSUT()
        
        sut(spy.process)(firstPayload) { _ in }
        sut(spy.process)(lastPayload) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [firstPayload, lastPayload])
    }
    
    func test_shouldDeliverResponse() {
        
        let payload = makePayload()
        let (sut, spy) = makeSUT()
        let response = makeResponse()
        var receivedResponse: Response?
        let exp = expectation(description: "wait for completion")
        
        sut(spy.process)(payload) {
            
            receivedResponse = $0
            exp.fulfill()
        }
        spy.complete(with: response)
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedResponse, response)
    }
    
    func test_shouldNotCallOnInstanceDeallocation() {
        
        let firstPayload = makePayload()
        let lastPayload = makePayload()
        var sut: SUT?
        let spy: Caller
        (sut, spy) = makeSUT()
        
        sut?(spy.process)(firstPayload) { _ in }
        sut = nil
        spy.complete(with: .init())
        sut?(spy.process)(lastPayload) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [firstPayload])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RemoveDuplicatesDecorator<Payload, Response>
    private typealias Caller = Spy<Payload, Response>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Caller
    ) {
        let spy = Caller()
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
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
    
    var value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}

private struct Response: Equatable {
    
    var value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}
