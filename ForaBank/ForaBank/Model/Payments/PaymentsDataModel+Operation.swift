//
//  PaymentsDataModel+Operation.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

extension Payments.Operation {
    
    typealias Parameter = Payments.Parameter
    
    func historyUpdated() -> [[Parameter]] {
        
        var historyUpdated = history
        let update = Self.history(for: parameters)
        historyUpdated.append(update)
        
        return historyUpdated
    }
    
    //TODO: Tests
    func update(with results: [Parameter]) -> Update {
        
        if let historyChangedStep = historyChangedStep(history: history, results: results) {
            
            let historyStep = history[historyChangedStep]
            let historyStepParametersIds = historyStep.map{ $0.id }
            let historyStepParameters = self.parameters.filter{ historyStepParametersIds.contains($0.parameter.id) }
            
            var updatedHistoryStepParameters = [ParameterRepresentable]()
            for param in historyStepParameters {
                
                guard let value = results.first(where: { $0.id == param.parameter.id })?.value else {
                    continue
                }
                
                updatedHistoryStepParameters.append(param.updated(value: value))
            }
            
            var historyTrimmed = [[Parameter]]()
            for index in 0..<historyChangedStep {
                
                historyTrimmed.append(history[index])
            }
  
            return .init(operation: .init(service: service, parameters: updatedHistoryStepParameters, history: historyTrimmed), type: .historyChanged)
            
        } else {
            
            var updatedParameters = [ParameterRepresentable]()
            
            for result in results {
                
                guard let index = parameters.firstIndex(where: { $0.parameter.id == result.id }) else {
                    continue
                }
                
                updatedParameters.append(parameters[index].updated(value: result.value))
            }
            
            return .init(operation: .init(service: service, parameters: updatedParameters, history: history), type: .normal)
        }
    }
    
    //TODO: Tests
    static func history(for parameters: [ParameterRepresentable]) -> [Parameter] {
        
        parameters.map{ $0.parameter }.filter{ $0.value != nil }
    }
        
    func historyChangedStep(history: [[Parameter]], result: Parameter) -> Int? {
        
        guard history.count > 0 else {
            return nil
        }
        
        let historyForParameter = history.reduce([Parameter]()) { partialResult, historyStep in
            
            var updated = partialResult
            
            if let historyValue = historyStep.first(where: { $0.id == result.id }) {
                
                updated.append(historyValue)
            }
     
            return updated
        }
        
        guard historyForParameter.count > 0 else {
            return nil
        }
        
        let lastHistoryParameter = historyForParameter[historyForParameter.count - 1]
        
        guard lastHistoryParameter.value != result.value else {
            return nil
        }
        
        let historyForParameterDepth = historyForParameter.compactMap{ $0 }.count
        
        return history.count - historyForParameterDepth
    }
    
    func historyChangedStep(history: [[Parameter]], results: [Parameter]) -> Int? {
        
        return results.compactMap{ historyChangedStep(history: history, result: $0)}.min()
    }
    
    static let emptyMock = Payments.Operation(service: .fms, parameters: [], history: [[]])
}

extension Payments.Operation {
    
    struct Update {
        
        let operation: Payments.Operation
        let type: Kind
        
        enum Kind {
            
            case normal
            case historyChanged
        }
    }
    
    enum Error: Swift.Error {
        
        case unableSelectServiceForCategory(Payments.Category)
        case operatorNotSelectedForService(Payments.Service)
    }
}
