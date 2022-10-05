//
//  PaymentsDataModel+Step.swift
//  ForaBank
//
//  Created by Max Gribov on 05.10.2022.
//

import Foundation

extension Payments.Operation.Step {
    
    typealias Parameter = Payments.Parameter
    
    var parametersIds: [Parameter.ID] { parameters.map({ $0.id })}
    
    func status(with parameters: [PaymentsParameterRepresentable]) -> Status {
        
        guard front.isCompleted == false else {
            return .updating
        }
        
        if let processedResults = processedResults(with: parameters) {

            var impacts = [Impact]()
            
            for statedata in processedResults {
                
                if statedata.processed != statedata.current {
                    
                    impacts.append(statedata.impact)
                }
            }
            
            let sortedImpacts = impacts.sorted(by: { $0.rawValue < $1.rawValue })
            
            guard let firstImpact = sortedImpacts.first else {
                return .complete
            }
            
            return .invalidated(firstImpact)
            
        } else {
            
            if let back = back {
                
                let termsParametersIds = back.terms.map{ $0.parameterId }
                let pendingParameters = parameters.filter({ termsParametersIds.contains($0.id) }).map{ $0.parameter }
                
                return .pending(parameters: pendingParameters, stage: back.stage)
                
            } else {
                
                return .complete
            }
        }
    }

    func termsParameters(with parameters: [PaymentsParameterRepresentable]) -> [Parameter]? {
        
        guard let terms = back?.terms else {
            return nil
        }
        
        let termsParametersIds = terms.map{ $0.parameterId }
        return parameters.filter({ termsParametersIds.contains($0.id) }).map{ $0.parameter }
    }
    
    func processedResults(with parameters: [PaymentsParameterRepresentable]) -> [ProcessedData]? {
        
        guard let back = back, let processed = back.processed else {
            return nil
        }
        
        let termsSorted = back.terms.sorted(by: { $0.parameterId < $1.parameterId })
        
        let termsParametersIds = termsSorted.map{ $0.parameterId }
        let currentParameters = parameters.filter({ termsParametersIds.contains($0.id) }).map{ $0.parameter }
        
        let processedParametersSorted = processed.sorted(by: { $0.id < $1.id })
        let impacts = termsSorted.map{ $0.impact }
        
        var result = [ProcessedData]()
        
        for (processed, (current, impact)) in zip(processedParametersSorted, zip(currentParameters, impacts)) {
            
            result.append(.init(current: current, processed: processed, impact: impact))
        }
        
        return result
    }
    
    func reseted() -> Payments.Operation.Step {
        
        if let back = back {
            
            return .init(parameters: parameters, front: front, back: .init(stage: back.stage, terms: back.terms, processed: nil) )
            
        } else {
            
            return self
        }
    }

    func processed(parameters: [Parameter]) throws -> Payments.Operation.Step {
        
        guard let back = back else {
            throw Payments.Operation.Error.stepMissingTermsForProcessedParameters
        }
 
        let requiredParametersIds = Set(back.terms.map({ $0.parameterId }))
        let processedParametersIds = Set(parameters.map({ $0.id }))
        
        //caheck if correct parameters procrssed
        guard processedParametersIds == requiredParametersIds else {
            throw Payments.Operation.Error.stepIncorrectParametersProcessed
        }
        
        return .init(parameters: self.parameters, front: front, back: .init(stage: back.stage, terms: back.terms, processed: parameters))
    }
    
    func updated(parameter: Parameter) -> Payments.Operation.Step {
        
        var updatedParameters = parameters
        for param in parameters {
            
            if param.id == parameter.id {
                
                let updatedParam = param.updated(value: parameter.value)
                updatedParameters.append(updatedParam)
                
            } else {
                
                updatedParameters.append(param)
            }
        }
        
        return .init(parameters: updatedParameters, front: front, back: back)
    }
    
    func contains(parameterId: Parameter.ID) -> Bool {
        
        parametersIds.contains(parameterId)
    }
}
