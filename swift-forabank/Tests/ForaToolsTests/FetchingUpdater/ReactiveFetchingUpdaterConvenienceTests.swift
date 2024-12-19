//
//  ReactiveFetchingUpdaterTests.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine
import ForaTools
import XCTest

final class ReactiveFetchingUpdaterConvenienceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, fetchSpy, mapSpy, updateSpy) = makeSUT()
        
        XCTAssertEqual(fetchSpy.callCount, 0)
        XCTAssertEqual(mapSpy.callCount, 0)
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    func test_load_shouldCallFetchWithPayload() {
        
        let payload = makePayload()
        let (sut, fetchSpy, _,_) = makeSUT()
        
        sut.load(payload: payload) { _ in }
        
        XCTAssertNoDiff(fetchSpy.payloads, [payload])
    }
    
    func test_load_shouldNotCallUpdateOnFetchFailure() {
        
        let (sut, fetchSpy, _, updateSpy) = makeSUT()
        
        sut.load(payload: makePayload()) { _ in }
        fetchSpy.complete(with: nil)
        
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    func test_load_shouldDeliverNilOnFetchFailure() {
        
        let (sut, fetchSpy, _,_) = makeSUT()
        
        expect(sut: sut, toDeliver: [nil]) {
            
            fetchSpy.complete(with: nil)
        }
    }
    
    func test_load_shouldCallMapOnFetchSuccess() {
        
        let fetchSuccess = makeT()
        let (sut, fetchSpy, mapSpy, _) = makeSUT()
        
        sut.load(payload: makePayload()) { _ in }
        fetchSpy.complete(with: fetchSuccess)
        
        XCTAssertNoDiff(mapSpy.payloads, [fetchSuccess])
    }
    
    func test_load_shouldDeliverUpdatedValue() {
        
        let item = makeItem()
        let newValue = anyMessage()
        let (sut, fetchSpy, _, updateSpy) = makeSUT(items: [item])
        
        expect(sut: sut, toDeliver: [
            [item],
            [.init(id: item.id, value: newValue)]]
        ) {
            fetchSpy.complete(with: makeT())
            updateSpy.complete(with: [item.id: newValue])
        }
    }
    
    func test_load_shouldDeliverUpdatedValueTwiceOnAnotherUpdate() {
        
        let (first, second) = (makeItem(), makeItem())
        let (newFirst, newSecond) = (anyMessage(), anyMessage())
        let (sut, fetchSpy, _, updateSpy) = makeSUT(items: [first, second])
        
        expect(sut: sut, toDeliver: [
            [first, second],
            [.init(id: first.id, value: newFirst), second],
            [.init(id: first.id, value: newFirst), .init(id: second.id, value: newSecond)],
        ]) {
            fetchSpy.complete(with: makeT())
            updateSpy.complete(with: [first.id: newFirst])
            updateSpy.complete(with: [second.id: newSecond])
        }
    }
    
    func test_load_shouldDeliverUpdatedValueOnMultipleUpdates() {
        
        let (first, second, third) = (makeItem(), makeItem(), makeItem())
        let (newFirst, newSecond, newThird) = (anyMessage(), anyMessage(), anyMessage())
        let (sut, fetchSpy, _, updateSpy) = makeSUT(items: [first, second, third])
        
        expect(sut: sut, toDeliver: [
            [first, second, third],
            [.init(id: first.id, value: newFirst), second, third],
            [.init(id: first.id, value: newFirst), .init(id: second.id, value: newSecond), third],
            [.init(id: first.id, value: newFirst), .init(id: second.id, value: newSecond), .init(id: third.id, value: newThird)]
        ]) {
            fetchSpy.complete(with: makeT())
            updateSpy.complete(with: [first.id: newFirst])
            updateSpy.complete(with: [second.id: newSecond])
            updateSpy.complete(with: [third.id: newThird])
        }
    }
    
    func test_load_shouldNotCallUpdateOnInstanceDeallocation() {
        
        var sut: SUT?
        let fetchSpy: FetchSpy
        let mapSpy: MapSpy
        let updateSpy: UpdateSpy
        (sut, fetchSpy, mapSpy, updateSpy) = makeSUT()
        
        sut?.load(payload: makePayload()) { _ in }
        sut = nil
        fetchSpy.complete(with: makeT())
        
        XCTAssertEqual(mapSpy.callCount, 0)
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    func test_load_shouldNotDeliverValueOnInstanceDeallocation() {
        
        var sut: SUT?
        let fetchSpy: FetchSpy
        (sut, fetchSpy, _,_) = makeSUT()
        var count = 0
        
        sut?.load(payload: makePayload()) { _ in count += 1 }
        sut = nil
        fetchSpy.complete(with: nil)
        
        XCTAssertEqual(count, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ReactiveFetchingUpdater<Payload, T, [Item]>
    private typealias FetchSpy = Spy<Payload, T?>
    private typealias MapSpy = CallSpy<T, [Item]>
    
    private func makeSUT(
        items: [Item] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        fetchSpy: FetchSpy,
        mapSpy: MapSpy,
        updateSpy: UpdateSpy
    ) {
        let fetchSpy = FetchSpy()
        let mapSpy = MapSpy(stubs: [items])
        let updateSpy = UpdateSpy()
        let sut = SUT(
            fetch: fetchSpy.process,
            map: mapSpy.call,
            update: updateSpy.update
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(fetchSpy, file: file, line: line)
        trackForMemoryLeaks(mapSpy, file: file, line: line)
        trackForMemoryLeaks(updateSpy, file: file, line: line)
        
        return (sut, fetchSpy, mapSpy, updateSpy)
    }
    
    private final class UpdateSpy {
        
        typealias Dictionary = Swift.Dictionary<Item.Key, Item.Value>
        
        private let subject = PassthroughSubject<Dictionary, Never>()
        private(set) var payloads = [T]()
        
        var callCount: Int { payloads.count }
        
        var update: AnyPublisher<Dictionary, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func complete(with value: Dictionary) {
            
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
    
    private func makeItem(
        id: UUID = .init(),
        value: String = anyMessage()
    ) -> Item {
        
        return .init(id: id, value: value)
    }

    private func expect(
        sut: SUT,
        with payload: Payload? = nil,
        toDeliver expectedValues: [[Item]?],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let payload = payload ?? makePayload()
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedValues.count
        var receivedValues = [[Item]?]()
        
        sut.load(payload: payload) {
            
            receivedValues.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(receivedValues, expectedValues, "Expected \(expectedValues), but got \(receivedValues) instead.", file: file, line: line)
    }
}

private struct Item: Equatable {
    
    let id: UUID
    let value: String
}

extension Item: ValueUpdatable {
    
    func updated(value: String) -> Self {
        
        return .init(id: id, value: value)
    }
}

extension Item: KeyProviding {
    
    var key: UUID { id }
}

