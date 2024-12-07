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
            
            self?.model.loadOperators(payload, completion)
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

#warning("duplication: see RootViewModelFactory+loadCachedOperators")

private extension Model {
    
    func loadOperators(
        _ payload: LoadOperatorsPayload,
        _ completion: @escaping ([UtilityPaymentOperator]) -> Void
    ) {
        let log = LoggerAgent().log
        let cacheLog = { log(.debug, .cache, $0, $1, $2) }
        
        if let operators = localAgent.load(type: [CachingSberOperator].self) {
            cacheLog("Operators count \(operators.count)", #file, #line)
            
            let page = operators.operators(for: payload)
            cacheLog("Operators page count \(page.count)", #file, #line)
            
            completion(page)
        } else {
            cacheLog("No more Operators", #file, #line)
            completion([])
        }
    }
    
}

struct LoadOperatorsPayload: Equatable {
    
    let operatorID: String?
    let searchText: String
    let pageSize: Int
}

// MARK: - Mapping

// TODO: - add tests
extension Array where Element == CachingSberOperator {
    
    /// - Warning: expensive with sorting and search. Sorting is expected to happen at cache phase.
    func operators(
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
