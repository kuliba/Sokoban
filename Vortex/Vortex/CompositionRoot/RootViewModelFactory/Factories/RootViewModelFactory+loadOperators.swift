//
//  RootViewModelFactory+loadCachedOperators.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.11.2024.
//

import VortexTools

extension RootViewModelFactory {
    
    @inlinable
    func loadCachedOperators(
        forCategory category: ServiceCategory,
        completion: @escaping (Result<[UtilityPaymentProvider], Error>) -> Void
    ) {
        loadCachedOperators(
            forCategoryType: category.type
        ) {
            completion(.success($0))
        }
    }
    
    @inlinable
    func loadCachedOperators(
        forCategoryType categoryType: ServiceCategory.CategoryType,
        completion: @escaping ([UtilityPaymentProvider]) -> Void
    ) {
        loadCachedOperators(
            payload: .init(
                categoryType: categoryType,
                pageSize: settings.pageSize
            ),
            completion: completion
        )
    }
    
    @inlinable
    func loadCachedOperators(
        payload: LoadOperatorsPayload,
        completion: @escaping ([UtilityPaymentProvider]) -> Void
    ) {
        schedulers.userInitiated.schedule { [weak self] in
            
            guard let self else { return }
            
            // sorting is performed at cache phase
            let page = loadPage(of: [CodableServicePaymentOperator].self, for: payload) ?? []
            completion(page.map(UtilityPaymentProvider.init(codable:)))
        }
    }
}

struct LoadOperatorsPayload: Equatable {
    
    let categoryType: ServiceCategory.CategoryType
    let operatorID: String?
    let searchText: String
    let pageSize: Int
    
    init(
        categoryType: ServiceCategory.CategoryType,
        operatorID: String? = nil,
        searchText: String = "",
        pageSize: Int
    ) {
        self.categoryType = categoryType
        self.operatorID = operatorID
        self.searchText = searchText
        self.pageSize = pageSize
    }
}

// MARK: - Helpers

extension CodableServicePaymentOperator: FilterableItem {
    
    func matches(_ payload: LoadOperatorsPayload) -> Bool {
        
        type == payload.categoryType && contains(payload.searchText)
    }
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        return name.localizedCaseInsensitiveContains(searchText)
        || inn.localizedCaseInsensitiveContains(searchText)
    }
}

extension LoadOperatorsPayload: PageQuery {
    
    var id: String? { operatorID }
}

// MARK: - Adapters

private extension UtilityPaymentProvider {
    
    init(codable: CodableServicePaymentOperator) {
        
        self.init(
            id: codable.id,
            icon: codable.md5Hash,
            inn: codable.inn,
            title: codable.name,
            type: codable.type
        )
    }
}
