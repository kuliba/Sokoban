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
        
        Just([]).eraseToAnyPublisher()
    }
}

import XCTest

final class ValueUpdaterTests: XCTestCase {

    func test_shouldDeliverEmptyOnEmpty() {
        
        let (_, updater, spy) = makeSUT(items: [])
        
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
}

extension Item: KeyProviding {
    
    var key: UUID { id }
}
