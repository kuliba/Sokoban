//
//  BatchLoaderTests.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import SerialComponents
import VortexTools
import XCTest

final class BatchLoaderTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, loadSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldNotCallLoad_onEmptyPayloads() {
        
        let (sut, loadSpy) = makeSUT()
        
        sut.load(payloads: []) { _ in }
        
        XCTAssertEqual(loadSpy.callCount, 0)
    }
    
    func test_load_shouldCallLoadWithPayload() {
        
        let payload = makePayload()
        let (sut, loadSpy) = makeSUT()
        
        sut.load(payloads: [payload]) { _ in }
        
        XCTAssertNoDiff(loadSpy.payloads, [payload])
    }
    
    func test_load_shouldCallLoadWithPayloads() {
        
        let (first, second) = (makePayload(), makePayload())
        let (sut, loadSpy) = makeSUT()
        
        sut.load(payloads: [first, second]) { _ in }
        loadSpy.complete(with: .failure(anyError()))
        
        XCTAssertNoDiff(loadSpy.payloads, [first, second])
    }
    
    
    func test_load_shouldDeliverEmpty_onEmptyLoad() {
        
        let (sut, _) = makeSUT()
        
        load(sut: sut) {
            XCTAssertNoDiff($0, .init(storage: [:], failed: []))
        } on: {}
    }
    
    func test_load_shouldCallLoadItemsWithPayload_onOneLoadPayload() {
        
        let payload = makePayload()
        let (sut, loadSpy) = makeSUT()
        
        load(sut: sut, with: payload) {
            
            loadSpy.complete(with: .failure(anyError()))
        }
        
        XCTAssertNoDiff(loadSpy.payloads, [payload])
    }
    
    func test_load_shouldDeliverFailed_onMissingInitialStorage() {
        
        let payload = makePayload()
        let (sut, loadSpy) = makeSUT()
        
        load(sut: sut, with: payload) {
            XCTAssertNoDiff($0, .init(storage: [:], failed: [payload]))
        } on: {
            loadSpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldCallLoadItemsWithPayloads_onTwoLoad() {
        
        let (first, second) = (makePayload(), makePayload())
        let (sut, loadSpy) = makeSUT()
        
        load(sut: sut, with: first, second) {
            
            loadSpy.complete(with: .failure(anyError()), at: 0)
            loadSpy.complete(with: .failure(anyError()), at: 1)
        }
        
        XCTAssertNoDiff(loadSpy.payloads, [first, second])
    }
    
    func test_load_shouldDeliverFailed_onTwoLoad_onMissingInitialStorage() {
        
        let (first, second) = (makePayload(), makePayload())
        let (sut, loadSpy) = makeSUT()
        
        load(sut: sut, with: first, second) {
            XCTAssertNoDiff($0, .init(storage: [:], failed: [first, second]))
        } on: {
            loadSpy.complete(with: .failure(anyError()), at: 0)
            loadSpy.complete(with: .failure(anyError()), at: 1)
        }
    }
    
    func test_load_shouldDeliverOutcome_onLoadSuccess() {
        
        let (payload, response) = (makePayload(), makeResponse())
        let outcome = makeOutcome(storage: [payload: response])
        let (sut, loadSpy) = makeSUT()
        
        load(sut: sut, with: payload) {
            XCTAssertNoDiff($0, outcome)
        } on: {
            loadSpy.complete(with: .success(response))
        }
    }
    
    func test_load_shouldMergeStorage_onLoadSuccess() {
        
        let (payload, response) = (makePayload(), makeResponse())
        let outcome = makeOutcome(storage: [
            payload: response
        ])
        
        let (newPayload, newResponse) = (makePayload(), makeResponse())
        let newOutcome = makeOutcome(storage: [
            payload: response,
            newPayload: newResponse
        ])
        
        let (sut, loadSpy) = makeSUT()
        
        load(sut: sut, with: payload) {
            XCTAssertNoDiff($0, outcome)
        } on: {
            loadSpy.complete(with: .success(response))
        }
        
        load(sut: sut, with: newPayload) {
            XCTAssertNoDiff($0, newOutcome)
        } on: {
            loadSpy.complete(with: .success(newResponse), at: 1)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = BatchLoader<Payload, Response>
    private typealias Outcome = SerialComponents.Outcome<Payload, Response>
    private typealias LoadSpy = Spy<Payload, Result<Response, Error>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy
    ) {
        let loadSpy = LoadSpy()
        
        let sut = SUT(load: loadSpy.process)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, loadSpy)
    }
    
    private func makeOutcome(
        storage: [Payload: Response],
        failed: [Payload] = []
    ) -> Outcome {
        
        return .init(storage: storage, failed: failed)
    }
    
    private struct Payload: Hashable {
        
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
    
    private func load(
        sut: SUT,
        with payloads: Payload...,
        assertOutcome: @escaping (Outcome) -> Void = { _ in },
        on action: () -> Void,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load(payloads: payloads) {
            
            assertOutcome($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
