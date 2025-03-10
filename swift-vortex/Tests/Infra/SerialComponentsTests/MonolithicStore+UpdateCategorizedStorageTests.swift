//
//  MonolithicStore+UpdateCategorizedStorageTests.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import SerialComponents
import VortexTools
import XCTest

final class MonolithicStore_UpdateCategorizedStorageTests: XCTestCase {
    
    func test_init_shouldSetEmptyStore() {
        
        XCTAssertEqual(makeSUT().insertedValues, [])
    }
    
    func test_update_shouldInsertStorage_onEmptyStore() {
        
        let category = makeCategory()
        let item = makeItem(category: category)
        let storage = makeStorage(items: [item])
        let sut = makeSUT()
        
        assertUpdate(sut: sut, storage: storage, toDeliver: [storage]) {
            
            sut.completeRetrieve(with: nil)
            sut.completeInsertSuccessfully()
        }
    }
    
    func test_update_shouldReplaceStorageWithSameCategory() {
        
        let category = makeCategory()
        let (item, newItem) = (makeItem(category: category), makeItem(category: category))
        let storage = makeStorage(items: [item])
        let update = makeStorage(items: [newItem])
        
        let sut = makeSUT()
        insert(sut: sut, storage: storage)
        
        assertUpdate(sut: sut, storage: update, toDeliver: [storage, update]) {
            
            sut.completeRetrieve(with: storage)
            sut.completeInsertSuccessfully(at: 1)
        }
    }
    
    func test_update_shouldUpdateStorageWithDifferentCategory() throws {
        
        let (item, newItem) = (makeItem(), makeItem())
        let storage = makeStorage(items: [item])
        let update = makeStorage(items: [newItem])
        
        let sut = makeSUT()
        insert(sut: sut, storage: storage)
        
        assertUpdate(sut: sut, storage: update, toDeliver: [
            storage,
            .init(entries: [
                item.category: .init(items: [item], serial: try XCTUnwrap(storage.serial(for: item.category))),
                newItem.category: .init(items: [newItem], serial: try XCTUnwrap(update.serial(for: newItem.category))),
            ])
        ]) {
            
            sut.completeRetrieve(with: storage)
            sut.completeInsertSuccessfully(at: 1)
        }
    }
    
    // MARK: - Helpers
    
    private typealias Storage = CategorizedStorage<Category, Item>
    private typealias SUT = MonolithicStoreSpy<Storage>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeStorage(
        items: [Item]? = nil,
        serial: String = anyMessage()
    ) -> Storage {
        
        return .init(items: items ?? [makeItem()], serial: serial)
    }
    
    private struct Category: Hashable {
        
        let value: String
    }
    
    private func makeCategory(
        _ value: String = anyMessage()
    ) -> Category {
        
        return .init(value: value)
    }
    
    private struct Item: Equatable, Categorized {
        
        let category: Category
        let value: String
    }
    
    private func makeItem(
        category: Category? = nil,
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(
            category: category ?? makeCategory(),
            value: value
        )
    }
    
    private func insert(
        sut: SUT,
        storage: Storage,
        timeout: TimeInterval = 1.0
    ) {
        let insertExp = expectation(description: "wait for insert completion")
        
        sut.insert(storage) { _ in insertExp.fulfill() }
        sut.completeInsertSuccessfully()
        wait(for: [insertExp], timeout: timeout)
    }
    
    private func assertUpdate(
        sut: SUT,
        storage update: Storage,
        toDeliver inserted: [Storage],
        timeout: TimeInterval = 1.0,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let updateExp = expectation(description: "wait for update completion")
        
        sut.update(with: update) { [weak sut] result in
            
            switch result {
            case let .failure(failure):
                XCTFail("Expected success but got \(failure) instead.")
                
            case .success(()):
                XCTAssertNoDiff(sut?.insertedValues, inserted, "Expected to have inserted \(inserted), but got \(String(describing: sut?.insertedValues)) instead.", file: file, line: line)
            }
            
            updateExp.fulfill()
        }
        
        action()
        
        wait(for: [updateExp], timeout: 1.0)
    }
}
