//
//  RootViewModelFactory+loadOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func loadOperators(
        payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload,
        completion: @escaping ([PaymentServiceOperator]) -> Void
    ) {
        schedulers.background.schedule { [weak self] in
            
            self?.model.loadOperators(payload, completion)
        }
    }
    
    @inlinable
    func loadOperatorsForCategory(
        category: ServiceCategory,
        completion: @escaping (Result<[PaymentServiceOperator], Error>) -> Void
    ) {
        loadOperators(
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

#warning("duplication - see UtilityPaymentOperatorLoaderComposer")

private extension Model {
    
    func loadOperators(
        _ payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload,
        _ completion: @escaping LoadOperatorsCompletion
    ) {
        let log = LoggerAgent().log
        let cacheLog = { log(.debug, .cache, $0, $1, $2) }
        
        if let operators = localAgent.load(type: [CodableServicePaymentOperator].self) {
            cacheLog("Total Operators count \(operators.count)", #file, #line)
            
            let page = operators.operators(for: payload)
            cacheLog("Operators page count \(page.count) for \(payload.categoryType.name)", #file, #line)
            
            completion(page)
        } else {
            cacheLog("No more Operators", #file, #line)
            completion([])
        }
    }
    
    typealias LoadOperatorsCompletion = ([PaymentServiceOperator]) -> Void
}

// TODO: - add tests
extension Array where Element == CodableServicePaymentOperator {
    
    /// - Warning: expensive with sorting and search. Sorting is expected to happen at cache phase.
    func operators(
        for payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    ) -> [PaymentServiceOperator] {
        
        // sorting is performed at cache phase
        return self
            .filter { $0.matches(payload) }
            .page(startingAfter: payload.operatorID, pageSize: payload.pageSize)
            .map(PaymentServiceOperator.init(codable:))
    }
}

// MARK: - Search

// TODO: - add tests
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
