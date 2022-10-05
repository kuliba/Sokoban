//
//  PaymentsDataModel+Operation.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

extension Payments.Operation {
    
    typealias Parameter = Payments.Parameter
    
    var nextStep: Int { steps.count }
    
    var parameters: [PaymentsParameterRepresentable] { steps.flatMap({ $0.parameters })}

    /// Appends new parameters to operation.
    /// - Parameters:
    ///   - parameters: parameters to append
    ///   - requred: parameters ids requred on next step opf transaction
    /// - Returns: Updated operation
    func appending(step: Step) throws -> Payments.Operation {
        
        let existingParametersIds = Set(parameters.map({ $0.id }))
        let appendingParametersIds = Set(step.parameters.map({ $0.id }))
        
        guard existingParametersIds.intersection(appendingParametersIds).count == 0 else {
            throw Payments.Operation.Error.appendingDuplicateParameters
        }
        
        if let terms = step.back?.terms {
            
            let allParametersIds = existingParametersIds.union(appendingParametersIds)
            let requiredParametersIds = Set(terms.map({ $0.parameterId }))
            
            // check if terms contains in parameters
            guard requiredParametersIds.isSubset(of: allParametersIds) else {
                throw Payments.Operation.Error.appendingIncorrectParametersTerms
            }
            
            var stepsUpdated = steps
            stepsUpdated.append(step)

            return .init(service: service, source: source, steps: stepsUpdated)
            
        } else {

            var stepsUpdated = steps
            stepsUpdated.append(step)

            return .init(service: service, source: source, steps: stepsUpdated)
        }
    }

    /// Update operation parameters with new values, history doesn't change
    /// - Parameter updatedParameters: updated parameters
    /// - Returns: updated operation
    func updated(with update: [Parameter]) -> Payments.Operation {
        
        var updatedSteps = steps
        for step in steps {
            
            var updatedStep = step
            for param in update {
                
                if step.contains(parameterId: param.id) {
                    
                    updatedStep = updatedStep.updated(parameter: param)
                }
            }
            
            updatedSteps.append(updatedStep)
        }
       
        return .init(service: service, source: source, steps: updatedSteps)
    }
    
    /// Rolls back operation to some step
    /// - Parameter step: step to roll back on
    /// - Returns: updated operation
    func rollback(to stepIndex: Int) throws -> Payments.Operation {
        
        guard stepIndex >= 0, stepIndex < steps.count else {
            throw Payments.Operation.Error.rollbackStepIndexOutOfRange
        }
        
        var stepsUpdated = [Step]()
        for (index, step) in steps.enumerated() {
            
            guard index <= stepIndex else {
                break
            }
            
            stepsUpdated.append(step.reseted())
        }

        return .init(service: service, source: source, steps: stepsUpdated)
    }
    
    /// Updates operation history with processed parameters
    /// - Parameters:
    ///   - parametersIds: parametrs ids processed
    ///   - isBegining: is it the beggining of transaction or some step?
    /// - Returns: updated operation
    func processed(parameters: [Parameter], stepIndex: Int) throws -> Payments.Operation {
        
        guard stepIndex >= 0, stepIndex < steps.count else {
            throw Payments.Operation.Error.processStepIndexOutOfRange
        }
        
        let step = steps[stepIndex]
        let updatedStep = try step.processed(parameters: parameters)
        
        var updatedSteps = steps
        updatedSteps.replaceSubrange(stepIndex...stepIndex, with: [updatedStep])
        
        return .init(service: service, source: source, steps: updatedSteps)
    }
        
    func nextAction() -> Action {
        
        for (index, step) in steps.enumerated() {
            
            switch step.status(with: parameters) {
            case .updating:
                return .frontUpdate
                
            case let .invalidated(impact):
                switch impact {
                case .rollback: return .rollback(stepIndex: index)
                case .restart: return .restart
                }
                
            case let .pending(parameters: parameters, stage: stage):
                return .backProcess(parameters: parameters, stepIndex: index, stage: stage)
                
            case .complete:
                break
            }
        }
        
        return .backParameters(stepIndex: nextStep)
    }
}



extension Payments.Operation {
    
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
        
        //FIXME: - refactor
        return .emptyMock
        /*
        var updatedParameters = parameters
        updatedParameters.append(Payments.ParameterFinal())
        
        return Payments.Operation(service: service, parameters: updatedParameters, processed: processed)
         */
    }
    
    static let emptyMock = Payments.Operation(service: .fms, source: .none, steps: [])
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
        
        case appendingDuplicateParameters
        case appendingIncorrectParametersTerms
        case rollbackStepIndexOutOfRange
        case processStepIndexOutOfRange
        case stepMissingTermsForProcessedParameters
        case stepIncorrectParametersProcessed
        case failedLoadServicesForCategory(Payments.Category)
        case unableSelectServiceForCategory(Payments.Category)
        case operatorNotSelectedForService(Payments.Service)
    }
}
