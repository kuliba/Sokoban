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
        
        //FIXME: refactor
        return [[]]
        /*
        var historyUpdated = history
        let update = Self.history(for: parameters)
        historyUpdated.append(update)
        
        return historyUpdated
         */
    }
    
    //TODO: Tests
    func update(with results: [(param: Parameter, affectsHistory: Bool)]) -> Update {
        
        //FIXME: refactor
        
        return Update(operation: .emptyMock, type: .historyChanged)

        /*
        if let historyChangedStep = historyChangedStep(history: history, results: results) {
            
            let historyStep = history[historyChangedStep]
            let historyStepParametersIds = historyStep.map{ $0.id }
            let historyStepParameters = self.parameters.filter{ historyStepParametersIds.contains($0.parameter.id) }
            
            var updatedHistoryStepParameters = [PaymentsParameterRepresentable]()
            
            for param in historyStepParameters {
                
                if let update = results.first(where: { $0.param.id == param.parameter.id })?.param.value {
                    
                    updatedHistoryStepParameters.append(param.updated(value: update))
                    
                } else {
                    
                    updatedHistoryStepParameters.append(param)
                }
            }
            
            var historyTrimmed = [[Parameter]]()
            for index in 0..<historyChangedStep {
                
                historyTrimmed.append(history[index])
            }
  
            return .init(operation: .init(service: service, parameters: updatedHistoryStepParameters, history: historyTrimmed), type: .historyChanged)
            
        } else {
            
            var updatedParameters = [PaymentsParameterRepresentable]()
            
            for parameter in parameters {
                
                if let update = results.first(where: { $0.param.id == parameter.parameter.id }) {
                    
                    updatedParameters.append(parameter.updated(value: update.param.value))
                    
                } else {
                    
                    updatedParameters.append(parameter)
                }
            }
            
            /*
            for result in results {
                
                guard let index = parameters.firstIndex(where: { $0.parameter.id == result.param.id }) else {
                    continue
                }
                
                updatedParameters.append(parameters[index].updated(value: result.param.value))
            }
             */
            
            return .init(operation: .init(service: service, parameters: updatedParameters, history: history), type: .normal)
        }
         */
    }
    
    //TODO: Tests
    static func history(for parameters: [PaymentsParameterRepresentable]) -> [Parameter] {
        
        parameters.map{ $0.parameter }.filter{ $0.value != nil }
    }
        
    func historyChangedStep(history: [[Parameter]], result: (param: Parameter, affectsHistory: Bool)) -> Int? {
        
        guard result.affectsHistory == true else {
            return nil
        }
        
        guard history.count > 0 else {
            return nil
        }
        
        let historyForParameter = history.reduce([Parameter]()) { partialResult, historyStep in
            
            var updated = partialResult
            
            if let historyValue = historyStep.first(where: { $0.id == result.param.id }) {
                
                updated.append(historyValue)
            }
     
            return updated
        }
        
        guard historyForParameter.count > 0 else {
            return nil
        }
        
        let lastHistoryParameter = historyForParameter[historyForParameter.count - 1]
        
        guard lastHistoryParameter.value != result.param.value else {
            return nil
        }
        
        let historyForParameterDepth = historyForParameter.compactMap{ $0 }.count
        
        return history.count - historyForParameterDepth
    }
    
    func historyChangedStep(history: [[Parameter]], results: [(param: Parameter, affectsHistory: Bool)]) -> Int? {
        
        return results.compactMap{ historyChangedStep(history: history, result: $0)}.min()
    }
    
    func finalized() -> Payments.Operation {
        
        var updatedParameters = parameters
        updatedParameters.append(Payments.ParameterFinal())
        
        return Payments.Operation(service: service, parameters: updatedParameters, processed: processed)
    }
    
    static let emptyMock = Payments.Operation(service: .fms, parameters: [], processed: [])
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
        
        case failedLoadServicesForCategory(Payments.Category)
        case unableSelectServiceForCategory(Payments.Category)
        case operatorNotSelectedForService(Payments.Service)
    }
}
