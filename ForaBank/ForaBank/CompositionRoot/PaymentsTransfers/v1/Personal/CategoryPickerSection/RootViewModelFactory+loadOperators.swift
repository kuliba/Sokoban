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
        payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload,
        completion: @escaping ([PaymentServiceOperator]) -> Void
    ) {
        schedulers.userInitiated.schedule { [weak self] in
            
            guard let self else { return }
            
            // sorting is performed at cache phase
            let page = loadPage(of: [CodableServicePaymentOperator].self, for: payload) ?? []
            completion(page.map(PaymentServiceOperator.init(codable:)))
        }
    }
    
    @inlinable
    func loadOperatorsForCategory(
        category: ServiceCategory,
        completion: @escaping (Result<[PaymentServiceOperator], Error>) -> Void
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
        _ payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    ) -> Bool {
        
        type == payload.categoryType.name && contains(payload.searchText)
    }
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        return name.localizedCaseInsensitiveContains(searchText)
        || inn.localizedCaseInsensitiveContains(searchText)
    }
}

extension UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload: PageQuery {
    
    var id: String? { operatorID }
}

// MARK: - Adapters

private extension PaymentServiceOperator {
    
    init(codable: CodableServicePaymentOperator) {
        
        self.init(
            id: codable.id,
            inn: codable.inn,
            icon: codable.md5Hash,
            name: codable.name,
            type: codable.type
        )
    }
}
