//
//  CategorizedStorage.swift
//
//
//  Created by Igor Malyarov on 28.12.2024.
//

/// A protocol describing items that have an associated category.
public protocol Categorized<Category> {
    
    associatedtype Category
    
    /// The category to which this item belongs.
    var category: Category { get }
}

/// A storage container that organizes items by their category and associates
/// a "serial" value with each category.
public struct CategorizedStorage<Category, T>
where Category: Hashable,
      T: Categorized<Category> {
    
    /// Internal mapping of each category to its stored items and serial.
    private let entries: [Category: Entry]
    
    /// Creates a new instance from a specified dictionary of entries.
    public init(entries: [Category: Entry]) {
        
        self.entries = entries
    }
    
    /// Represents the items and serial value associated with a particular category.
    public struct Entry {
        
        /// All items that share this entry’s category.
        public let items: [T]
        
        /// A string that may serve as a hash, version, identifier, or revision for this category.
        public let serial: String
        
        public init(
            items: [T],
            serial: String
        ) {
            self.items = items
            self.serial = serial
        }
    }
}

extension CategorizedStorage: Equatable where Category: Equatable, T: Equatable {}
extension CategorizedStorage.Entry: Equatable where Category: Equatable, T: Equatable {}

extension CategorizedStorage: Codable where Category: Codable, T: Codable {}
extension CategorizedStorage.Entry: Codable where Category: Codable, T: Codable {}

public extension CategorizedStorage {
    
    /// Returns a list of all categories currently stored.
    ///
    /// - Returns: An array of distinct categories present in the storage.
    var categories: [Category] { return .init(entries.keys) }
    
    /// Creates a storage by grouping items by category, assigning the same serial to each group.
    ///
    /// - If `items` is empty, an empty storage is created.
    /// - Each unique category in `items` receives a separate entry.
    ///
    /// - Parameters:
    ///   - items: The array of items to store.
    ///   - serial: A common serial value applied to every category in `items`.
    init(items: [T], serial: String) {
        
        guard !items.isEmpty
        else {
            self.init(entries: [:])
            return
        }
        
        let grouped = Dictionary(grouping: items, by: \.category)
        let entries = grouped.mapValues { Entry(items: $0, serial: serial) }
        
        self.init(entries: entries)
    }
    
    /// Retrieves all items for the specified `category`, or `nil` if none exist.
    ///
    /// - Parameter category: The category whose items should be retrieved.
    /// - Returns: An optional array of items belonging to the given category.
    func items(for category: Category) -> [T]? {
        
        entries[category]?.items
    }
    
    /// Merges `newStorage` into the current storage based on serial comparison.
    ///
    /// - Categories with **identical serials** in both storages remain unchanged.
    /// - Categories with **differing serials** are replaced with `newStorage`’s data.
    /// - Categories **exclusive to `newStorage`** are added to the current storage.
    ///
    /// - Parameter newStorage: The storage to merge into the current instance.
    /// - Returns: A tuple `(updatedStorage, changed)`, where:
    ///   - `updatedStorage` contains the merged data.
    ///   - `changed` is `true` if at least one category was modified.
    func merged(
        with newStorage: Self
    ) -> (Self, Bool) {
        
        Self.merge(self, newStorage)
    }
    
    /// Retrieves the serial value for the specified `category`, or `nil` if the category is absent.
    ///
    /// - Parameter category: The category whose serial should be retrieved.
    /// - Returns: The serial value associated with the category, or `nil` if not found.
    func serial(for category: Category) -> String? {
        
        entries[category]?.serial
    }
    
    /// Returns a copy of the storage in which the given `category` is updated with
    /// the provided `items` and a new `serial`.
    ///
    /// - If `items` is empty, the category's existing items will be replaced with an empty list.
    /// - Only items matching `category` are stored; items from other categories are ignored.
    ///
    /// - Parameters:
    ///   - category: The category to update.
    ///   - items: The list of items to store under the given category.
    ///   - serial: The new serial value for the category.
    /// - Returns: A new `CategorizedStorage` instance with the updated category.
    func updated(category: Category, items: [T], serial: String) -> Self {
        
        var entries = self.entries
        let matching = items.filter { $0.category == category }
        entries[category] = .init(items: matching, serial: serial)
        
        return .init(entries: entries)
    }
    
    /// Returns a copy of the storage where the first item's category is updated with new data.
    ///
    /// - Important: Only updates the category of the first item in the given list.
    ///   If multiple categories exist in `items`, only the first category is affected.
    ///
    /// - Parameters:
    ///   - items: The list of items to insert.
    ///   - serial: The new serial value for the updated category.
    /// - Returns: A new `CategorizedStorage` instance with the updated category,
    ///   or the original storage if `items` is empty.
    func updated(items: [T], serial: String) -> Self {
        
        guard let firstCategory = items.first?.category
        else { return self }
        
        return updated(category: firstCategory, items: items, serial: serial)
    }
    
    /// Searches all items across all categories for a specific value in the field
    /// specified by the `keyPath`.
    ///
    /// - Parameters:
    ///   - value: The value to search for.
    ///   - keyPath: The key path of the field in `T` to search within.
    /// - Returns: An array of all matching items across all categories.
    func search<Value: Equatable>(
        for value: Value,
        in keyPath: KeyPath<T, Value>
    ) -> [T] {
        
        return entries.values
            .lazy
            .flatMap { $0.items }
            .filter { $0[keyPath: keyPath] == value }
    }
}

public extension CategorizedStorage {
    
    /// Merges `newStorage` into `oldStorage` based on serial comparison.
    ///
    /// - Categories with **identical serials** in both storages remain unchanged.
    /// - Categories with **differing serials** are replaced with `newStorage`’s data.
    /// - Categories **exclusive to `newStorage`** are added to `oldStorage`.
    ///
    /// - Parameters:
    ///   - oldStorage: The original storage.
    ///   - newStorage: The storage with new data.
    /// - Returns: A tuple `(updatedStorage, changed)`, where:
    ///   - `updatedStorage` contains the merged data.
    ///   - `changed` is `true` if at least one category was modified.
    static func merge(
        _ oldStorage: Self,
        _ newStorage: Self
    ) -> (Self, Bool) {
        
        var merged = oldStorage
        var changed = false
        
        for category in newStorage.categories {
            
            guard let newEntry = newStorage.entries[category],
                  oldStorage.serial(for: category) != newEntry.serial
            else { continue }
            
            merged = merged.updated(
                category: category,
                items: newEntry.items,
                serial: newEntry.serial
            )
            changed = true
        }
        
        return (merged, changed)
    }
}
