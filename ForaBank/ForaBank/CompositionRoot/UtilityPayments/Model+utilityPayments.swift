//
//  Model+utilityPayments.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.02.2024.
//

import Foundation
import OperatorsListComponents

extension Model {
    
    typealias Payload = (id: OperatorsListComponents.Operator.ID?, pageSize: Int)
    typealias LoadOperatorsResult = Result<[OperatorsListComponents.Operator], Error>
    typealias LoadOperatorsCompletion = (LoadOperatorsResult) -> Void
    
    func loadOperators(
        _ payload: Payload,
        _ completion: @escaping LoadOperatorsCompletion
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self else { return }
            
            guard let operatorGroups = localAgent.load(type: [_OperatorGroup].self)
            else {
                completion(.failure(LoadOperatorsFailure()))
                return
            }
            
            switch payload.id {
            case .none:
                let operators = operatorGroups
                    .prefix(payload.pageSize)
                    .map(OperatorsListComponents.Operator.init)
                completion(.success(operators))
                
            case let .some(id):
                let operators = operatorGroups
                    .page(startingAt: id, pageSize: payload.pageSize)
                    .map(OperatorsListComponents.Operator.init)
            }
        }
    }
    
    struct LoadOperatorsFailure: Error {}
}

private extension OperatorsListComponents.Operator {
    
    init(_ operatorGroup: OperatorGroup) {
        
        self.init(
            id: operatorGroup.title,
            title: operatorGroup.title,
            subtitle: operatorGroup.description,
            image: nil
        )
    }
}

extension Array where Element: Identifiable {
    
    /// Return a slice of the array starting from the element with given `id`, up to the specified `pageSize`.
    /// If the element with the given ID is not found, return an empty array.
    func page(
        startingAt id: Element.ID,
        pageSize: Int
    ) -> Self {
        
        guard let startIndex = self.firstIndex(where: { $0.id == id })
        else { return [] }
        
        let endIndex = index(startIndex, offsetBy: pageSize, limitedBy: count) ?? count
        return .init(self[startIndex..<endIndex])
    }
}
