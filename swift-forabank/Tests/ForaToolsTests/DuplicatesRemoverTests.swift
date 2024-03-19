//
//  DuplicatesRemoverTests.swift
//
//
//  Created by Igor Malyarov on 19.03.2024.
//

final class DuplicatesRemover<Payload, Response>
where Payload: Equatable {
    
    private let f: F
    private var lastPayload: Payload?
    
    init(_ f: @escaping F) {
        
        self.f = f
    }
    
    func callAsFunction(
        _ payload: Payload,
        _ completion: @escaping Completion
    ) {
        guard payload != lastPayload else { return }
        
        lastPayload = payload
        f(payload, completion)
    }
}

extension DuplicatesRemover {
    
    typealias Completion = (Response) -> Void
    typealias F = (Payload, @escaping Completion) -> Void
}

import XCTest

final class DuplicatesRemoverTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborator() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_shouldNotCallTwiceWithSamePayload() {
        
        let payload = makePayload()
        let (sut, spy) = makeSUT()
        
        sut(payload) { _ in }
        sut(payload) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [payload])
    }
    
    func test_shouldCallWithDifferentPayload() {
        
        let firstPayload = makePayload()
        let lastPayload = makePayload()
        let (sut, spy) = makeSUT()
        
        sut(firstPayload) { _ in }
        sut(lastPayload) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [firstPayload, lastPayload])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = DuplicatesRemover<Payload, Response>
    private typealias Caller = Spy<Payload, Response>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Caller
    ) {
        let spy = Caller()
        let sut = SUT(spy.process(_:completion:))
        
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

private struct Payload: Equatable {
    
    var value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}

private struct Response {
    
    var value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}
