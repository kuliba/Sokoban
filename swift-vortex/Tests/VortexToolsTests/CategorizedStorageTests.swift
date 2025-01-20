//
//  CategorizedStorageTests.swift
//  
//
//  Created by Igor Malyarov on 18.01.2025.
//

import VortexTools
import XCTest

final class CategorizedStorageTests: XCTestCase {
    
    // MARK: - categories
    
    func test_categories_shouldReturnAllExistingCategories() {
        
        let entries: [String: Storage.Entry] = [
            "fruits": .init(
                items: [.init(category: "fruits", name: "Apple")],
                serial: "serial-fruits"
            ),
            "drinks": .init(
                items: [.init(category: "drinks", name: "Water")],
                serial: "serial-drinks"
            )
        ]
        let storage = Storage(entries: entries)
        
        XCTAssertNoDiff(Set(storage.categories), ["fruits", "drinks"])
    }
    
    // MARK: - items(for:)
    
    func test_items_shouldReturnNilOnEmpty() {
        
        let storage = makeEmptyStorage()
        
        XCTAssertNil(storage.items(for: "fruits"))
    }
    
    func test_items_shouldReturnSingleItemOnOne() {
        
        let storage = makeSingleItemStorage()
        
        let items = storage.items(for: "fruits")
        
        XCTAssertNoDiff(items?.count, 1)
        XCTAssertNoDiff(items?.first?.name, "Apple")
    }
    
    func test_items_shouldReturnMultipleItemsOnTwo() {
        
        let storage = makeTwoItemStorage()
        
        let items = storage.items(for: "fruits")
        
        XCTAssertNoDiff(items?.count, 2)
        XCTAssertTrue(items?.contains(where: { $0.name == "Apple" }) ?? false)
        XCTAssertTrue(items?.contains(where: { $0.name == "Banana" }) ?? false)
    }
    
    func test_items_shouldReturnNilOnUnknownCategory() {
        
        let storage = makeSingleItemStorage()
        
        XCTAssertNil(storage.items(for: "vegetables"))
    }
    
    // MARK: - serial(for:)
    
    func test_serial_shouldReturnNilOnEmpty() {
        
        let storage = makeEmptyStorage()
        
        XCTAssertNil(storage.serial(for: "fruits"))
    }
    
    func test_serial_shouldReturnStoredValueOnSingle() {
        
        let storage = makeSingleItemStorage()
        
        XCTAssertNoDiff(storage.serial(for: "fruits"), "serial-1")
    }
    
    func test_serial_shouldReturnStoredValueOnTwo() {
        
        let storage = makeTwoItemStorage()
        
        XCTAssertNoDiff(storage.serial(for: "fruits"), "serial-2")
    }
    
    func test_serial_shouldReturnNilOnUnknownCategory() {
        
        let storage = makeSingleItemStorage()
        
        XCTAssertNil(storage.serial(for: "vegetables"))
    }
    
    // MARK: - updated(category:items:serial:)
    
    func test_updatedWithCategory_shouldSetEmptyItemsOnEmptyForExistingCategory() {
        
        let storage = makeSingleItemStorage()
        
        let updated = storage.updated(
            category: "fruits",
            items: [],
            serial: "new-serial"
        )
        
        let items = updated.items(for: "fruits")
        XCTAssertNoDiff(items?.isEmpty, true)
        XCTAssertNoDiff(updated.serial(for: "fruits"), "new-serial")
    }
    
    func test_updatedWithCategory_shouldNotCreateOrCreateCategoryOnEmptyForNewCategory() {
        
        let storage = makeEmptyStorage()
        
        let updated = storage.updated(
            category: "drinks",
            items: [],
            serial: "serial-drinks"
        )
        
        let items = updated.items(for: "drinks")
        XCTAssertNoDiff(items?.isEmpty, true)
        XCTAssertNoDiff(updated.serial(for: "drinks"), "serial-drinks")
    }
    
    func test_updatedWithCategory_shouldNotChangeDataWhenItemsUnchanged() {
        
        let storage = makeTwoItemStorage()
        
        let updated = storage.updated(
            category: "fruits",
            items: [
                makeItem(category: "fruits", name: "Apple"),
                makeItem(category: "fruits", name: "Banana")
            ],
            serial: "serial-2"
        )
        
        XCTAssertNoDiff(updated, storage)
    }
    
