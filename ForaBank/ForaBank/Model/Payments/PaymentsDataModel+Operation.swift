//
//  PaymentsDataModel+Operation.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

extension Payments.Operation {
    
    typealias Parameter = Payments.Parameter
    
    var parameters: [PaymentsParameterRepresentable] { steps.flatMap{ $0.parameters } }
    var nextStep: Int { steps.isEmpty ? 0 : steps.count + 1 }

    /// Appends new parameters to operation.
    /// - Parameters:
    ///   - parameters: parameters to append
    ///   - requred: parameters ids requred on next step opf transaction
    /// - Returns: Updated operation
    func appending(parameters: [PaymentsParameterRepresentable], terms: [Payments.Operation.Step.Term]) throws -> Payments.Operation {
        
        let appendingParametersIds = Set(parameters.map({ $0.id }))
        let requiredParametersIds = Set(terms.map({ $0.parameterId }))
        
        // check if terms contains in parameters
        guard appendingParametersIds.isSuperset(of: requiredParametersIds) else {
            throw Payments.Error.operationAppendingIncorrectParametersTerms
        }
        
        var stepsUpdated = steps
        stepsUpdated.append(.init(parameters: parameters, terms: terms, processed: []))

        return .init(service: service, source: source, steps: stepsUpdated)
    }

    /// Update operation parameters with new values, history doesn't change
    /// - Parameter updatedParameters: updated parameters
    /// - Returns: updated operation
    func updated(updatedParameters: [Parameter]) -> Payments.Operation {
        
        var stepsUpdated = [Payments.Operation.Step]()
        
        for step in steps {
            
            var parametersUpdated = [PaymentsParameterRepresentable]()
            for parameter in self.parameters {
                
                if let update = updatedParameters.first(where: { $0.id == parameter.id }) {
                    
                    let parameterUpdated = parameter.updated(value: update.value)
                    parametersUpdated.append(parameterUpdated)
                    
                } else {
                    
                    parametersUpdated.append(parameter)
                }
            }
            
            stepsUpdated.append(.init(parameters: parametersUpdated, terms: step.terms, processed: step.processed))
        }
        
        return .init(service: service, source: source, steps: stepsUpdated)
    }
    
    /// Rolls back operation to some step
    /// - Parameter step: step to roll back on
    /// - Returns: updated operation
    func rollback(to stepIndex: Int) -> Payments.Operation {
        
        assert(stepIndex >= 0)
        return .init(service: service, source: source, steps: Array(steps.prefix(stepIndex)))
    }
    
    /// Updates operation history with processed parameters
    /// - Parameters:
    ///   - parametersIds: parametrs ids processed
    ///   - isBegining: is it the beggining of transaction or some step?
    /// - Returns: updated operation
    func processed(parameters: [Parameter], stepIndex: Int) throws -> Payments.Operation {
        
        assert(stepIndex >= 0 && stepIndex < steps.count)
        
        let step = steps[stepIndex]
        let updatedStep = try step.processed(parameters: parameters)
        
        var updatedSteps = steps
        updatedSteps.replaceSubrange(stepIndex...stepIndex, with: [updatedStep])
        
        return .init(service: service, source: source, steps: steps)
    }
    
    func parametersRequired(for stepIndex: Int) -> [Parameter]? {
        
        guard stepIndex >= 0, stepIndex < steps.count else {
            return nil
        }
        
        let requiredParametersIds = steps[stepIndex].terms.map{ $0.parameterId }
        
        return parameters.filter({ requiredParametersIds.contains($0.id) }).map({ $0.parameter })
    }
    
    func stepIndex(for parameterId: Parameter.ID) -> Int? {
        
        for (index, step) in steps.enumerated() {
            
            if step.contains(parameterId: parameterId) {
                
                return index
            }
        }
        
        return nil
    }

    func nextAction() -> Action {
        
        var isBegin = true
        
        for (index, step) in steps.enumerated() {
            
            switch step.state {
            case let .impact(impact):
                switch impact {
                case .rollback: return .rollback(stepIndex: index)
                case .restart: return .restart
                case .confirm: return .confirm(parameters: step.termsParameters)
                }
                
            case let .pending(pendingParameters):
                return .process(parameters: pendingParameters, isBegin: isBegin)
                
            case .complete:
                isBegin = false
            }
        }
        
        return .parameters(stepIndex: nextStep)
    }
}

extension Payments.Operation.Step {
    
    typealias Parameter = Payments.Parameter
    
    var state: State {
        
        guard let stateDataList = stateDataList else {
            return .pending(termsParameters)
        }
        
        var impacts = [Impact]()
        
        for statedata in stateDataList {
            
            if statedata.processed != statedata.current {
                
                impacts.append(statedata.impact)
            }
        }
        
        let sortedImpacts = impacts.sorted(by: { $0.rawValue < $1.rawValue })
        
        guard let firstImpact = sortedImpacts.first else {
            return .complete
        }
        
        return .impact(firstImpact)
    }

    var termsParameters: [Parameter] {
        
        let termsParametersIds = terms.map{ $0.parameterId }
        return parameters.filter({ termsParametersIds.contains($0.id) }).map{ $0.parameter }
    }
    
    var stateDataList: [StateData]? {
        
        guard let processed = processed else {
            return nil
        }
        
        let termsSorted = terms.sorted(by: { $0.parameterId < $1.parameterId })
        
        let termsParametersIds = termsSorted.map{ $0.parameterId }
        let currentParameters = parameters.filter({ termsParametersIds.contains($0.id) }).map{ $0.parameter }
        
        let processedParametersSorted = processed.sorted(by: { $0.id < $1.id })
        let impacts = termsSorted.map{ $0.impact }
        
        var result = [StateData]()
        
        for (processed, (current, impact)) in zip(processedParametersSorted, zip(currentParameters, impacts)) {
            
            result.append(.init(current: current, processed: processed, impact: impact))
        }
        
        return result
    }
    
    func contains(parameterId: Parameter.ID) -> Bool {
        
        parameters.map{ $0.id }.contains(parameterId)
    }
    
    func processed(parameters: [Parameter]) throws -> Payments.Operation.Step {
 
        let requiredParametersIds = Set(terms.map({ $0.parameterId }))
        let processedParametersIds = Set(parameters.map({ $0.id }))
        
        //caheck if correct parameters procrssed
        guard processedParametersIds == requiredParametersIds else {
            throw Payments.Error.stepIncorrectParametersProcessed
        }
        
        return .init(parameters: self.parameters, terms: terms, processed: parameters)
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
        
        case failedLoadServicesForCategory(Payments.Category)
        case unableSelectServiceForCategory(Payments.Category)
        case operatorNotSelectedForService(Payments.Service)
    }
}
