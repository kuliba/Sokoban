//
//  Payments+Step.swift
//  ForaBank
//
//  Created by Max Gribov on 05.10.2022.
//

import Foundation

extension Payments.Operation.Step {
    
    typealias Parameter = Payments.Parameter
    
    /// Step's parameters identifiers
    var parametersIds: [Parameter.ID] { parameters.map({ $0.id }) }
    
    /// Current step status based on list of parameters from operation
    /// - Parameter parameters: list of parameters
    /// - Returns: step status
    func status(with parameters: [PaymentsParameterRepresentable]) throws -> Status {
        
        guard front.isCompleted == true else {
            return .editing
        }
        
        if let processedResults = try processedResults(with: parameters) {
            
            for result in processedResults {
                
                if result.current != result.processed {
                    
                    return .invalidated
                }
            }

            return .complete
            
        } else {
            
            return .pending(parameters: pendingParameters(with: parameters), stage: back.stage)
        }
    }
    
    /// Results for parameters processed on server. Result contains parameter value sent on server, current parameter value and impact caused if current parameter value changed
    /// - Parameter parameters: list of parameters from operation
    /// - Returns: optional list of results
    func processedResults(with parameters: [PaymentsParameterRepresentable]) throws -> [ProcessedData]? {
        
        guard let processed = back.processed else {
            return nil
        }
        
        var result = [ProcessedData]()
        
        for parameterId in back.required {
            
            guard let currentParameter = parameters.first(where: { $0.id == parameterId })?.parameter else {
                throw Payments.Error.missingParameter(parameterId)
            }
            
            guard let processedParameter = processed.first(where: { $0.id == parameterId }) else {
                throw Payments.Error.missingParameter(parameterId)
            }

            result.append(.init(current: currentParameter, processed: processedParameter))
        }
        
        return result
    }
    
    /// Removes data about parameters processed on server
    /// - Returns: resetted step
    func reseted() -> Payments.Operation.Step {
        
        return .init(parameters: parameters, front: front, back: .init(stage: back.stage, required: back.required, processed: nil) )
    }
    
    /// Creates list of parameters that should be processed on server side
    /// - Parameter parameters: list of parameters from operation
    /// - Returns: parameters list
    func pendingParameters(with parameters: [PaymentsParameterRepresentable]) -> [Parameter] {

        parameters.filter({ back.required.contains($0.id) }).map{ $0.parameter }
    }
    
    /// Updates step with parameters processed on server
    /// - Parameter parameters: list of processed parameters
    /// - Returns: updated step
    func processed(parameters: [Parameter]) throws -> Payments.Operation.Step {
        
        let requiredParametersIds = Set(back.required)
        let processedParametersIds = Set(parameters.map({ $0.id }))
        
        //caheck if correct parameters procrssed
        guard processedParametersIds == requiredParametersIds else {
            throw Payments.Operation.Error.stepIncorrectParametersProcessed
        }
        
        return .init(parameters: self.parameters, front: front, back: .init(stage: back.stage, required: back.required, processed: parameters))
    }
    
    /// Updates state with parameter. If all parameters have value step becomes complete for front part.
    /// - Parameter parameter: updated parameter
    /// - Returns: updated set
    func updated(parameter: Parameter) -> Payments.Operation.Step {
        
        var updatedParameters = [PaymentsParameterRepresentable]()
        for param in parameters {
            
            if param.id == parameter.id {
                
                let updatedParam = param.updated(value: parameter.value)
                updatedParameters.append(updatedParam)
                
            } else {
                
                updatedParameters.append(param)
            }
        }
        
        let completeParamsCount = updatedParameters.compactMap({ $0.value }).count
        let isComplete = updatedParameters.count == completeParamsCount
        
        return .init(parameters: updatedParameters, front: .init(visible: front.visible, isCompleted: isComplete), back: back)
    }
    
    /// Updates step parameters values with source (template, qr-code, etc.) If there is no source, step remains unchanged.
    /// - Parameters:
    ///   - service: operation service
    ///   - source: optional operation source
    ///   - reducer: reducer that might return value from source for parameter
    /// - Returns: updated step
    func updated(service: Payments.Service, source: Payments.Operation.Source?, reducer: (Payments.Service, Payments.Operation.Source, Parameter.ID) -> Parameter.Value?) -> Payments.Operation.Step {
        
        guard let source = source else {
            return self
        }
        
        var updatedParameters = [PaymentsParameterRepresentable]()
        
        for parameter in parameters {
            
            if parameter.value == nil, let newValue = reducer(service, source, parameter.id) {
                
                let updatedParameter = parameter.updated(value: newValue)
                updatedParameters.append(updatedParameter)
                
            } else {
                
                updatedParameters.append(parameter)
            }
        }
        
        return .init(parameters: updatedParameters, front: front, back: back)
    }
    
    /// Updates back stage for step
    /// - Parameter stage: back stage value
    /// - Returns: updated step
    func updated(stage: Payments.Operation.Stage) -> Payments.Operation.Step {
        
        .init(parameters: parameters, front: front, back: .init(stage: stage, required: back.required, processed: back.processed))
    }
    
    /// Checks if step contains parameter with id
    /// - Parameter parameterId: parameter id to check
    /// - Returns: true if contains
    func contains(parameterId: Parameter.ID) -> Bool {
        
        parametersIds.contains(parameterId)
    }
}

//MARK: - Debug Description

extension Payments.Operation.Step: CustomDebugStringConvertible {
    
    var debugDescription: String {

        var result = ""
        
        let paramsDescriptions = parameters.map{ $0.parameter.debugDescription }
        result += "parameters: "
        for paramDescription in paramsDescriptions {
            
            result += paramDescription
            result += " "
        }
        result += "\n\tfront:"
        result += "\n\t\tvisible: "
        for item in front.visible {
            
            result += "\(item) "
        }
        
        result += "\n\t\tcomplete: \(front.isCompleted)"
        
        result += "\n\tback:"
        result += "\n\t\tstage: \(back.stage)"
        
        result += "\n\t\trequired: "
        
        for parameterId in back.required {
            
            result += "\(parameterId) "
        }
        
        if let processed = back.processed {
            
            let processedParamsDescriptions = processed.map{ $0.debugDescription }
            result += "\n\t\tprocessed: "
            
            for paramDescription in processedParamsDescriptions {
                
                result += paramDescription
                result += " "
            }

        } else {
            
            result += "\n\t\tprocessed: no"
        }

        return result
    }
}
