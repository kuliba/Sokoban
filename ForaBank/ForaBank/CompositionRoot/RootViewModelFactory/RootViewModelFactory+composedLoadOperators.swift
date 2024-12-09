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
        composedLoadOperators(payload: .init(), completion: completion)
    }
    
    func composedLoadOperators(
        payload: UtilityPaymentOperatorLoaderComposerPayload<UtilityPaymentOperator>,
        completion: @escaping ([UtilityPaymentOperator]) -> Void
    ) {
        let payload = LoadOperatorsPayload(
            operatorID: payload.operatorID,
            searchText: payload.searchText,
            pageSize: settings.pageSize
        )
        
        schedulers.userInitiated.schedule { [weak self] in
            
            guard let self else { return }
            
            // sorting is performed at cache phase
            let page = loadPage(of: [CachingSberOperator].self, for: payload) ?? []
            completion(page.map(UtilityPaymentOperator.init(codable:)))
        }
    }
}

struct UtilityPaymentOperatorLoaderComposerPayload<Operator: Identifiable>: Equatable {
    
    let operatorID: Operator.ID?
    let searchText: String
    
    init(
        operatorID: Operator.ID? = nil,
        searchText: String = ""
    ) {
        self.operatorID = operatorID
        self.searchText = searchText
    }
}

// MARK: - Load Operators

struct LoadOperatorsPayload: Equatable {
    
    let operatorID: String?
    let searchText: String
    let pageSize: Int
}

// MARK: - Helpers

extension CachingSberOperator: Identifiable {}

extension CachingSberOperator: FilterableItem {
    
    func matches(_ payload: LoadOperatorsPayload) -> Bool {
        
        contains(payload.searchText)
    }
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        return title.localizedCaseInsensitiveContains(searchText)
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
            title: codable.title,
            icon: codable.md5Hash,
            type: codable.type
        )
    }
}
