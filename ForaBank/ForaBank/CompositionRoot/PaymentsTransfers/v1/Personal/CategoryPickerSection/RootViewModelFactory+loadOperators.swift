//
//  RootViewModelFactory+loadCachedOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import ForaTools

extension RootViewModelFactory {
    
    @inlinable
    func loadCachedOperators(
        payload: UtilityPrepaymentNanoServices<UtilityPaymentProvider>.LoadOperatorsPayload,
        completion: @escaping ([UtilityPaymentProvider]) -> Void
    ) {
        schedulers.userInitiated.schedule { [weak self] in
            
            guard let self else { return }
            
            // sorting is performed at cache phase
            let page = loadPage(of: [CodableServicePaymentOperator].self, for: payload) ?? []
            completion(page.map(UtilityPaymentProvider.init(codable:)))
        }
    }
    
    @inlinable
    func loadOperatorsForCategory(
        category: ServiceCategory,
        completion: @escaping (Result<[UtilityPaymentProvider], Error>) -> Void
    ) {
        loadCachedOperators(
            payload: .init(
                afterOperatorID: nil,
                for: category.type,
                searchText: "",
                pageSize: settings.pageSize
            )
        ) {
            completion(.success($0))
        }
    }
}

// MARK: - Helpers

extension CodableServicePaymentOperator: FilterableItem {
    
    func matches(
        _ payload: UtilityPrepaymentNanoServices<UtilityPaymentProvider>.LoadOperatorsPayload
    ) -> Bool {
        
        type == payload.categoryType.name && contains(payload.searchText)
    }
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        return name.localizedCaseInsensitiveContains(searchText)
        || inn.localizedCaseInsensitiveContains(searchText)
    }
}

extension UtilityPrepaymentNanoServices<UtilityPaymentProvider>.LoadOperatorsPayload: PageQuery {
    
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