    func test_updatedWithCategory_shouldAddNewCategoryOnEmpty() {
        
        let storage = makeEmptyStorage()
        
        let updated = storage.updated(
            category: "drinks",
            items: [makeItem(category: "drinks", name: "Water")],
            serial: "serial-drinks"
        )
        
        XCTAssertNoDiff(updated.items(for: "drinks")?.count, 1)
        XCTAssertNoDiff(updated.serial(for: "drinks"), "serial-drinks")
    }
    
    func test_updatedWithCategory_shouldReplaceItemsOnExistingCategory() throws {
        
        let storage = makeSingleItemStorage()
        
        let updated = storage.updated(
            category: "fruits",
            items: [
                makeItem(category: "fruits", name: "Cherry"),
                makeItem(category: "fruits", name: "Grapes")
            ],
            serial: "serial-replaced"
        )
        
        let items = try XCTUnwrap(updated.items(for: "fruits"))
        
        XCTAssertNoDiff(items.count, 2)
        XCTAssertTrue(items.contains(where: { $0.name == "Cherry" }))
        XCTAssertTrue(items.contains(where: { $0.name == "Grapes" }))
        XCTAssertNoDiff(updated.serial(for: "fruits"), "serial-replaced")
    }
    
    func test_updatedWithCategory_shouldFilterOutDifferentCategoryItems() {
        
        let storage = makeEmptyStorage()
        
        let updated = storage.updated(
            category: "electronics",
            items: [
                makeItem(category: "electronics", name: "iPhone"),
                makeItem(category: "furniture", name: "Chair")
            ],
            serial: "serial-electronics"
        )
        
        let items = updated.items(for: "electronics")
        XCTAssertNoDiff(items?.count, 1)
        XCTAssertNoDiff(items?.first?.name, "iPhone")
    }
    
    func test_updatedWithCategory_shouldNotAffectOtherCategoriesOnMultiple() {
        
        let storage = makeTwoItemStorage()
        
        let updated = storage.updated(
            category: "electronics",
            items: [makeItem(category: "electronics", name: "iPhone")],
            serial: "serial-electronics"
        )
        
        // "fruits" should remain untouched
        XCTAssertNoDiff(updated.items(for: "fruits")?.count, 2)
        XCTAssertNoDiff(updated.serial(for: "fruits"), "serial-2")
        
        // "electronics" was just added
        XCTAssertNoDiff(updated.items(for: "electronics")?.count, 1)
        XCTAssertNoDiff(updated.serial(for: "electronics"), "serial-electronics")
    }
    
    // MARK: - updated(items:serial:)
    
    func test_updated_shouldNotUpdateOnEmptyForExistingCategory() {
        
        let storage = makeSingleItemStorage()
        
        let updated = storage.updated(items: [], serial: anyMessage())
        
        XCTAssertNoDiff(updated, storage)
    }
    
    func test_updated_shouldNotCreateCategoryOnEmptyForNewCategory() {
        
        let storage = makeEmptyStorage()
        
        let updated = storage.updated(items: [], serial: anyMessage())
        
        XCTAssertNoDiff(updated, storage)
    }
    
    func test_updated_shouldNotChangeDataWhenItemsUnchanged() {
        
        let storage = makeTwoItemStorage()
        
        let updated = storage.updated(
            items: [
                makeItem(category: "fruits", name: "Apple"),
                makeItem(category: "fruits", name: "Banana")
            ],
            serial: "serial-2"
        )
        
        XCTAssertNoDiff(updated, storage)
    }
    
    func test_updated_shouldAddNewCategoryOnEmpty() {
        
        let storage = makeEmptyStorage()
        
        let updated = storage.updated(
            items: [makeItem(category: "drinks", name: "Water")],
            serial: "serial-drinks"
        )
        
        XCTAssertNoDiff(updated.items(for: "drinks")?.count, 1)
        XCTAssertNoDiff(updated.serial(for: "drinks"), "serial-drinks")
    }
    
