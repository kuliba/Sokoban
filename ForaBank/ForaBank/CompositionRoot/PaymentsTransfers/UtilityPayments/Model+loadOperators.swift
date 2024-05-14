//
//  Model+loadOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.02.2024.
//

import Foundation
import OperatorsListComponents

extension Model {
    
    typealias Payload = LoadOperatorsPayload<String>
    typealias LoadOperatorsResult = [UtilityPaymentOperator]
    typealias LoadOperatorsCompletion = (LoadOperatorsResult) -> Void
    
    func loadOperators(
        _ payload: Payload,
        _ completion: @escaping LoadOperatorsCompletion
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let operatorGroups = self?.localAgent.load(type: [SberOperator].self) {
                completion(operatorGroups.operators(for: payload))
            } else {
                completion([])
            }
        }
    }
}

// MARK: - Mapping

// TODO: - add tests
extension Array where Element == SberOperator {
    
#warning("sort is very expensive, should be moved to cache")
    /// - Warning: expensive with sorting and search. Sorting could be moved to cache.
    func operators(
        for payload: LoadOperatorsPayload<String>
    ) -> [UtilityPaymentOperator] {
        
        self.search(searchText: payload.searchText)
        // TODO: - move sorting to caching
            .sorted { $0.precedes($1) }
            .page(startingAt: payload.operatorID, pageSize: payload.pageSize)
            .map(UtilityPaymentOperator.init(with:))
    }
}

// MARK: - Sorting

// TODO: add tests
extension SberOperator {
    
    var inn: String { description }
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        return title.localizedCaseInsensitiveContains(searchText)
        || inn.localizedCaseInsensitiveContains(searchText)
    }
    
    func precedes(_ other: Self) -> Bool {
        
        if title == other.title {
            return inn.customLexicographicallyPrecedes(other.inn)
        } else {
            return title.customLexicographicallyPrecedes(other.title)
        }
    }
}

// MARK: - Search

//TODO: complete search and add tests
extension Array where Element == SberOperator {
    
    func search(searchText: String) -> [Element] {
        
        guard !searchText.isEmpty else { return self }
        
        return filter { $0.contains(searchText) }
    }
}

private extension String {
    
    /// Custom method to compare strings based on character priorities.
    func customLexicographicallyPrecedes(
        _ other: String
    ) -> Bool {
        
        let minLength = min(self.count, other.count)
        
        for i in 0..<minLength {
            
            let selfChar = self[index(startIndex, offsetBy: i)]
            let otherChar = other[other.index(startIndex, offsetBy: i)]
            
            if selfChar.characterSortPriority() != otherChar.characterSortPriority() {
                return selfChar.characterSortPriority() < otherChar.characterSortPriority()
            } else if selfChar != otherChar {
                return selfChar < otherChar
            }
        }
        
        return self.count < other.count
    }
}

private extension Character {
    
    /// Determine the custom priority of the character.
    func characterSortPriority() -> Int {
        
        let s = String(self)
        
        if s.range(of: "\\p{InCyrillic}", options: .regularExpression) != nil {
            return 1  // Priority 1 for Cyrillic characters
        } else if s.range(of: "[A-Za-z]", options: .regularExpression) != nil {
            return 2  // Priority 2 for Latin characters
        } else if s.range(of: "[0-9]", options: .regularExpression) != nil {
            return 3  // Priority 3 for numbers
        }
        
        return 4
    }
}

// MARK: - Page

//TODO: add test and move to ForaTools
extension Array where Element: Identifiable {
    
    func page(
        startingAt id: Element.ID?,
        pageSize: Int
    ) -> Self {
        
        switch id {
        case .none:
            return .init(prefix(pageSize))
            
        case let .some(id):
            return page(startingAt: id, pageSize: pageSize)
        }
        
    }
}

extension ArraySlice where Element: Identifiable {
    
    func page(startingAt id: Element.ID?, pageSize: Int) -> Self {
        
        switch id {
        case .none:
            return prefix(pageSize)
            
        case let .some(id):
            return page(startingAt: id, pageSize: pageSize)
        }
        
    }
}

extension ArraySlice where Element: Identifiable {
    
    /// Return a slice of the array starting from the element with given `id`, up to the specified `pageSize`.
    /// If the element with the given ID is not found, return an empty array.
    func page(
        startingAt id: Element.ID,
        pageSize: Int
    ) -> Self {
        
        guard let startIndex = self.firstIndex(where: { $0.id == id })
        else { return [] }
        
        let endIndex = index(startIndex, offsetBy: pageSize, limitedBy: count) ?? count
        return self[startIndex..<endIndex]
    }
    
    /// Return a slice of the array starting `after` the element with given `id`, up to the specified `pageSize`.
    /// If the element with the given ID is not found, return an empty array.
    func page(
        startingAfter id: Element.ID,
        pageSize: Int
    ) -> Self {
        
        guard let startIndex = self.firstIndex(where: { $0.id == id })
        else { return [] }
        
        let nextIndex = index(startIndex, offsetBy: 1, limitedBy: count) ?? count
        let endIndex = index(nextIndex, offsetBy: pageSize, limitedBy: count) ?? count
        return self[nextIndex..<endIndex]
    }
}

// MARK: - Adapters

private extension UtilityPaymentOperator {
    
    init(with operatorGroup: SberOperator) {
        
        self.init(
            id: operatorGroup.id,
            title: operatorGroup.title,
            subtitle: operatorGroup.description as! Subtitle,
            icon: operatorGroup.md5hash as! Icon
        )
    }
}
