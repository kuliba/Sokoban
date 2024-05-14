//
//  Model+loadOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.02.2024.
//

import ForaTools
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
            
            if let operators = self?.localAgent.load(type: [CachingSberOperator].self) {
                completion(operators.operators(for: payload))
            } else {
                completion([])
            }
        }
    }
}

// MARK: - Mapping

// TODO: - add tests
extension Array where Element == CachingSberOperator {
    
    /// - Warning: expensive with sorting and search. Sorting could be moved to cache.
    func operators(
        for payload: LoadOperatorsPayload<String>
    ) -> [UtilityPaymentOperator] {
        
        // sorting is performed at cache phase
        self.search(searchText: payload.searchText)
            .page(startingAt: payload.operatorID, pageSize: payload.pageSize)
            .map(UtilityPaymentOperator.init(with:))
    }
}

// MARK: - Search

//TODO: complete search and add tests
extension Array where Element == CachingSberOperator {
    
    func search(searchText: String) -> [Element] {
        
        guard !searchText.isEmpty else { return self }
        
        return filter { $0.contains(searchText) }
    }
}

extension CachingSberOperator {
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        return name.localizedCaseInsensitiveContains(searchText)
        || (inn?.localizedCaseInsensitiveContains(searchText) ?? false)
    }
}

// MARK: - Page

extension CachingSberOperator: Identifiable {}

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

// MARK: - Adapters

private extension UtilityPaymentOperator {
    
    init(with sberOperator: CachingSberOperator) {
        
        self.init(
            id: sberOperator.id,
            title: sberOperator.name,
            subtitle: sberOperator.inn,
            icon: sberOperator.icon ?? ""
        )
    }
}
