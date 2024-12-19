//
//  ArrayUpdatingTests.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine
import ForaTools
import XCTest

final class ArrayUpdatingTests: XCTestCase {
    
    // MARK: - empty
    
    func test_shouldDeliverEmptyOnEmpty() {
        
        let (_, spy) = makeSUT(items: [])
        
        XCTAssertNoDiff(spy.values, [[]])
    }
    
    func test_shouldNotDeliverEmptyUpdateOnEmpty() {
        
        let (updater, spy) = makeSUT(items: [])
        
        updater.emit([:])
        
        XCTAssertNoDiff(spy.values, [[]])
    }
    
    func test_shouldNotDeliverUpdateOnEmpty() {
        
        let (updater, spy) = makeSUT(items: [])
        
        updater.emit([.init(): anyMessage()])
        
        XCTAssertNoDiff(spy.values, [[]])
    }
    
    // MARK: - one
    
    func test_shouldDeliverOneOnOne() {
        
        let item = makeItem()
        let (_, spy) = makeSUT(items: [item])
        
        XCTAssertNoDiff(spy.values, [[item]])
    }
    
    func test_shouldNotChangeWithEmptyUpdateOnOne() {
        
        let item = makeItem()
        let (updater, spy) = makeSUT(items: [item])
        
        updater.emit([:])
        
        XCTAssertNoDiff(spy.values, [[item], [item]])
    }
    
    func test_shouldNotChangeWithNonMatchingKeyUpdateOnOne() {
        
        let item = makeItem()
        let (updater, spy) = makeSUT(items: [item])
        
        updater.emit([.init(): anyMessage()])
        
        XCTAssertNoDiff(spy.values, [[item], [item]])
    }
    
    func test_shouldDeliverMatchingKeyUpdateOnOne() {
        
        let item = makeItem()
        let newValue = anyMessage()
        let (updater, spy) = makeSUT(items: [item])
        
        updater.emit([item.id: newValue])
        
        XCTAssertNoDiff(spy.values, [
            [item],
            [.init(id: item.id, value: newValue)]
        ])
    }
    
    func test_shouldIgnoreNonMatchingKeyUpdateOnOne() {
        
        let item = makeItem()
        let newValue = anyMessage()
        let (updater, spy) = makeSUT(items: [item])
        
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
        let (_, spy) = makeSUT(items: [item1, item2])
        
        XCTAssertNoDiff(spy.values, [[item1, item2]])
    }
    
    func test_shouldNotChangeWithEmptyUpdateOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (updater, spy) = makeSUT(items: [item1, item2])
        
        updater.emit([:])
        
        XCTAssertNoDiff(spy.values, [[item1, item2], [item1, item2]])
    }
    
    func test_shouldNotChangeWithNonMatchingKeyUpdateOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (updater, spy) = makeSUT(items: [item1, item2])
        
        updater.emit([.init(): anyMessage()])
        
        XCTAssertNoDiff(spy.values, [[item1, item2], [item1, item2]])
    }
    
    func test_shouldChangeFirstWithMatchingKeyUpdateOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let newValue = anyMessage()
        let (updater, spy) = makeSUT(items: [item1, item2])
        
        updater.emit([item1.id: newValue])
        
        XCTAssertNoDiff(spy.values, [
            [item1, item2],
            [.init(id: item1.id, value: newValue), item2]
        ])
    }
    
    func test_shouldChangeSecondMatchingKeyUpdateOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let newValue = anyMessage()
        let (updater, spy) = makeSUT(items: [item1, item2])
        
        updater.emit([item2.id: newValue])
        
        XCTAssertNoDiff(spy.values, [
            [item1, item2],
            [item1, .init(id: item2.id, value: newValue)]
        ])
    }
    
    func test_shouldChangeBothMatchingKeyUpdatesOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (newValue1, newValue2) = (anyMessage(), anyMessage())
        let (updater, spy) = makeSUT(items: [item1, item2])
        
        updater.emit([item1.id: newValue1, item2.id: newValue2])
        
        XCTAssertNoDiff(spy.values, [
            [item1, item2],
            [.init(id: item1.id, value: newValue1), .init(id: item2.id, value: newValue2)]
        ])
    }
    
    func test_shouldIgnoreNonMatchingKeyUpdateOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let newValue = anyMessage()
        let (updater, spy) = makeSUT(items: [item1, item2])
        
        updater.emit([
            item1.id: newValue,
            .init(): anyMessage()
        ])
        
        XCTAssertNoDiff(spy.values, [
            [item1, item2],
            [.init(id: item1.id, value: newValue), item2]
        ])
    }
    
    // MARK: - multiple sequential updates
    
    func test_shouldDeliverMultipleSequentialUpdatesOnOne() {
        
        let item = makeItem()
        let (updater, spy) = makeSUT(items: [item])
        
        let value1 = anyMessage()
        updater.emit([item.id: value1])
        
        let value2 = anyMessage()
        updater.emit([item.id: value2])
        
        XCTAssertNoDiff(spy.values, [
            [item],
            [.init(id: item.id, value: value1)],
            [.init(id: item.id, value: value2)]
        ])
    }
    
    func test_shouldDeliverMultipleSequentialUpdatesOnTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (updater, spy) = makeSUT(items: [item1, item2])
        
        let value1ForItem1 = anyMessage()
        updater.emit([item1.id: value1ForItem1])
        
        let value1ForItem2 = anyMessage()
        updater.emit([item2.id: value1ForItem2])
        
        let (value2ForItem1, value2ForItem2) = (anyMessage(), anyMessage())
        updater.emit([item1.id: value2ForItem1, item2.id: value2ForItem2])
        
        XCTAssertNoDiff(spy.values, [
            [item1, item2],
            [.init(id: item1.id, value: value1ForItem1), item2],
            [.init(id: item1.id, value: value1ForItem1), .init(id: item2.id, value: value1ForItem2)],
            [.init(id: item1.id, value: value2ForItem1), .init(id: item2.id, value: value2ForItem2)]
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Spy = ValueSpy<[Item]>
    
    private func makeSUT(
        items: [Item],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        updater: Updater,
        spy: Spy
    ) {
        let updater = Updater()
        let spy = Spy(items.updating(with: updater.update))
        
        trackForMemoryLeaks(updater, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (updater, spy)
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
