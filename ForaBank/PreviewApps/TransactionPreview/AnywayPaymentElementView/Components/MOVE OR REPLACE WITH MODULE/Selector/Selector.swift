//
//  Selector.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

struct Selector<T> {
    
    var selected: T
    let firstOption: T
    let otherOptions: [T]
    var isShowingOptions: Bool
    var searchQuery: String
    let filterPredicate: (T, String) -> Bool
}

extension Selector {
    
    var options: [T] { [firstOption] + otherOptions }
    
    var filteredOptions: [T] {
        
        searchQuery.isEmpty
        ? options
        : options.filter { filterPredicate($0, searchQuery) }
    }
}

extension Selector {
    
    enum Error: Swift.Error {
        
        case emptyOptionsArray
        case selectedOptionNotInOptions
    }
}

extension Selector {
    
    /// Initialiser with options array, setting selected to first option..
    /// - Parameters:
    ///   - options: Array of options.
    ///   - filterPredicate: Predicate to filter options based on a search query.
    /// - Throws: `Selector.Error.emptyOptionsArray` if the options array is empty.
    init(
        options: [T],
        isShowingOptions: Bool = false,
        searchQuery: String = "",
        filterPredicate: @escaping (T, String) -> Bool
    ) throws {
        
        guard let first = options.first else {
            throw Error.emptyOptionsArray
        }
        
        self.firstOption = first
        self.otherOptions = Array(options.dropFirst())
        self.selected = first
        self.isShowingOptions = isShowingOptions
        self.searchQuery = searchQuery
        self.filterPredicate = filterPredicate
    }
}

extension Selector where T: Equatable {
    
    /// Initialiser ensuring the selected option is in the options list.
    /// - Parameters:
    ///   - selected: The selected option.
    ///   - firstOption: The first option in the list.
    ///   - otherOptions: Additional options.
    ///   - filterPredicate: Predicate to filter options based on a search query.
    /// - Throws: `Selector.Error.selectedOptionNotInOptions` if the selected option is not in the options list.
    init(
        selected: T,
        firstOption: T,
        otherOptions: [T],
        isShowingOptions: Bool = false,
        searchQuery: String = "",
        filterPredicate: @escaping (T, String) -> Bool
    ) throws {
        
        let allOptions = [firstOption] + otherOptions
        
        guard allOptions.contains(selected) else {
            throw Error.selectedOptionNotInOptions
        }
        
        self.selected = selected
        self.firstOption = firstOption
        self.otherOptions = otherOptions
        self.isShowingOptions = isShowingOptions
        self.searchQuery = searchQuery
        self.filterPredicate = filterPredicate
    }
    
    /// Ergonomic initialiser with selected option and options array.
    /// - Parameters:
    ///   - selected: The selected option.
    ///   - options: Array of options.
    ///   - filterPredicate: Predicate to filter options based on a search query.
    /// - Throws: `Selector.Error.emptyOptionsArray` if the options array is empty.
    /// - Throws: `Selector.Error.selectedOptionNotInOptions` if the selected option is not in the options list.
    init(
        selected: T,
        options: [T],
        isShowingOptions: Bool = false,
        searchQuery: String = "",
        filterPredicate: @escaping (T, String) -> Bool
    ) throws {
        
        guard let firstOption = options.first else {
            throw Error.emptyOptionsArray
        }
        guard options.contains(selected) else {
            throw Error.selectedOptionNotInOptions
        }
        
        try self.init(
            selected: selected, 
            firstOption: firstOption,
            otherOptions: .init(options.dropFirst()),
            isShowingOptions: isShowingOptions,
            searchQuery: searchQuery,
            filterPredicate: filterPredicate
        )
    }
}

extension Selector where T == String {
    
    /// Convenience initialiser for `String` options.
    /// - Parameters:
    ///   - options: Array of string options.
    ///   - filterPredicate: Predicate to filter options based on a search query.
    /// - Throws: `Selector.Error.emptyOptionsArray` if the options array is empty.
    init(
        options: [T],
        isShowingOptions: Bool = false,
        searchQuery: String = "",
        contains: @escaping (T, String) -> Bool = { $0.contains($1) }
    ) throws {
        
        try self.init(
            options: options, 
            isShowingOptions: isShowingOptions,
            searchQuery: searchQuery,
            filterPredicate: contains
        )
    }
}
