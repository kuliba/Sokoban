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
    func status(with parameters: [PaymentsParameterRepresentable]) -> Status {
        
        guard front.isCompleted == true else {
            return .editing
        }
        
        if let processedResults = processedResults(with: parameters) {

            let impacts = impacts(for: processedResults)

            guard let firstImpact = impacts.first else {
                return .complete
            }
            
            return .invalidated(firstImpact)
            
        } else {
            
            return .pending(parameters: pendingParameters(with: parameters), stage: back.stage)
        }
    }
    
    /// Results for parameters processed on server. Result contains parameter value sent on server, current parameter value and impact caused if current parameter value changed
    /// - Parameter parameters: list of parameters from operation
    /// - Returns: optional list of results
    func processedResults(with parameters: [PaymentsParameterRepresentable]) -> [ProcessedData]? {
        
        guard let processed = back.processed else {
            return nil
        }
        
        let termsSorted = back.terms.sorted(by: { $0.parameterId < $1.parameterId })
        
        let termsParametersIds = termsSorted.map{ $0.parameterId }
        let currentParameters = parameters.filter({ termsParametersIds.contains($0.id) }).map{ $0.parameter }
        
        // check if we have parameters for terms
        guard currentParameters.count > 0 else {
            return nil
        }
        
        let processedParametersSorted = processed.sorted(by: { $0.id < $1.id })
        let impacts = termsSorted.map{ $0.impact }
        
        var result = [ProcessedData]()
        
        for (processed, (current, impact)) in zip(processedParametersSorted, zip(currentParameters, impacts)) {
            
            result.append(.init(current: current, processed: processed, impact: impact))
        }
        
        return result
    }
    
    func impacts(for processedResults: [ProcessedData]) -> [Impact] {
        
        var impacts = [Impact]()
        
        for statedata in processedResults {
            
            if statedata.processed != statedata.current {
                
                impacts.append(statedata.impact)
            }
        }
        
        return impacts.sorted(by: { $0.rawValue < $1.rawValue })
    }
    
    /// Removes data about parameters processed on server
    /// - Returns: resetted step
    func reseted() -> Payments.Operation.Step {
        
        return .init(parameters: parameters, front: front, back: .init(stage: back.stage, terms: back.terms, processed: nil) )
    }
    
    /// Creates list of parameters that should be processed on server side
    /// - Parameter parameters: list of parameters from operation
    /// - Returns: parameters list
    func pendingParameters(with parameters: [PaymentsParameterRepresentable]) -> [Parameter] {

        let termsParametersIds = back.terms.map{ $0.parameterId }
        
        return parameters.filter({ termsParametersIds.contains($0.id) }).map{ $0.parameter }
    }
    
    /// Updates step with parameters processed on server
    /// - Parameter parameters: list of processed parameters
    /// - Returns: updated step
    func processed(parameters: [Parameter]) throws -> Payments.Operation.Step {
        
        let requiredParametersIds = Set(back.terms.map({ $0.parameterId }))
        let processedParametersIds = Set(parameters.map({ $0.id }))
        
        //caheck if correct parameters procrssed
        guard processedParametersIds == requiredParametersIds else {
            throw Payments.Operation.Error.stepIncorrectParametersProcessed
        }
        
        return .init(parameters: self.parameters, front: front, back: .init(stage: back.stage, terms: back.terms, processed: parameters))
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
            
            if let newValue = reducer(service, source, parameter.id) {
                
                let updatedParameter = parameter.updated(value: newValue)
                updatedParameters.append(updatedParameter)
                
            } else {
                
                updatedParameters.append(parameter)
            }
        }
        
        return .init(parameters: updatedParameters, front: front, back: back)
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
        
        result += "\n\t\tterms:"
        
        for term in back.terms {
            
            result += "\(term) "
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
