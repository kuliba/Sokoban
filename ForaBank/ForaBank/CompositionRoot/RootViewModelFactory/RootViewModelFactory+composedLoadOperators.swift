//
//  RootViewModelFactory+composedLoadOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2024.
//

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
            
            let operators: [CachingSberOperator] = logDecoratedLocalLoad() ?? []
            let page = operators.pageOfOperators(for: payload)
            debugLog(pageCount: page.count, of: operators.count)
            completion(page)
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

// MARK: - Mapping

// TODO: - add tests
extension Array where Element == CachingSberOperator {
    
    /// - Warning: expensive with sorting and search. Sorting is expected to happen at cache phase.
    func pageOfOperators(
        for payload: LoadOperatorsPayload
    ) -> [UtilityPaymentOperator] {
        
        // sorting is performed at cache phase
        return self
            .search(searchText: payload.searchText)
            .page(startingAfter: payload.operatorID, pageSize: payload.pageSize)
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
        
        return title.localizedCaseInsensitiveContains(searchText)
        || inn.localizedCaseInsensitiveContains(searchText)
    }
}

// MARK: - Page

extension CachingSberOperator: Identifiable {}

// MARK: - Adapters

private extension UtilityPaymentOperator {
    
    init(with sberOperator: CachingSberOperator) {
        
        self.init(
            id: sberOperator.id,
            inn: sberOperator.inn,
            title: sberOperator.title,
            icon: sberOperator.md5Hash,
            type: sberOperator.type
        )
    }
}
