//
//  Payments+Operation.swift
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
    
    var transferType: Payments.Operation.TransferType {

        return service.transferType
    }

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
        
        let allParametersIds = existingParametersIds.union(appendingParametersIds)
        let requiredParametersIds = Set(step.back.terms.map({ $0.parameterId }))
        
        // check if terms contains in parameters
        guard requiredParametersIds.isSubset(of: allParametersIds) else {
            throw Payments.Operation.Error.appendingStepIncorrectParametersTerms
        }
        
        var stepsUpdated = steps
        stepsUpdated.append(step)

        return .init(service: service, source: source, steps: stepsUpdated)
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
    
    /// Restarts the operation
    /// - Returns: restarted operation
    func restarted() -> Payments.Operation {
        
        .init(service: service, source: source, steps: steps.map({ $0.reseted() }))
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
    
    /// Updates depended parameters. For example parameter `amount` or `currency` depends on parameter `product` value
    /// - Parameter reducer: optional returns updated parameter if it depends on other
    /// - Returns: updated operation
    func updatedDepended(reducer: (Parameter.ID, [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable?) -> Payments.Operation {
        
        var updatedSteps = [Payments.Operation.Step]()
        
        for step in steps {
            
            var updatedParameters = [PaymentsParameterRepresentable]()
            for parameter in step.parameters {
                
                if let updatedParameter = reducer(parameter.id, parameters) {
                    
                    updatedParameters.append(updatedParameter)
                    
                } else {
                    
                    updatedParameters.append(parameter)
                }
            }
            
            let updatedStep = Payments.Operation.Step(parameters: updatedParameters, front: step.front, back: step.back)
            updatedSteps.append(updatedStep)
        }
        
        return .init(service: service, source: source, steps: updatedSteps)
    }
    
    /// Generates next action for payment process
    /// - Returns: payments action
    func nextAction() -> Action {
        
        for (index, step) in steps.enumerated() {
            
            switch step.status(with: parameters) {
            case .editing:
                return step.back.stage == .remote(.confirm) ? .frontConfirm : .frontUpdate
                
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
    
    var isAutoContinueRequired: Bool {
        
        let nextAction = nextAction()
        switch nextAction {
        case .rollback:
            return true
            
        default:
            return false
        }
    }
}

//MARK: - Error

extension Payments.Operation {
    
    enum Error: Swift.Error {
        
        case appendingStepDuplicateParameters
        case appendingStepDuplicateVisibleParameters
        case appendingStepIncorrectParametersTerms
        case rollbackStepIndexOutOfRange
        case processStepIndexOutOfRange
        case stepMissingParameterForTerm
        case stepIncorrectParametersProcessed
        case failedLoadServicesForCategory(Payments.Category)
        case unableSelectServiceForCategory(Payments.Category)
        case operatorNotSelectedForService(Payments.Service)
    }
}

//MARK: - Mock

extension Payments.Operation {
    
    static let emptyMock = Payments.Operation(service: .fms, source: nil, steps: [])
}
