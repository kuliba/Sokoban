//
//  RequestPoolerTests.swift
//
//
//  Created by Igor Malyarov on 11.03.2024.
//

final class RequestPooler<Request: Hashable, Response> {

    private let perform: Perform
    
    init(perform: @escaping Perform) {
        
        self.perform = perform
    }
}

extension RequestPooler {
    
    func handleRequest(
        _ request: Request,
        _ completion: @escaping Completion
    ) {
        // ...
    }
}

extension RequestPooler {
    
    typealias Perform = (Request, @escaping (Response) -> Void) -> Void
    typealias Completion = (Response) -> Void
}

import XCTest

final class RequestPoolerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborator() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RequestPooler<Request, Response>
    private typealias PerformSpy = Spy<Request, Response>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: PerformSpy
    ) {
        let spy = PerformSpy()
        let sut = SUT(perform: spy.process(_:completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}

private struct Request: Hashable {
    
    var id: String
    
    init(id: String = UUID().uuidString) {
        
        self.id = id
    }
}

private struct Response: Equatable {
    
    var value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}
