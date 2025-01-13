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
    
    @inlinable
    func loadOperatorsForCategory(
        category: ServiceCategory,
        completion: @escaping (Result<[UtilityPaymentProvider], Error>) -> Void
    ) {
        loadCachedOperators(
            payload: .init(
                categoryType: category.type,
                pageSize: settings.pageSize
            )
        ) {
            completion(.success($0))
        }
    }
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
