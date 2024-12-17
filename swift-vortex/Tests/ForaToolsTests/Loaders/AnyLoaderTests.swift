//
//  AnyLoaderTests.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import ForaTools
import XCTest

final class AnyLoaderTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborator() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_load_shouldCallWithPayload() {
        
        let payload = anyPayload()
        let (sut, spy) = makeSUT()
        
        sut.load(payload) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [payload])
    }
    
    func test_load_shouldDeliverResponse() {
        
        let response = anyResponse()
        let (sut, spy) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: response) {
            
            spy.complete(with: response)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnyLoader<Payload, Response>
    private typealias LoadSpy = Spy<Payload, Response>
    
    private typealias Payload = Int
    private typealias Response = String
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LoadSpy
    ) {
        let spy = LoadSpy()
        let sut = SUT(spy.process(_:completion:))
        
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func anyPayload(
        _ value: Int = .random(in: 0...1_000)
    ) -> Payload {
        
        return value
    }
    
    private func anyResponse(
        _ value: String = UUID().uuidString
    ) -> Response {
        
        return value
    }
    
    private func assert(
        _ sut: SUT,
        with payload: Payload,
        toDeliver expected: Response,
        on action: () throws -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var result: Response?
        let exp = expectation(description: "wait for completion")
        
        sut.load(payload) {
            
            result = $0
            exp.fulfill()
        }
        
        try? action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(result, expected, file: file, line: line)
    }
}
