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
    private let flag: Flag
    private let pageSize: PageSize
    
    init(
        model: Model,
        flag: Flag,
        pageSize: PageSize
    ) {
        self.model = model
        self.flag = flag
        self.pageSize = pageSize
    }
}

extension UtilityPaymentOperatorLoaderComposer {
    
    typealias Flag = StubbedFeatureFlag.Option
    typealias PageSize = Int
}

extension UtilityPaymentOperatorLoaderComposer {
    
    func compose() -> LoadOperators {
        
        return { [weak self] payload, completion in
            
            guard let self else { return }
            
            switch flag {
            case .live:
                model.loadOperators(
                    .init(
                        operatorID: payload.operatorID,
                        searchText: payload.searchText,
                        pageSize: pageSize
                    ),
                    completion
                )
                
            case .stub:
                DispatchQueue.main.delay(for: .seconds(1)) {
                    switch payload.operatorID {
                    case .none:
                        completion(.stub)
                        
                    case .some:
                        completion([])
                    }
                }
            }
        }
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

// MARK: - Live

private extension Model {
    
    func loadOperators(
        _ payload: LoadOperatorsPayload,
        _ completion: @escaping LoadOperatorsCompletion
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let operators = self?.localAgent.load(type: [CachingSberOperator].self) {
                completion(operators.operators(for: payload))
            } else {
                completion([])
            }
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
    
    /// - Warning: expensive with sorting and search. Sorting could be moved to cache.
    func operators(
        for payload: LoadOperatorsPayload
    ) -> [UtilityPaymentOperator] {
        
        // sorting is performed at cache phase
        let operators = self
            .search(searchText: payload.searchText)
            .page(startingAt: payload.operatorID, pageSize: payload.pageSize)
            .map(UtilityPaymentOperator.init(with:))
        
        return operators
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
        
        return name.localizedCaseInsensitiveContains(searchText)
        || (inn?.localizedCaseInsensitiveContains(searchText) ?? false)
    }
}

// MARK: - Page

extension CachingSberOperator: Identifiable {}

// MARK: - Adapters

private extension UtilityPaymentOperator {
    
    init(with sberOperator: CachingSberOperator) {
        
        self.init(
            id: sberOperator.id,
            title: sberOperator.name,
            subtitle: sberOperator.inn,
            icon: sberOperator.icon ?? ""
        )
    }
}

// MARK: - Stubs

private extension Array where Element == UtilityPaymentOperator {
    
    static let stub: Self = [
        .single,
        .singleFailure,
        .multiple,
        .multipleFailure,
    ]
}

private extension UtilityPaymentOperator {
    
    static let multiple: Self = .init("multiple", "Multiple")
    static let multipleFailure: Self = .init("multipleFailure", "MultipleFailure")
    static let single: Self = .init("single", "Single")
    static let singleFailure: Self = .init("singleFailure", "SingleFailure")
    
    private init(_ id: String, _ title: String) {
        
        self.init(id: id, title: title, subtitle: nil, icon: "abc")
    }
}
