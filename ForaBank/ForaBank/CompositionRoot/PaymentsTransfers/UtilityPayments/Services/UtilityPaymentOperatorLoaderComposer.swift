//
//  UtilityPaymentOperatorLoaderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.05.2024.
//

import Foundation
import OperatorsListComponents

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
                        afterOperatorID: payload.operatorID,
                        searchText: payload.searchText,
                        pageSize: pageSize),
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
