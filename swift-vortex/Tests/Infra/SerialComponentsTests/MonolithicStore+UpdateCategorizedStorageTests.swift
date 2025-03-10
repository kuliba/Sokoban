//
//  MonolithicStore+UpdateCategorizedStorageTests.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import VortexTools

extension MonolithicStore {
    
    // @inlinable
    func update<T, V>(
        with storage: CategorizedStorage<T, V>,
        completion: @escaping (Result<Void, Error>) -> Void
    ) where Value == CategorizedStorage<T, V>, Self: AnyObject {
        
        retrieve { [weak self] value in
            
            guard let self else { return }
            
            guard let value
            else { return insert(storage, completion) }
            
            let (merged, isUpdated) = value.merged(with: storage)
            
            if isUpdated {
                insert(merged, completion)
            } else {
                completion(.success(()))
            }
        }
    }
}

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
        let exp = expectation(description: "wait for completion")
        
        sut.update(with: storage) { [weak sut] result in
            
            switch result {
            case let .failure(failure):
                XCTFail("Expected success but got \(failure) instead.")
                
            case .success(()):
                XCTAssertNoDiff(sut?.insertedValues, [storage])
                XCTAssertNoDiff(sut?.insertedValues.first?.categories, [category])
                XCTAssertNoDiff(sut?.insertedValues.first?.items(for: category), [item])
            }
            
            exp.fulfill()
        }
        
        sut.completeRetrieve(with: nil)
        sut.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1.0)
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
}
