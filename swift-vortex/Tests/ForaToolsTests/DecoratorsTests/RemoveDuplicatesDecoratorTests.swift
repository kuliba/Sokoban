//
//  RemoveDuplicatesDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 19.03.2024.
//

import ForaTools
import XCTest

final class RemoveDuplicatesDecoratorTests: XCTestCase {
    
    func test_removeDuplicates_shouldNotCallTwiceWithSamePayload() {
        
        let payload = makePayload()
        let (sut, spy) = makeSUT()
        
        sut.removeDuplicates(spy.process)(payload) { _ in }
        sut.removeDuplicates(spy.process)(payload) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [payload])
    }
    
    func test_removeDuplicates_shouldCallWithDifferentPayload() {
        
        let firstPayload = makePayload()
        let lastPayload = makePayload()
        let (sut, spy) = makeSUT()
        
        sut.removeDuplicates(spy.process)(firstPayload) { _ in }
        sut.removeDuplicates(spy.process)(lastPayload) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [firstPayload, lastPayload])
    }
    
    func test_removeDuplicates_shouldDeliverResponse() {
        
        let payload = makePayload()
        let (sut, spy) = makeSUT()
        let response = makeResponse()
        var receivedResponse: Response?
        let exp = expectation(description: "wait for completion")
        
        sut.removeDuplicates(spy.process)(payload) {
            
            receivedResponse = $0
            exp.fulfill()
        }
        spy.complete(with: response)
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedResponse, response)
    }
    
    func test_removeDuplicates_shouldNotHaveRaceConditionWithConcurrentAccess() {
        
        let payload = makePayload()
        let (sut, spy) = makeSUT()
        
        let exp = expectation(description: "Complete multiple concurrent calls")
        let iterations = 20
        exp.expectedFulfillmentCount = iterations
        
        var lastPayloadProcessed: Payload?
        let concurrentQueue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        
        for _ in 0..<iterations {
            
            concurrentQueue.async {
                
                sut.removeDuplicates { payload, completion in
                    
                    Thread.sleep(forTimeInterval: 0.001)
                    spy.process(payload, completion: completion)
                    lastPayloadProcessed = payload
                }(payload) { _ in exp.fulfill() }
                spy.complete(with: makeResponse())
            }
        }
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertNoDiff(lastPayloadProcessed, payload)
    }
    
    func test_removeDuplicates_shouldNotCallOnInstanceDeallocation() {
        
        let firstPayload = makePayload()
        let lastPayload = makePayload()
        var sut: SUT?
        let spy: Caller
        (sut, spy) = makeSUT()
        
        sut?.removeDuplicates(spy.process)(firstPayload) { _ in }
        sut = nil
        spy.complete(with: .init())
        sut?.removeDuplicates(spy.process)(lastPayload) { _ in }
        
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
