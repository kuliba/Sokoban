//
//  UtilityPaymentOperatorLoaderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.05.2024.
//

import ForaTools
import Foundation

final class UtilityPaymentOperatorLoaderComposer {
    
    private let model: Model
    private let pageSize: PageSize
    
    init(
        model: Model,
        pageSize: PageSize
    ) {
        self.model = model
        self.pageSize = pageSize
    }
    
    typealias PageSize = Int
}

extension UtilityPaymentOperatorLoaderComposer {
    
    func compose() -> LoadOperators {
        
        return live
    }
    
    struct Payload: Equatable {
        
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
    
    typealias LoadOperatorsCompletion = ([Operator]) -> Void
    typealias LoadOperators = (Payload, @escaping LoadOperatorsCompletion) -> Void
    
    typealias Operator = UtilityPaymentOperator
}

private extension UtilityPaymentOperatorLoaderComposer {
    
    func live(
        payload: Payload,
        completion: @escaping LoadOperatorsCompletion
    ) {
        let payload = LoadOperatorsPayload(
            operatorID: payload.operatorID,
            searchText: payload.searchText,
            pageSize: pageSize
        )
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.model.loadOperators(payload, completion)
        }
    }
}

// MARK: - Live

private extension Model {
    
    func loadOperators(
        _ payload: LoadOperatorsPayload,
        _ completion: @escaping LoadOperatorsCompletion
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
    
    typealias LoadOperatorsCompletion = ([UtilityPaymentOperator]) -> Void
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

// MARK: - Stubs

private extension Array where Element == UtilityPaymentOperator {
    
    static let stub: Self = [.empty, .failing, .single, .multi]
}

private extension UtilityPaymentOperator {
    
    static let empty:   Self = .init("empty", "0", "No Service Operator", "123", type: "utility")
    static let failing: Self = .init("failing", "1", "Failing Operator", "456", type: "utility")
    static let multi:   Self = .init("multi-d1", "2", "Multi Service Operator", "abc", type: "utility")
    static let single:  Self = .init("single-d2", "3", "Single Service Operator", "cde", type: "utility")
    
    private init(_ id: String, _ inn: String, _ title: String, _ icon: String? = nil, type: String) {
        
        self.init(id: id, inn: inn, title: title, icon: icon, type: type)
    }
}
