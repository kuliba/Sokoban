//
//  CategorizedLoaderTests.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

//import EphemeralStores
import SerialComponents
import VortexTools
import XCTest

final class CategorizedLoaderTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT()
        
        XCTAssertEqual(loadCategoriesSpy.callCount, 0)
        XCTAssertEqual(loadItemsSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldCallLoadCategories() {
        
        let (sut, loadCategoriesSpy, _) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(loadCategoriesSpy.callCount, 1)
    }
    
    func test_load_shouldNotCallLoadItems_onNilLoadCategories() {
        
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT()
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load { _ in exp.fulfill() }
        loadCategoriesSpy.complete(with: nil)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(loadItemsSpy.callCount, 0)
    }
    
    func test_load_shouldNotCallLoadItems_onEmptyLoadCategories() {
        
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT()
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load { _ in exp.fulfill() }
        loadCategoriesSpy.complete(with: [])
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(loadItemsSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias Serial = String
    private typealias SUT = CategorizedLoader<Category, Item>
    private typealias Storage = CategorizedStorage<Category, Item>
    private typealias LoadCategoriesSpy = Spy<Void, [Category]?>
    private typealias LoadItemsSpy = Spy<(Category, Serial?), Result<SerialStamped<String, [Item]>, Error>>
    
    private func makeSUT(
        initialStorage: Storage? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadCategoriesSpy: LoadCategoriesSpy,
        loadItemsSpy: LoadItemsSpy
    ) {
        let loadCategoriesSpy = LoadCategoriesSpy()
        let loadItemsSpy = LoadItemsSpy()
        
        let sut = SUT(
            initialStorage: initialStorage,
            loadCategories: loadCategoriesSpy.process,
            loadItems: loadItemsSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadCategoriesSpy, file: file, line: line)
        trackForMemoryLeaks(loadItemsSpy, file: file, line: line)
        
        return (sut, loadCategoriesSpy, loadItemsSpy)
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
        
        return .init(category: category ?? makeCategory(), value: value)
    }
}
