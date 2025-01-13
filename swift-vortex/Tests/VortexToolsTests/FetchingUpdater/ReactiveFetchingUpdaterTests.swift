//
//  ReactiveFetchingUpdaterTests.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine
import VortexTools
import XCTest

final class ReactiveFetchingUpdaterTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, fetchSpy, updateSpy) = makeSUT()
        
        XCTAssertEqual(fetchSpy.callCount, 0)
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    func test_load_shouldCallFetchWithPayload() {
        
        let payload = makePayload()
        let (sut, fetchSpy, _) = makeSUT()
        
        sut.load(payload: payload) { _ in }
        
        XCTAssertNoDiff(fetchSpy.payloads, [payload])
    }
    
    func test_load_shouldNotCallUpdateOnFetchFailure() {
        
        let (sut, fetchSpy, updateSpy) = makeSUT()
        
        sut.load(payload: makePayload()) { _ in }
        fetchSpy.complete(with: nil)
        
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    func test_load_shouldDeliverNilOnFetchFailure() {
        
        let (sut, fetchSpy, _) = makeSUT()
        
        expect(sut: sut, toDeliver: [nil]) {
            
            fetchSpy.complete(with: nil)
        }
    }
    
    func test_load_shouldCallUpdateWithFetchSuccess() {
        
        let fetchSuccess = makeT()
        let (sut, fetchSpy, updateSpy) = makeSUT()
        
        sut.load(payload: makePayload()) { _ in }
        fetchSpy.complete(with: fetchSuccess)
        
        XCTAssertNoDiff(updateSpy.payloads, [fetchSuccess])
    }
    
    func test_load_shouldDeliverUpdatedValue() {
        
        let updatedValue = makeV()
        let (sut, fetchSpy, updateSpy) = makeSUT()
        
        expect(sut: sut, toDeliver: [updatedValue]) {
            
            fetchSpy.complete(with: makeT())
            updateSpy.complete(with: updatedValue)
        }
    }
    
    func test_load_shouldDeliverUpdatedValueTwiceOnAnotherUpdate() {
        
        let (first, second) = (makeV(), makeV())
        let (sut, fetchSpy, updateSpy) = makeSUT()
        
        expect(sut: sut, toDeliver: [first, second]) {
            
            fetchSpy.complete(with: makeT())
            updateSpy.complete(with: first)
            updateSpy.complete(with: second)
        }
    }
    
    func test_load_shouldDeliverUpdatedValueOnMultipleUpdates() {
        
        let (first, second, third) = (makeV(), makeV(), makeV())
        let (sut, fetchSpy, updateSpy) = makeSUT()
        
        expect(sut: sut, toDeliver: [first, second, third]) {
            
            fetchSpy.complete(with: makeT())
            updateSpy.complete(with: first)
            updateSpy.complete(with: second)
            updateSpy.complete(with: third)
        }
    }
    
    func test_load_shouldNotCallUpdateOnInstanceDeallocation() {
        
        var sut: SUT?
        let fetchSpy: FetchSpy
        let updateSpy: UpdateSpy
        (sut, fetchSpy, updateSpy) = makeSUT()
        
        sut?.load(payload: makePayload()) { _ in }
        sut = nil
        fetchSpy.complete(with: makeT())
        
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    func test_load_shouldNotDeliverValueOnInstanceDeallocation() {
        
        var sut: SUT?
        let fetchSpy: FetchSpy
        (sut, fetchSpy, _) = makeSUT()
        var count = 0
        
        sut?.load(payload: makePayload()) { _ in count += 1 }
        sut = nil
        fetchSpy.complete(with: nil)
        
        XCTAssertEqual(count, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ReactiveFetchingUpdater<Payload, T, V>
    private typealias FetchSpy = Spy<Payload, T?>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        fetchSpy: FetchSpy,
        updateSpy: UpdateSpy
    ) {
        let fetchSpy = FetchSpy()
        let updateSpy = UpdateSpy()
        let sut = SUT(
            fetcher: AnyOptionalFetcher(fetch: fetchSpy.process),
            updater: AnyReactiveUpdater(update: updateSpy.update)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(fetchSpy, file: file, line: line)
        trackForMemoryLeaks(updateSpy, file: file, line: line)
        
        return (sut, fetchSpy, updateSpy)
    }
    
    private final class UpdateSpy {
        
        private let subject = PassthroughSubject<V, Never>()
        private(set) var payloads = [T]()
        
        var callCount: Int { payloads.count }
        
        func update(
            _ payload: T
        ) -> AnyPublisher<V, Never> {
            
            payloads.append(payload)
            return subject.eraseToAnyPublisher()
        }
        
        func complete(with value: V) {
            
            subject.send(value)
        }
    }
    
    private struct Payload: Equatable {
        
        let value: String
    }
    
    private func makePayload(
        _ value: String = anyMessage()
    ) -> Payload {
        
        return .init(value: value)
    }
    
    private struct T: Equatable {
        
        let value: String
    }
    
    private func makeT(
        _ value: String = anyMessage()
    ) -> T {
        
        return .init(value: value)
    }
    
    private struct V: Equatable {
        
        let value: String
    }
    
    private func makeV(
        _ value: String = anyMessage()
    ) -> V {
        
        return .init(value: value)
    }
    
    private func expect(
        sut: SUT,
        with payload: Payload? = nil,
        toDeliver expectedValues: [V?],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let payload = payload ?? makePayload()
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedValues.count
        var receivedValues = [V?]()
        
        sut.load(payload: payload) {
            
            receivedValues.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(receivedValues, expectedValues, "Expected \(expectedValues), but got \(receivedValues) instead.", file: file, line: line)
    }
}
