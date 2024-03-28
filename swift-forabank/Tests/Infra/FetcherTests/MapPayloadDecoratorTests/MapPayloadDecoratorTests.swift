//
//  MapPayloadDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

final class MapPayloadDecorator<Payload, NewPayload, Response> {
    
    private let decoratee: Decoratee
    private let mapPayload: MapPayload
    
    init(
        decoratee: @escaping Decoratee,
        mapPayload: @escaping (Payload) -> NewPayload
    ) {
        self.decoratee = decoratee
        self.mapPayload = mapPayload
    }
}

extension MapPayloadDecorator {
    
    func callAsFunction(
        _ payload: Payload,
        completion: @escaping DecorateeCompletion
    ) {
        decoratee(mapPayload(payload)) { [weak self] in
            
            guard self != nil else { return }
            
            completion($0)
        }
    }
}

extension MapPayloadDecorator {
    
    typealias DecorateeCompletion = (Response) -> Void
    typealias Decoratee = (NewPayload, @escaping DecorateeCompletion) -> Void
    typealias MapPayload = (Payload) -> NewPayload
}

import XCTest

final class MapPayloadDecoratorTests: XCTestCase {
    
    func test_shouldCallWithNewPayload() {
        
        let newPayload = makeNewPayload("abcd")
        let (sut, decoratee) = makeSUT(mapPayload: { _ in newPayload })
        
        sut.callAsFunction(makePayload(123)) { _ in }
        
        XCTAssertEqual(decoratee.payloads, [newPayload])
    }
    
    func test_shouldDeliverDecorateeResult() {
        
        let response = makeResponse()
        let (sut, decoratee) = makeSUT()
        let exp = expectation(description: "wait for completion")
        var receivedResponses = [Response]()
        
        sut.callAsFunction(makePayload(123)) {
            
            receivedResponses.append($0)
            exp.fulfill()
        }
        
        decoratee.complete(with: response)
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedResponses, [response])
    }
    
    func test_shouldNotDeliverDecorateeResultOnInstanceDeallocation() {
        
        let response = makeResponse()
        var sut: SUT?
        let decoratee: Decoratee
        (sut, decoratee) = makeSUT()
        var receivedResponses = [Response]()
        
        sut?.callAsFunction(makePayload(123)) {
            
            receivedResponses.append($0)
        }
        sut = nil
        decoratee.complete(with: response)
        
        XCTAssert(receivedResponses.isEmpty)
    }
    
    func test_shouldCallAsFunction() {
        
        let response = makeResponse()
        let decoratee = Decoratee()
        let newPayload = makeNewPayload("abcd")
        let sut = SUT(
            decoratee: decoratee.process(_:completion:),
            mapPayload: { _ in newPayload }
        )
        var receivedResponses = [Response]()
        
        sut(makePayload(123)) { receivedResponses.append($0) }
        decoratee.complete(with: response)
        
        XCTAssertNoDiff(decoratee.payloads, [newPayload])
        XCTAssertNoDiff(receivedResponses, [response])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MapPayloadDecorator<Payload, NewPayload, Response>
    private typealias Decoratee = Spy<NewPayload, Response>
    
    private func makeSUT(
        mapPayload: @escaping (Payload) -> NewPayload = { .init(value: "\($0.value)") },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: Decoratee
    ) {
        let decoratee = Decoratee()
        let sut = SUT(
            decoratee: decoratee.process,
            mapPayload: mapPayload
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        
        return (sut, decoratee)
    }
}

private struct Payload: Equatable {
    
    let value: Int
}

private struct NewPayload: Equatable {
    
    let value: String
}

private struct Response: Equatable {
    
    let value: String
}

private func makePayload(
    _ value: Int
) -> Payload {
    
    .init(value: value)
}

private func makeNewPayload(
    _ value: String = UUID().uuidString
) -> NewPayload {
    
    .init(value: value)
}

private func makeResponse(
    _ value: String = UUID().uuidString
) -> Response {
    
    .init(value: value)
}
