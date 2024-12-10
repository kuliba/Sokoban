//
//  RootViewModelFactory+composedLoadOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2024.
//

import ForaTools

extension RootViewModelFactory {
    
    func composedLoadOperators(
        completion: @escaping ([UtilityPaymentOperator]) -> Void
    ) {
        composedLoadOperators(payload: .init(pageSize: settings.pageSize), completion: completion)
    }
    
    func composedLoadOperators(
        payload: LoadOperatorsPayload,
        completion: @escaping ([UtilityPaymentOperator]) -> Void
    ) {
        schedulers.userInitiated.schedule { [weak self] in
            
            guard let self else { return }
            
            // sorting is performed at cache phase
            let page = loadPage(of: [CachingSberOperator].self, for: payload) ?? []
            completion(page.map(UtilityPaymentOperator.init(codable:)))
        }
    }
}

// MARK: - Load Operators

struct LoadOperatorsPayload: Equatable {
    
    let operatorID: String?
    let searchText: String
    let pageSize: Int
    
    init(
        operatorID: String? = nil,
        searchText: String = "",
        pageSize: Int
    ) {
        self.operatorID = operatorID
        self.searchText = searchText
        self.pageSize = pageSize
    }
}

// MARK: - Helpers

extension CachingSberOperator: Identifiable {}

extension CachingSberOperator: FilterableItem {
    
    func matches(_ payload: LoadOperatorsPayload) -> Bool {
        
        contains(payload.searchText)
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

private extension UtilityPaymentOperator {
    
    init(codable: CachingSberOperator) {
        
        self.init(
            id: codable.id,
            inn: codable.inn,
            title: codable.name,
            icon: codable.md5Hash,
            type: codable.type
        )
    }
}
