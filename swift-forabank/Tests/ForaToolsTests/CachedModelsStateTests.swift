//
//  CachedModelsStateTests.swift
//
//
//  Created by Igor Malyarov on 04.06.2024.
//

@testable import ForaTools
import XCTest

final class CachedModelsStateTests: XCTestCase {
    
    func test_updating_withEmpty_shouldNotChangeEmptyState() {
        
        let emptyState = makeState()
        
        let newState = updating(emptyState, with: [])
        
        XCTAssertTrue(emptyState.models.isEmpty)
        XCTAssertTrue(newState.models.isEmpty)
    }
    
    func test_updating_withEmpty_shouldSetStateWithOneItemToEmpty() {
        
        let item = makeItem()
        let stateWithOne = makeState(from: item)
        
        let newState = updating(stateWithOne, with: [])
        
        XCTAssertEqual(stateWithOne.models.count, 1)
        XCTAssertTrue(newState.models.isEmpty)
    }
    
    func test_updating_withEmpty_shouldSetStateWithManyItemsToEmpty() {
        
        let items = [makeItem(), makeItem()]
        let stateWithMany = makeState(items: items)
        
        let newState = updating(stateWithMany, with: [])
        
        XCTAssertEqual(stateWithMany.models.count, 2)
        XCTAssertTrue(newState.models.isEmpty)
    }
    
    func test_updating_withOne_shouldChangeEmptyState() {
        
        let emptyState = makeState()
        let item = makeItem()
        
        let newState = updating(emptyState, with: [item])
        
        XCTAssertTrue(emptyState.models.isEmpty)
        XCTAssertEqual(newState.models.count, 1)
        XCTAssertNoDiff(newState.models.map(\.item), [item])
    }
    
    func test_updating_withMany_shouldChangeEmptyState() {
        
        let emptyState = makeState()
        let (item1, item2) = (makeItem(), makeItem())
        
        let newState = updating(emptyState, with: [item1, item2])
        
        XCTAssertTrue(emptyState.models.isEmpty)
        XCTAssertEqual(newState.models.count, 2)
        XCTAssertNoDiff(newState.models.map(\.item), [item1, item2])
    }
    
    func test_updating_withSameID_shouldNotChangeStateWithOneItem() {
        
        let item = makeItem()
        let stateWithOne = makeState(from: item)
        
        let updatedItem = makeItem(id: item.id)
        let newState = updating(stateWithOne, with: [updatedItem])
        
        XCTAssertNoDiff(newState, stateWithOne)
    }
    
    func test_updating_withSameID_shouldNotChangeIdentity() {
        
        let item = makeItem()
        let stateWithOne = makeState(from: item)
        let identity = ObjectIdentifier(stateWithOne.models[0])
        
        let updatedItem = makeItem(id: item.id)
        let newState = updating(stateWithOne, with: [updatedItem])
        
        XCTAssertNoDiff(ObjectIdentifier(newState.models[0]), identity)
    }
    
    func test_updating_withSameID_shouldNotChangeStateWithManyItem() {
        
        let items = [makeItem(), makeItem()]
        let stateWithMany = makeState(items: items)
        
        let update = items.map { makeItem(id: $0.id) }
        let newState = updating(stateWithMany, with: update)
        
        XCTAssertNoDiff(newState, stateWithMany)
    }
    
    func test_updating_withSameID_shouldNotChangeModelItemValue() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let stateWithMany = makeState(from: item1, item2)
        
        let updated = [makeItem(id: item1.id), makeItem(id: item2.id)]
        let newState = updating(stateWithMany, with: updated)
        
        XCTAssertNoDiff(newState, stateWithMany)
    }
    
    func test_updating_withSameID_shouldNotChangeIdentities() {
        
        let items = [makeItem(), makeItem()]
        let stateWithMany = makeState(items: items)
        let identities = stateWithMany.models.map { ObjectIdentifier($0) }
        
        let update = items.map { makeItem(id: $0.id) }
        let newState = updating(stateWithMany, with: update)
        
        XCTAssertNoDiff(
            newState.models.map { ObjectIdentifier($0) },
            identities
        )
    }
    
    func test_updating_withSameIDs_shouldNotChangeStateWithManyItem() {
        
        let items = [makeItem(), makeItem()]
        let stateWithMany = makeState(items: items)
        
        let updatedItems = items.map { makeItem(id: $0.id) }
        let newState = updating(stateWithMany, with: updatedItems)
        
        XCTAssertNoDiff(newState, stateWithMany)
    }
    
    func test_updating_shouldDeliverModelsWithMatchingIDs() {
        
        let items = [makeItem(), makeItem()]
        let stateWithMany = makeState(items: items)
        
        let updatedItem = makeItem(id: items[1].id)
        let update = [makeItem(), updatedItem]
        let newState = updating(stateWithMany, with: update)
        
        XCTAssertNoDiff(newState.models.map(\.item.id), update.map(\.id))
    }
    
    func test_updating_shouldReorderModelsAccordingToGivenItems() {
        
        let items = [makeItem(), makeItem()]
        let stateWithMany = makeState(items: items)
        
        let newState = updating(stateWithMany, with: items.reversed())
        
        XCTAssertNoDiff(
            newState.models.map(\.item.id),
            stateWithMany.models.map(\.item.id).reversed()
        )
    }
    
    func test_updating_shouldEvictUnusedModelsFromCache() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let stateWithMany = makeState(from: item1, item2)
        XCTAssertEqual(stateWithMany.cacheCount, 2)
        
        let updatedItem = makeItem(id: item1.id)
        let newState = updating(stateWithMany, with: [updatedItem])
        
        XCTAssertEqual(newState.cacheCount, 1)
    }
    
    func test_updating_shouldUseLastItemWithSameID() {
        
        let emptyState = makeState()
        
        let id = anyMessage()
        let (item1, item2) = (makeItem(id: id, value: 1), makeItem(id: id, value: 2))
        let newState = updating(emptyState, with: [item1, item2])
        
        XCTAssertEqual(newState.models.count, 1)
        XCTAssertNoDiff(newState.models.last?.item, item2)
    }
    
    func test_updating_withMixedReplaceAndNewItems() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let stateWithMany = makeState(from: item1, item2)
        
        let update = [makeItem(), makeItem(id: item2.id)]
        let newState = updating(stateWithMany, with: update)
        
        XCTAssertEqual(newState.models.map(\.item), [update[0], item2])
    }
    
    // MARK: - Helpers
    
    private typealias State = CachedModelsState<String, Model>
    
    private func updating(
        _ state: State,
        with items: [Item]
    ) -> State {
        
        state.updating(with: items, using: Model.init)
    }
    
    private func makeItem(
        id: String = UUID().uuidString,
        value: Int = .random(in: 0..<100)
    ) -> Item {
        
        return .init(id: id, value: value)
    }
    
    private func makeState(
        from items: Item...
    ) -> State {
        
        makeState(items: items)
    }
    
    private func makeState(
        items: [Item]
    ) -> State {
        
        let pairs = items.map { ( $0.id, Model(item: $0)) }
        
        return .init(pairs: pairs)
    }
    
    private struct Item: Equatable, Identifiable {
        
        let id: String
        let value: Int
    }
    
    private final class Model: Equatable {
        
        let item: Item
        
        init(item: Item) {
            
            self.item = item
        }
        
        static func == (lhs: Model, rhs: Model) -> Bool {
            
            ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
            && lhs.item == rhs.item
        }
    }
    
    func anyMessage() -> String {
        
        UUID().uuidString
    }
}
