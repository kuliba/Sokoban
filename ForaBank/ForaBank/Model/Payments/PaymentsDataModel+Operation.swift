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
    
    var parameters: [PaymentsParameterRepresentable] { steps.flatMap({ $0.parameters }) }
    var visibleParametersIds: [Payments.Parameter.ID] { steps.flatMap({ $0.front.visible }) }
    var visibleParameters: [PaymentsParameterRepresentable] { parameters.filter({ visibleParametersIds.contains($0.id)} ) }

    
    /// Appends new step to operation
    /// - Parameter step: step to append
    /// - Returns: updated operation
    func appending(step: Step) throws -> Payments.Operation {
        
        let existingParametersIds = Set(parameters.map({ $0.id }))
        let appendingParametersIds = Set(step.parameters.map({ $0.id }))
        
        // check for duplicate parameters
        guard existingParametersIds.intersection(appendingParametersIds).count == 0 else {
            throw Payments.Operation.Error.appendingStepDuplicateParameters
        }
        
        let existingVisibleParametersIds = Set(visibleParametersIds)
        let appendingVisibleParametersIds = Set(step.front.visible)
        
        // check for duplicate visible parameters
        guard existingVisibleParametersIds.intersection(appendingVisibleParametersIds).count == 0 else {
            throw Payments.Operation.Error.appendingStepDuplicateVisibleParameters
        }

        if let terms = step.back?.terms {
            
            let allParametersIds = existingParametersIds.union(appendingParametersIds)
            let requiredParametersIds = Set(terms.map({ $0.parameterId }))
            
            // check if terms contains in parameters
            guard requiredParametersIds.isSubset(of: allParametersIds) else {
                throw Payments.Operation.Error.appendingStepIncorrectParametersTerms
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

    
    /// Updates operation parameters
    /// - Parameter update: parameters used to update
    /// - Returns: updated operation
    func updated(with update: [Parameter]) -> Payments.Operation {
        
        var updatedSteps = [Payments.Operation.Step]()
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
    
    func restarted() -> Payments.Operation {
        
        //TODO: implementation required
        return self
    }
    
    
    /// Update operation step data with parameters sent to the server
    /// - Parameters:
    ///   - parameters: processed parameters
    ///   - stepIndex: step index
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
    
    /// Generates next action for payment process
    /// - Returns: payments action
    func nextAction() -> Action {
        
        for (index, step) in steps.enumerated() {
            
            switch step.status(with: parameters) {
            case .editing:
                return step.back?.stage == .confirm ? .frontConfirm : .frontUpdate
                
            case let .invalidated(impact):
                switch impact {
                case .rollback: return .rollback(stepIndex: index)
                case .restart: return .restart
                }
                
            case let .pending(parameters: parameters, stage: stage):
                return .backProcess(parameters: parameters, stepIndex: index, stage: stage)
                
            default:
                break
            }
        }
        
        return .step(index: nextStep)
    }
}



//TODO: remove
extension Payments.Operation {
    
    func historyUpdated() -> [[Parameter]] {
        
        //FIXME: refactor
        return [[]]
    }
    
    func update(with results: [(param: Parameter, affectsHistory: Bool)]) -> Update {
        
        //FIXME: refactor
        return Update(operation: .emptyMock, type: .historyChanged)

    }
    
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
        
        case appendingStepDuplicateParameters
        case appendingStepDuplicateVisibleParameters
        case appendingStepIncorrectParametersTerms
        case rollbackStepIndexOutOfRange
        case processStepIndexOutOfRange
        case stepMissingParameterForTerm
        case stepMissingTermsForProcessedParameters
        case stepIncorrectParametersProcessed
        case failedLoadServicesForCategory(Payments.Category)
        case unableSelectServiceForCategory(Payments.Category)
        case operatorNotSelectedForService(Payments.Service)
    }
}
