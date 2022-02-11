//
//  PaymentsDataModel+Operation.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

extension Payments.Operation {
    
    typealias Parameter = Payments.Parameter
    
    func historyUpdated() -> [[Parameter.Value]] {
        
        var historyUpdated = history
        let update = parameters.map{ $0.parameterValue }
        historyUpdated.append(update)
        
        return historyUpdated
    }
    
    static func historyStepChanged(history: [[Parameter.Value]], value: Parameter.Value) -> Int? {
        
        guard history.count > 0 else {
            return nil
        }
        
        let historyForParameter = history.reduce([Parameter.Value?]()) { partialResult, historyStep in
            
            var updated = partialResult
            
            if let historyValue = historyStep.first(where: { $0.id == value.id }) {
                
                updated.append(historyValue)
                
            } else {
                
                updated.append(nil)
            }
     
            return updated
        }
        
        guard let lastHistoryValue = historyForParameter[history.count - 1], lastHistoryValue.value != value.value else {
            return nil
        }
        
        let historyForParameterDepth = historyForParameter.compactMap{ $0 }.count
        
        return history.count - historyForParameterDepth
    }
    
    static func historyStepChanged(history: [[Parameter.Value]], values: [Parameter.Value]) -> Int? {
        
        return values.compactMap{ historyStepChanged(history: history, value: $0)}.min()
    }
}
