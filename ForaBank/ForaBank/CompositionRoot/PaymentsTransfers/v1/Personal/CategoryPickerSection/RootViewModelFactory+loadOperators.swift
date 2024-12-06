//
//  RootViewModelFactory+loadCachedOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

extension RootViewModelFactory {
    
#warning("duplication - see UtilityPaymentOperatorLoaderComposer")
    
    @inlinable
    func loadCachedOperators(
        payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload,
        completion: @escaping ([PaymentServiceOperator]) -> Void
    ) {
        schedulers.background.schedule { [weak self] in
            
            guard let self else { return }
            
            let operators: [CodableServicePaymentOperator] = logDecoratedLocalLoad() ?? []
            completion(operators.pageOfOperators(for: payload))
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

extension Array where Element == CodableServicePaymentOperator {
    
    /// - Warning: expensive with sorting and search. Sorting is expected to happen at cache phase.
    func pageOfOperators(
        for payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    ) -> [PaymentServiceOperator] {
        
        // sorting is performed at cache phase
        return self
            .filter { $0.matches(payload) }
            .page(startingAfter: payload.operatorID, pageSize: payload.pageSize)
            .map(PaymentServiceOperator.init(codable:))
    }
}

// MARK: - Helpers

extension CodableServicePaymentOperator {
    
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

private extension PaymentServiceOperator {
    
    init(codable: CodableServicePaymentOperator) {
        
        self.init(
            id: codable.id,
            inn: codable.inn,
            md5Hash: codable.md5Hash,
            name: codable.name,
            type: codable.type
        )
    }
}