    func test_updated_shouldReplaceItemsOnExistingCategory() throws {
        
        let storage = makeSingleItemStorage()
        
        let updated = storage.updated(
            items: [
                makeItem(category: "fruits", name: "Cherry"),
                makeItem(category: "fruits", name: "Grapes")
            ],
            serial: "serial-replaced"
        )
        
        let items = try XCTUnwrap(updated.items(for: "fruits"))
        
        XCTAssertNoDiff(items.count, 2)
        XCTAssertTrue(items.contains(where: { $0.name == "Cherry" }))
        XCTAssertTrue(items.contains(where: { $0.name == "Grapes" }))
        XCTAssertNoDiff(updated.serial(for: "fruits"), "serial-replaced")
    }
    
    func test_updated_shouldFilterOutDifferentCategoryItems() {
        
        let storage = makeEmptyStorage()
        
        let updated = storage.updated(
            items: [
                makeItem(category: "electronics", name: "iPhone"),
                makeItem(category: "furniture", name: "Chair")
            ],
            serial: "serial-electronics"
        )
        
        let items = updated.items(for: "electronics")
        XCTAssertNoDiff(items?.count, 1)
        XCTAssertNoDiff(items?.first?.name, "iPhone")
    }
    
    func test_updated_shouldNotAffectOtherCategoriesOnMultiple() {
        
        let storage = makeTwoItemStorage()
        
        let updated = storage.updated(
            items: [makeItem(category: "electronics", name: "iPhone")],
            serial: "serial-electronics"
        )
        
        // "fruits" should remain untouched
        XCTAssertNoDiff(updated.items(for: "fruits")?.count, 2)
        XCTAssertNoDiff(updated.serial(for: "fruits"), "serial-2")
        
        // "electronics" was just added
        XCTAssertNoDiff(updated.items(for: "electronics")?.count, 1)
        XCTAssertNoDiff(updated.serial(for: "electronics"), "serial-electronics")
    }
    
    func test_updated_shouldKeepAllMatchingItemsEvenIfTheyAppearAfterDifferentCategory() throws {
        
        let storage = makeSingleItemStorage()
        let fruit1 = makeItem(category: "fruits", name: "Cherry")
        let other  = makeItem(category: "drinks", name: "Cola")
        let fruit2 = makeItem(category: "fruits", name: "Plum")
        
        let updated = storage.updated(items: [fruit1, other, fruit2], serial: "serial-fruits2")
        
        let items = try XCTUnwrap(updated.items(for: "fruits"))
        XCTAssertNoDiff(items.count, 2)
        XCTAssertTrue(items.contains { $0.name == "Cherry" })
        XCTAssertTrue(items.contains { $0.name == "Plum" })
    }
    
    func test_updated_shouldKeepDuplicateItems() {
        
        let storage = makeEmptyStorage()
        let apple = makeItem(category: "fruits", name: "Apple")
        
        let updated = storage.updated(items: [apple, apple], serial: "serial-fruits")
        
        let items = updated.items(for: "fruits") ?? []
        XCTAssertNoDiff(items.count, 2)
        XCTAssertTrue(items.allSatisfy { $0.name == "Apple" })
        XCTAssertNoDiff(updated.serial(for: "fruits"), "serial-fruits")
    }
    
    // MARK: - init(items:)
    
    func test_init_shouldCreateEmptyStorageOnEmpty() {
        
        let storage = Storage(items: [], serial: anyMessage())
        
        XCTAssert(storage.categories.isEmpty)
    }
    
    func test_init_shouldCreateStorageWithOneOnOne() {
        
        let (item, serial) = (makeItem(), anyMessage())
        let storage = Storage(items: [item], serial: serial)
        
        XCTAssertNoDiff(storage, .init(entries: [
            item.category: .init(items: [item], serial: serial)
        ]))
    }
    
    func test_init_shouldCreateStorageWithTwoOnTwoWithSameCategory() {
        
        let category = anyMessage()
        let (first, second) = (makeItem(category: category), makeItem(category: category))
        let serial = anyMessage()
        let storage = Storage(items: [first, second], serial: serial)
        
        XCTAssertNoDiff(storage, .init(entries: [
            category: .init(items: [first, second], serial: serial)
        ]))
    }
    
