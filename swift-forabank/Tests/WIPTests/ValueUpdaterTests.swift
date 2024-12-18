//
//  ValueUpdaterTests.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

protocol KeyProviding<Key> {
    
    associatedtype Key: Hashable
    
    var key: Key { get }
}

protocol ValueUpdatable<Value> {
    
    associatedtype Value
    
    var keyPath: KeyPath<Self, Value> { get }
    func updated(value: Value) -> Self
}

final class ValueUpdater<T, Key, Value>
where Key: Hashable,
      T: KeyProviding<Key>,
      T: ValueUpdatable<Value> {
    
    private let items: [T]
    private let update: AnyPublisher<Dictionary<Key, Value>, Never>
    
    init(
        items: [T],
        update: AnyPublisher<Dictionary<Key, Value>, Never>
    ) {
        self.items = items
        self.update = update
    }
}

extension ValueUpdater {
    
    var updatingItems: AnyPublisher<[T], Never> {
        
        guard !items.isEmpty
        else { return Just([]).eraseToAnyPublisher() }
        
        return update
            .scan(items) { currentItems, updates in
                
                currentItems.map { item in
                    
                    if let newValue = updates[item.key] {
                        return item.updated(value: newValue)
                    } else {
                        return item
                    }
                }
            }
            .prepend(items)
            .eraseToAnyPublisher()
    }
}

import XCTest

final class ValueUpdaterTests: XCTestCase {
    
    // MARK: - empty

    func test_shouldDeliverEmptyOnEmpty() {
        
        let (_,_, spy) = makeSUT(items: [])
        
        XCTAssertNoDiff(spy.values, [[]])
    }

    func test_shouldNotDeliverEmptyUpdateOnEmpty() {
        
        let (_, updater, spy) = makeSUT(items: [])
        
        updater.emit([:])
        
        XCTAssertNoDiff(spy.values, [[]])
    }

    func test_shouldNotDeliverUpdateOnEmpty() {
        
        let (_, updater, spy) = makeSUT(items: [])
        
        updater.emit([.init(): anyMessage()])
        
        XCTAssertNoDiff(spy.values, [[]])
    }
    
    // MARK: - one

    func test_shouldDeliverOneOnOne() {
        
        let item = makeItem()
        let (_,_, spy) = makeSUT(items: [item])
        
        XCTAssertNoDiff(spy.values, [[item]])
    }

    func test_shouldNotChangeWithEmptyUpdateOnOne() {
        
        let item = makeItem()
        let (_, updater, spy) = makeSUT(items: [item])

        updater.emit([:])
        
        XCTAssertNoDiff(spy.values, [[item], [item]])
    }

    func test_shouldNotChangeWithNonMatchingKeyUpdateOnOne() {
        
        let item = makeItem()
        let (_, updater, spy) = makeSUT(items: [item])

        updater.emit([.init(): anyMessage()])
        
        XCTAssertNoDiff(spy.values, [[item], [item]])
    }

    func test_shouldDeliverMatchingKeyUpdateOnOne() {
        
        let item = makeItem()
        let newValue = anyMessage()
        let (_, updater, spy) = makeSUT(items: [item])

        updater.emit([item.id: newValue])
        
        XCTAssertNoDiff(spy.values, [
            [item],
            [.init(id: item.id, value: newValue)]
        ])
    }

    func test_shouldIgnoreNonMatchingKeyUpdateOnOne() {
        
        let item = makeItem()
        let newValue = anyMessage()
        let (_, updater, spy) = makeSUT(items: [item])

        updater.emit([
            item.id: newValue,
            .init(): anyMessage()
        ])
        
        XCTAssertNoDiff(spy.values, [
            [item],
            [.init(id: item.id, value: newValue)]
        ])
    }

    // MARK: - two

    func test_shouldDeliverTwoOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (_,_, spy) = makeSUT(items: [item1, item2])
        
        XCTAssertNoDiff(spy.values, [[item1, item2]])
    }

    func test_shouldNotChangeWithEmptyUpdateOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (_, updater, spy) = makeSUT(items: [item1, item2])

        updater.emit([:])
        
        XCTAssertNoDiff(spy.values, [[item1, item2], [item1, item2]])
    }

    func test_shouldNotChangeWithNonMatchingKeyUpdateOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (_, updater, spy) = makeSUT(items: [item1, item2])

        updater.emit([.init(): anyMessage()])
        
        XCTAssertNoDiff(spy.values, [[item1, item2], [item1, item2]])
    }

    func test_shouldChangeFirstWithMatchingKeyUpdateOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let newValue = anyMessage()
        let (_, updater, spy) = makeSUT(items: [item1, item2])

        updater.emit([item1.id: newValue])
        
        XCTAssertNoDiff(spy.values, [
            [item1, item2],
            [.init(id: item1.id, value: newValue), item2]
        ])
    }

    func test_shouldChangeSecondMatchingKeyUpdateOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let newValue = anyMessage()
        let (_, updater, spy) = makeSUT(items: [item1, item2])

        updater.emit([item2.id: newValue])
        
        XCTAssertNoDiff(spy.values, [
            [item1, item2],
            [item1, .init(id: item2.id, value: newValue)]
        ])
    }

    func test_shouldChangeBothMatchingKeyUpdatesOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (newValue1, newValue2) = (anyMessage(), anyMessage())
        let (_, updater, spy) = makeSUT(items: [item1, item2])

        updater.emit([item1.id: newValue1, item2.id: newValue2])
        
        XCTAssertNoDiff(spy.values, [
            [item1, item2],
            [.init(id: item1.id, value: newValue1), .init(id: item2.id, value: newValue2)]
        ])
    }

    func test_shouldIgnoreNonMatchingKeyUpdateOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let newValue = anyMessage()
        let (_, updater, spy) = makeSUT(items: [item1, item2])

        updater.emit([
            item1.id: newValue,
            .init(): anyMessage()
        ])
        
        XCTAssertNoDiff(spy.values, [
            [item1, item2],
            [.init(id: item1.id, value: newValue), item2]
        ])
    }

    // MARK: - Helpers
    
    private typealias SUT = ValueUpdater<Item, UUID, String>
    private typealias Spy = ValueSpy<[Item]>
    
    private func makeSUT(
        items: [Item],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        updater: Updater,
        spy: Spy
    ) {
        let updater = Updater()
        let sut = SUT(items: items, update: updater.update)
        let spy = Spy(sut.updatingItems)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(updater, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, updater, spy)
    }
    
    private func makeItem(
        id: UUID = .init(),
        value: String = anyMessage()
    ) -> Item {
        
        return .init(id: id, value: value)
    }
    
    private final class Updater {
        
        typealias Value = Dictionary<UUID, String>
        
        private let subject = PassthroughSubject<Value, Never>()
        
        var update: AnyPublisher<Value, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func emit(_ value: Value) {
            
            subject.send(value)
        }
    }
}

struct Item: Equatable {
    
    let id: UUID
    let value: String
}

extension Item: ValueUpdatable {
    
    var keyPath: KeyPath<Item, String> { \.value }
    
    func updated(value: Value) -> Self {
        
        return .init(id: id, value: value)
    }
}

extension Item: KeyProviding {
    
    var key: UUID { id }
}
