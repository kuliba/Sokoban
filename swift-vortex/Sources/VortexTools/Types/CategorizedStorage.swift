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
    
    /// All categories that currently exist in this storage.
    var categories: [Category] { return .init(entries.keys) }
    
    /// Creates a storage by grouping items by category, assigning the same serial to each group.
    ///
    /// - Parameters:
    ///   - items: The array of items to store.
    ///   - serial: A common string identifier applied to every category in these items.
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
    func items(for category: Category) -> [T]? {
        
        entries[category]?.items
    }
    
    /// Retrieves the serial value for the specified `category`, or `nil` if none exist.
    func serial(for category: Category) -> String? {
        
        entries[category]?.serial
    }
    
    /// Returns a copy of the storage in which the given `category` is updated with
    /// the filtered `items` and a new `serial`. Only items matching `category` are stored.
    func updated(category: Category, items: [T], serial: String) -> Self {
        
        var entries = self.entries
        let matching = items.filter { $0.category == category }
        entries[category] = .init(items: matching, serial: serial)
        
        return .init(entries: entries)
    }
    
    /// Returns a copy of the storage in which the single category determined by
    /// the first item is updated with a new `serial`.
    ///
    /// - Note: Only items matching that first item’s category are included.
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
            .flatMap { $0.items }
            .filter { $0[keyPath: keyPath] == value }
    }
}

public extension CategorizedStorage {
    
    /// Merges `newStorage` into `oldStorage` by comparing their serial:
    /// - If a category's serial in `oldStorage` matches the one in `newStorage`, that category remains unchanged.
    /// - Otherwise, the new category data (items + serial) overwrites the old.
    ///
    /// Returns a tuple of `(updatedStorage, changed)`.
    ///
    /// - Parameters:
    ///   - oldStorage: The original storage to be updated.
    ///   - newStorage: The storage providing new data.
    /// - Returns: A tuple of `(mergedStorage, changed)` where `changed` is `true`
    ///   if at least one category was updated, otherwise `false`.
    static func merge(
        _ oldStorage: Self,
        _ newStorage: Self
    ) -> (Self, Bool) {
        
        var merged = oldStorage
        var changed = false
        
        for category in newStorage.categories {
            guard let newSerial = newStorage.serial(for: category),
                  oldStorage.serial(for: category) != newSerial
            else { continue }
            
            let items = newStorage.items(for: category) ?? []
            merged = merged.updated(category: category, items: items, serial: newSerial)
            changed = true
        }
        
        return (merged, changed)
    }
}