    func test_init_shouldStoreAllCategories() {
        
        let items = [
            makeItem(category: "fruits",    name: "Apple"),
            makeItem(category: "drinks",    name: "Water"),
            makeItem(category: "electronics", name: "iPhone")
        ]
        
        let storage = Storage(items: items, serial: "same-serial")
        
        XCTAssertNoDiff(storage.items(for: "fruits")?.count, 1)
        XCTAssertNoDiff(storage.items(for: "drinks")?.count, 1)
        XCTAssertNoDiff(storage.items(for: "electronics")?.count, 1)
        
        XCTAssertNoDiff(storage.serial(for: "fruits"), "same-serial")
        XCTAssertNoDiff(storage.serial(for: "drinks"), "same-serial")
        XCTAssertNoDiff(storage.serial(for: "electronics"), "same-serial")
    }
    
    func test_merge_shouldSkipWhenSerialsMatchButMergeWhenDifferent() {
        
        let oldStorage = Storage(entries: [
            "fruits": .init(
                items: [.init(category: "fruits", name: "Apple")],
                serial: "serial-fruits"
            )
        ])
        
        let newStorage = Storage(entries: [
            "fruits": .init(
                items: [.init(category: "fruits", name: "Apple")],
                serial: "serial-fruits"
            ),
            "drinks": .init(
                items: [.init(category: "drinks", name: "Water")],
                serial: "serial-drinks"
            )
        ])
        
        let (merged, changed) = Storage.merge(oldStorage, newStorage)
        
        // "fruits" has matching serial, so remains unchanged
        let fruits = merged.items(for: "fruits") ?? []
        XCTAssertNoDiff(fruits.count, 1)
        XCTAssertNoDiff(fruits.first?.name, "Apple")
        XCTAssertNoDiff(merged.serial(for: "fruits"), "serial-fruits")
        
        // "drinks" is new (serial differs), so it merges in
        let drinks = merged.items(for: "drinks") ?? []
        XCTAssertNoDiff(drinks.count, 1)
        XCTAssertNoDiff(drinks.first?.name, "Water")
        XCTAssertNoDiff(merged.serial(for: "drinks"), "serial-drinks")
        
        // At least one category updated => changed is true
        XCTAssertNoDiff(changed, true)
    }
    
    func test_search_shouldFindItemsMatchingValue() {
        
        let storage = Storage(entries: [
            "fruits": .init(
                items: [
                    .init(category: "fruits", name: "Apple"),
                    .init(category: "fruits", name: "Banana")
                ],
                serial: "serial-fruits"
            ),
            "drinks": .init(
                items: [
                    .init(category: "drinks", name: "Water"),
                    .init(category: "drinks", name: "Apple Juice")
                ],
                serial: "serial-drinks"
            )
        ])
        
        // Search for "Apple" in the `name` field
        let results = storage.search(for: "Apple", in: \.name)
        
        XCTAssertNoDiff(results.count, 1)
        XCTAssertNoDiff(results.first?.category, "fruits")
        XCTAssertNoDiff(results.first?.name, "Apple")
        
        // Search for "Water" in the `name` field
        let waterResults = storage.search(for: "Water", in: \.name)
        
        XCTAssertNoDiff(waterResults.count, 1)
        XCTAssertNoDiff(waterResults.first?.category, "drinks")
        XCTAssertNoDiff(waterResults.first?.name, "Water")
        
        // Search for a non-existent value
        let nonExistentResults = storage.search(for: "NonExistent", in: \.name)
        XCTAssertNoDiff(nonExistentResults.count, 0)
    }
    
    // MARK: - Helpers
    
    private typealias Storage = CategorizedStorage<String, Item>
    
    private func makeEmptyStorage() -> Storage {
        
        return .init(entries: [:])
    }
    
    private func makeSingleItemStorage() -> Storage {
        
        let entry = Storage.Entry(
            items: [.init(category: "fruits", name: "Apple")],
            serial: "serial-1"
        )
        
        return .init(entries: ["fruits": entry])
    }
    
    private func makeTwoItemStorage() -> Storage {
        
        let entry = CategorizedStorage<String, Item>.Entry(
            items: [
                .init(category: "fruits", name: "Apple"),
                .init(category: "fruits", name: "Banana")
            ],
            serial: "serial-2"
        )
        
        return .init(entries: ["fruits": entry])
    }
    
    private func makeItem(
        category: String = anyMessage(),
        name: String = anyMessage()
    ) -> Item {
        
        return .init(category: category, name: name)
    }
    
    private struct Item: Categorized, Equatable {
        
        let category: String
        let name: String
    }
}
