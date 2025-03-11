//
//  MonolithicStore+UpdateWithKeyTests.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import SerialComponents
import VortexTools
import XCTest

final class MonolithicStore_UpdateWithKeyTests: XCTestCase {
    
    func test_init_shouldSetEmptyStore() {
        
        XCTAssertEqual(makeSUT().insertedValues, [])
    }
    
    func test_update_shouldInsertStorage_onEmptyStore() {
        
        let category = makeCategory()
        let item = makeItem(category: category)
        let sut = makeSUT()
        
        assertUpdate(
            sut: sut,
            update: (category, item),
            toDeliver: [[category: item]]
        ) {
            sut.completeRetrieve(with: nil)
            sut.completeInsertSuccessfully()
        }
    }
    
    func test_update_shouldReplaceStorageWithSameCategory() {
        
        let category = makeCategory()
        let (item, newItem) = (makeItem(category: category), makeItem(category: category))
        
        let sut = makeSUT()
        insert(sut: sut, value: [category: item])
        
        assertUpdate(
            sut: sut,
            update: (category, newItem),
            toDeliver: [[category: item], [category: newItem]]
        ) {
            sut.completeRetrieve(with: [category: item])
            sut.completeInsertSuccessfully(at: 1)
        }
    }
    
    func test_update_shouldUpdateStorageWithDifferentCategory() throws {
        
        let (item, newItem) = (makeItem(), makeItem())
        let sut = makeSUT()
        insert(sut: sut, value: [item.category: item])
        
        assertUpdate(
            sut: sut,
            update: (newItem.category, newItem),
            toDeliver: [[
                item.category: item
            ],[
                item.category: item,
                newItem.category: newItem
            ]]
        ) {
            sut.completeRetrieve(with: [item.category: item])
            sut.completeInsertSuccessfully(at: 1)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MonolithicStoreSpy<[Key: Item]>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private struct Key: Hashable {
        
        let value: String
    }
    
    private func makeCategory(
        _ value: String = anyMessage()
    ) -> Key {
        
        return .init(value: value)
    }
    
    private struct Item: Equatable, Categorized {
        
        let category: Key
        let value: String
    }
    
    private func makeItem(
        category: Key? = nil,
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(
            category: category ?? makeCategory(),
            value: value
        )
    }
    
    private func insert(
        sut: SUT,
        value: [Key: Item],
        timeout: TimeInterval = 1.0
    ) {
        let insertExp = expectation(description: "wait for insert completion")
        
        sut.insert(value) { _ in insertExp.fulfill() }
        sut.completeInsertSuccessfully()
        wait(for: [insertExp], timeout: timeout)
    }
    
    private func assertUpdate(
        sut: SUT,
        update: (key: Key, item: Item),
        toDeliver inserted: [[Key: Item]],
        timeout: TimeInterval = 1.0,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for update completion")
        
        sut.update(key: update.key, with: update.item) { [weak sut] result in
            
            switch result {
            case let .failure(failure):
                XCTFail("Expected success but got \(failure) instead.")
                
            case .success(()):
                XCTAssertNoDiff(sut?.insertedValues, inserted, "Expected to have inserted \(inserted), but got \(String(describing: sut?.insertedValues)) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
