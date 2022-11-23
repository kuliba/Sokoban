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
    var parametersIds: [Payments.Parameter.ID] { parameters.map({ $0.id })}
    var visibleParameters: [PaymentsParameterRepresentable] {
        
        var result = [PaymentsParameterRepresentable]()
        
        // sort order from visible
        for parameterId in visible {
            
            guard let parameter = parameters.first(where: { $0.id == parameterId }) else {
                continue
            }
            
            result.append(parameter)
        }
        
        return result
    }
    
    var transferType: Payments.Operation.TransferType {

        return service.transferType
    }

    /// Appends new step to operation
    /// - Parameter step: step to append
    /// - Returns: updated operation
    func appending(step: Step) throws -> Payments.Operation {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Operation: \(shortDescription) appending step: \n\(step)")
        
        let existingParametersIds = Set(parameters.map({ $0.id }))
        let appendingParametersIds = Set(step.parameters.map({ $0.id }))
        
        // check for duplicate parameters
        guard existingParametersIds.intersection(appendingParametersIds).count == 0 else {
            throw Payments.Operation.Error.appendingStepDuplicateParameters
        }
        
        let allParametersIds = existingParametersIds.union(appendingParametersIds)
        let requiredParametersIds = Set(step.back.required)
        
        // check if terms contains in parameters
        guard requiredParametersIds.isSubset(of: allParametersIds) else {
            throw Payments.Operation.Error.appendingStepIncorrectParametersTerms
        }
        
        var stepsUpdated = steps
        stepsUpdated.append(step)
        
        // update visible parameters
        var visibleUpdated = [Parameter.ID]()
        for parameterId in visible {
            
            // check if parameter id contains in step visible
            // if so this parameter just change it's order
            // becasuse all step's visible parameters we will add after
            guard step.front.visible.contains(parameterId) == false else {
                continue
            }
            
            visibleUpdated.append(parameterId)
        }
        
        visibleUpdated.append(contentsOf: step.front.visible)
        
        let updatedOperation = Payments.Operation(service: service, source: source, steps: stepsUpdated, visible: visibleUpdated)
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Operation: \(updatedOperation.shortDescription) step appended")

        return updatedOperation
    }
    
    /// Resets visible parameters for operation. Only parameters represented in operation can be visible. If list is nil - operation returns unchanged. If visible list after filtration with operaton parameters contains no elemnts, operation returns unchanged.
    /// - Parameter visible: List of visible parameters ids. Order in this list also defines order in the view.
    /// - Returns: Updated operation.
    func reseted(visible: [Parameter.ID]) -> Payments.Operation {
        
        let visibleFilterred = visible.filter({ parametersIds.contains($0) })
        
        guard visibleFilterred.isEmpty == false else {
            return self
        }
        
        return .init(service: service, source: source, steps: steps, visible: visibleFilterred)
    }
    
    /// Updates operation parameters
    /// - Parameter update: parameters used to update
    /// - Returns: updated operation
    func updated(with update: [Parameter]) -> Payments.Operation {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Operation: \(shortDescription) updating with parameters: \n\(update)")
        
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
        
        let updatedOperation = Payments.Operation(service: service, source: source, steps: updatedSteps, visible: visible)
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Operation: \(updatedOperation.shortDescription) updated")
       
        return updatedOperation
    }
    
    /// Rolls back operation to some step
    /// - Parameter step: step to roll back on
    /// - Returns: updated operation
    func rollback(to stepIndex: Int) throws -> Payments.Operation {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Operation: \(shortDescription) rolling back to step: \(stepIndex)")
        
        guard stepIndex >= 0, stepIndex < steps.count else {
            throw Payments.Operation.Error.rollbackStepIndexOutOfRange
        }
        
        var stepsUpdated = [Step]()
        for (index, step) in steps.enumerated() {
            
            if index < stepIndex {
                
                switch step.back.stage {
                case .local:
                    stepsUpdated.append(step)
                    
                case .remote:
                    stepsUpdated.append(step.reseted())
                }
                
            } else if index == stepIndex {
                
                stepsUpdated.append(step.reseted())
                
            } else {
                
                break
            }
        }
        
        let updatedOperation = Payments.Operation(service: service, source: source, steps: stepsUpdated, visible: visible)
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Operation: ROLLED BACK \(updatedOperation)")

        return updatedOperation
    }
    
    /// Update operation step data with parameters sent to the server
    /// - Parameters:
    ///   - parameters: processed parameters
    ///   - stepIndex: step index
    /// - Returns: updated operation
    func processed(parameters: [Parameter], stepIndex: Int) throws -> Payments.Operation {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Operation: \(shortDescription) updating processed parameters: \(parameters) for step: \(stepIndex)")
        
        guard stepIndex >= 0, stepIndex < steps.count else {
            throw Payments.Operation.Error.processStepIndexOutOfRange
        }
        
        let step = steps[stepIndex]
        let updatedStep = try step.processed(parameters: parameters)
        
        var updatedSteps = steps
        updatedSteps.replaceSubrange(stepIndex...stepIndex, with: [updatedStep])
        
        let updatedOperation = Payments.Operation(service: service, source: source, steps: updatedSteps, visible: visible)
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Operation: UPDATED \(updatedOperation)")
        
        return updatedOperation
    }
    
    /// Updates depended parameters. For example parameter `amount` or `currency` depends on parameter `product` value
    /// - Parameter reducer: optional returns updated parameter if it depends on other
    /// - Returns: updated operation
    func updatedDepended(reducer: (Payments.Service, Parameter.ID, [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable?) -> Payments.Operation {
        
        var updatedSteps = [Payments.Operation.Step]()
        
        for step in steps {
            
            var updatedParameters = [PaymentsParameterRepresentable]()
            for parameter in step.parameters {
                
                if let updatedParameter = reducer(service, parameter.id, parameters) {
                    
                    updatedParameters.append(updatedParameter)
                    
                } else {
                    
                    updatedParameters.append(parameter)
                }
            }
            
            let updatedStep = Payments.Operation.Step(parameters: updatedParameters, front: step.front, back: step.back)
            updatedSteps.append(updatedStep)
        }
        
        return .init(service: service, source: source, steps: updatedSteps, visible: visible)
    }
    
    /// Generates next action for payment process
    /// - Returns: payments action
    func nextAction() throws -> Action {
        
        for (index, step) in steps.enumerated() {
            
            switch try step.status(with: parameters) {
            case .editing:
                return step.back.stage == .remote(.confirm) ? .frontConfirm : .frontUpdate
                
            case .invalidated:
                return .rollback(stepIndex: index)
                
            case let .pending(parameters: parameters, stage: stage):
                return .backProcess(parameters: parameters, stepIndex: index, stage: stage)
                
            default:
                continue
            }
        }
        
        return .step(index: nextStep)
    }
}

//MARK: - Helpers

extension Payments.Operation {
    
    var amount: Double? {
        
        guard let amountParameter = parameters.first(where: { $0.id == Payments.Parameter.Identifier.amount.rawValue }) as? Payments.ParameterAmount else {
            return nil
        }
        
        return amountParameter.amount
    }
    
    var productId: ProductData.ID? {
        
        guard let productParameter = parameters.first(where: { $0.id == Payments.Parameter.Identifier.product.rawValue }) as? Payments.ParameterProduct else {
            return nil
        }
        
        return productParameter.productId
    }
}

//MARK: - Error

extension Payments.Operation {
    
    enum Error: LocalizedError {
        
        case appendingStepDuplicateParameters
        case appendingStepIncorrectParametersTerms
        case rollbackStepIndexOutOfRange
        case processStepIndexOutOfRange
        case stepMissingParameterForTerm
        case stepIncorrectParametersProcessed
        case failedLoadServicesForCategory(Payments.Category)
        case unableSelectServiceForCategory(Payments.Category)
        case operatorNotSelectedForService(Payments.Service)
        
        var errorDescription: String? {
            
            switch self {
            case .appendingStepDuplicateParameters:
                return "Operation appending step: duplicate parameters "
                
            case .appendingStepIncorrectParametersTerms:
                return "Operation appending step: incorrect parameters terms"
                
            case .rollbackStepIndexOutOfRange:
                return "Operation rollback: step index out of range"
                
            case .processStepIndexOutOfRange:
                return "Operation processing: step index out of range"
                
            case .stepMissingParameterForTerm:
                return "Step updating: missing parameter for term"
                
            case .stepIncorrectParametersProcessed:
                return "Step updating: processed incorrect parameter"
                
            case .failedLoadServicesForCategory(let category):
                return "Failed loading service for category: \(category)"
                
            case .unableSelectServiceForCategory(let category):
                return "Unable select service for category: \(category)"
                
            case .operatorNotSelectedForService(let service):
                return "Not selected operator for service: \(service)"
            }
        }
    }
}

//MARK: - Debug Description

extension Payments.Operation: CustomDebugStringConvertible {
    
    var shortDescription: String { "\(service)[steps: \(steps.count)]" }
    
    var debugDescription: String {
        
        var result = "\n=========== OPERATION ===========\n"
        result += "\nservice: \(service)\n"
        let stepsDescriptions = steps.map{ $0.debugDescription }
        for (index, stepDescription) in stepsDescriptions.enumerated() {
            
            result += "step \(index):\n\t"
            result += stepDescription
            result += "\n"
        }
        result += "=================================\n"
        
        return result
    }
}

//MARK: - Mock

extension Payments.Operation {
    
    static let emptyMock = Payments.Operation(service: .fms, source: nil, steps: [], visible: [])
}
