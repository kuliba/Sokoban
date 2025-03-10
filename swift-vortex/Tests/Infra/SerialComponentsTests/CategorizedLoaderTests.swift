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
    
    func test_load_shouldCallLoadItemsWithCategory_onOneLoadCategory() {
        
        let category = makeCategory()
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT()
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load { _ in exp.fulfill() }
        loadCategoriesSpy.complete(with: [category])
        loadItemsSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(loadItemsSpy.payloads.map(\.0), [category])
    }
    
    func test_load_shouldCallLoadItemsWithoutSerial_onMissingInitialStorage() {
        
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT()
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load { _ in exp.fulfill() }
        loadCategoriesSpy.complete(with: [makeCategory()])
        loadItemsSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(loadItemsSpy.payloads.map(\.1), [nil])
    }
    
    func test_load_shouldCallLoadItemsWithoutSerial_onDifferentCategoryInInitialStorage() {
        
        let initialStorage = makeStorage(entries: [
            makeCategory(): .init(items: [makeItem()], serial: anyMessage())
        ])
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT(with: initialStorage)
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load { _ in exp.fulfill() }
        loadCategoriesSpy.complete(with: [makeCategory()])
        loadItemsSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(loadItemsSpy.payloads.map(\.1), [nil])
    }
    
    func test_load_shouldCallLoadItemsWithSerial_onMatchingCategoryInInitialStorage() {
        
        let (category, serial) = (makeCategory(), anyMessage())
        let initialStorage = makeStorage(entries: [
            category: .init(items: [makeItem()], serial: serial)
        ])
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT(with: initialStorage)
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load { _ in exp.fulfill() }
        loadCategoriesSpy.complete(with: [category])
        loadItemsSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(loadItemsSpy.payloads.map(\.1), [serial])
    }
    
    func test_load_shouldCallLoadItemsWithCategories_onTwoLoadCategories() {
        
        let (firstCategory, secondCategory) = (makeCategory(), makeCategory())
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT()
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load { _ in exp.fulfill() }
        loadCategoriesSpy.complete(with: [firstCategory, secondCategory])
        loadItemsSpy.complete(with: .failure(anyError()), at: 0)
        loadItemsSpy.complete(with: .failure(anyError()), at: 1)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(loadItemsSpy.payloads.map(\.0), [firstCategory, secondCategory])
    }
    
    func test_load_shouldCallLoadItemsWithoutSerial_onTwoLoadCategorie_onMissingInitialStorage() {
        
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT()
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load { _ in exp.fulfill() }
        loadCategoriesSpy.complete(with: [makeCategory(), makeCategory()])
        loadItemsSpy.complete(with: .failure(anyError()), at: 0)
        loadItemsSpy.complete(with: .failure(anyError()), at: 1)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(loadItemsSpy.payloads.map(\.1), [nil, nil])
    }
    
    func test_load_shouldCallLoadItemsWithoutSerial_onTwoLoadCategorie_onNonMatchingCategoryInInitialStorage() {
        
        let initialStorage = makeStorage(entries: [
            makeCategory(): .init(items: [makeItem()], serial: anyMessage())
        ])
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT(with: initialStorage)
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load { _ in exp.fulfill() }
        loadCategoriesSpy.complete(with: [makeCategory(), makeCategory()])
        loadItemsSpy.complete(with: .failure(anyError()), at: 0)
        loadItemsSpy.complete(with: .failure(anyError()), at: 1)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(loadItemsSpy.payloads.map(\.1), [nil, nil])
    }
    
    func test_load_shouldCallLoadItemsWithSerial_onTwoLoadCategorie_onMatchingCategoryInInitialStorage() {
        
        let (category, serial) = (makeCategory(), anyMessage())
        let initialStorage = makeStorage(entries: [
            category: .init(items: [makeItem()], serial: serial)
        ])
        let (sut, loadCategoriesSpy, loadItemsSpy) = makeSUT(with: initialStorage)
        let exp = expectation(description: "wait for load categories completions")
        
        sut.load { _ in exp.fulfill() }
        loadCategoriesSpy.complete(with: [makeCategory(), category])
        loadItemsSpy.complete(with: .failure(anyError()), at: 0)
        loadItemsSpy.complete(with: .failure(anyError()), at: 1)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(loadItemsSpy.payloads.map(\.1), [nil, serial])
    }
    
    // MARK: - Helpers
    
    private typealias Serial = String
    private typealias SUT = CategorizedLoader<Category, Item>
    private typealias Storage = CategorizedStorage<Category, Item>
    private typealias LoadCategoriesSpy = Spy<Void, [Category]?>
    private typealias LoadItemsSpy = Spy<(Category, Serial?), Result<SerialStamped<String, [Item]>, Error>>
    
    private func makeSUT(
        with initialStorage: Storage? = nil,
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
        entries: [Category : CategorizedStorage<Category, Item>.Entry] = [:]
    ) -> Storage {
        
        return .init(entries: entries)
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
