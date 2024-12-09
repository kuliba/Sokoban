//
//  PaymentsParametersReducer.swift
//  Vortex
//
//  Created by Max Gribov on 23.06.2023.
//

import Foundation

protocol PaymentsParametersReducerCase {
    
    var parametersOrder: [Payments.Parameter.Identifier]? { get }
}

enum PaymentsParametersReducer {
    
    static func reduce(
        _ state: [PaymentsParameterRepresentable],
        _ action: (
            new: [PaymentsParameterRepresentable],
            case: some PaymentsParametersReducerCase)
    ) -> [PaymentsParameterRepresentable] {
        
        if let order = action.case.parametersOrder {
            
            let updatedState = order.map { identifier in
                
                action.new.first(where: { $0.id == identifier.rawValue }) ?? state.first(where: { $0.id == identifier.rawValue })
                
            }.compactMap{ $0 }
            
            let newRemain = action.new.filter { updatedState.map(\.id).contains($0.id) == false }
            let oldRemain = state.filter { updatedState.map(\.id).contains($0.id) == false && newRemain.map(\.id).contains($0.id) == false }
            
            return updatedState + oldRemain + newRemain
            
        } else {
            
           let updatedState = state
                .reduce([PaymentsParameterRepresentable]()) { partialResult, param in
                    
                    var updatedResult = partialResult
                    
                    if let newParam = action.new.first(where: { $0.id == param.id }) {
                        
                        updatedResult.append(newParam)
                        
                    } else {
                        
                        updatedResult.append(param)
                    }
                    
                    return updatedResult
                }
            
            let remain = action.new.filter { updatedState.map(\.id).contains($0.id) == false }
            
            return updatedState + remain
        }
    }
}
