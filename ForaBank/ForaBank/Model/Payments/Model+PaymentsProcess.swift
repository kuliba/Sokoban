//
//  Model+PaymentsProcess.swift
//  ForaBank
//
//  Created by Max Gribov on 26.10.2022.
//

import Foundation

extension Model {
    
    func paymentsProcess(operation: Payments.Operation) async throws -> Payments.ProcessResult {
        
        try await Self.paymentsProcess(
            operation: operation,
            localStep: paymentsProcessLocalStep(operation:stepIndex:),
            remoteStep: paymentsProcessRemoteStep(operation:response:),
            remoteStart: paymentsProcessRemoteStart(_:_:),
            remoteNext: paymentsProcessRemoteNext(_:_:),
            remoteConfirm: paymentsProcessRemoteConfirm(_:_:),
            remoteComplete: paymentsProcessRemoteComplete(_:_:),
            sourceReducer: paymentsProcessSourceReducer(service:source:parameterId:),
            dependenceReducer: paymentsProcessDependencyReducer(parameterId:parameters:))
    }
    
    static func paymentsProcess(operation: Payments.Operation,
                         localStep: (Payments.Operation, Int) async throws -> Payments.Operation.Step,
                         remoteStep: (Payments.Operation, TransferResponseData) async throws -> Payments.Operation.Step,
                         remoteStart: ([Payments.Parameter], Payments.Operation) async throws -> TransferResponseData,
                         remoteNext: ([Payments.Parameter], Payments.Operation) async throws -> TransferResponseData,
                         remoteConfirm: ([Payments.Parameter], Payments.Operation) async throws -> Payments.Success,
                         remoteComplete: ([Payments.Parameter], Payments.Operation) async throws -> Payments.Success,
                         sourceReducer: (Payments.Service, Payments.Operation.Source, Payments.Parameter.ID) -> Payments.Parameter.Value?,
                         dependenceReducer: (Payments.Parameter.ID, [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable?) async throws -> Payments.ProcessResult {
        
        /// operation with updated depended parameters
        var operation = operation.updatedDepended(reducer: dependenceReducer)
        
        repeat {
            
            let nextAction = try operation.nextAction()
            
            switch nextAction {
            case let .step(index: stepIndex):
                LoggerAgent.shared.log(category: .payments, message: "Process action: LOCAL STEP: \(stepIndex)")
                
                // try to create step for the index
                let step = try await localStep(operation, stepIndex)
                
                // update step parameters values with data in source
                let stepUpdatedWithSource = step.updated(service: operation.service, source: operation.source, reducer: sourceReducer)
                
                // try to append step to operation
                operation = try operation.appending(step: stepUpdatedWithSource)
                
            case .frontUpdate:
                LoggerAgent.shared.log(category: .payments, message: "Process action: FRONT UPDATE")
                return .step(operation)
                
            case let .backProcess(parameters: parameters, stepIndex: stepIndex, stage: stage):
                switch stage {
                case .local:
                    LoggerAgent.shared.log(category: .payments, message: "Process action: BACK : LOCAL step: \(stepIndex + 1)")
                    // try to create step for the index
                    let step = try await localStep(operation, stepIndex + 1)
                    
                    // update step parameters values with data in source
                    let stepUpdatedWithSource = step.updated(service: operation.service, source: operation.source, reducer: sourceReducer)
                    
                    // try to update operation with processed values
                    operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                    
                    // try to append step to operation
                    operation = try operation.appending(step: stepUpdatedWithSource)
                    
                case let .remote(remoteStage):
                    switch remoteStage {
                    case .start:
                        // check if it restart or regular flow
                        if stepIndex + 1 < operation.steps.count {
                            
                            LoggerAgent.shared.log(category: .payments, message: "Process action: BACK: REMOTE START (restart)")
                            
                            // process parameters on server
                            let _ = try await remoteStart(parameters, operation)
                            
                            // try to update operation with processed values
                            operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                            
                        } else {
                            
                            LoggerAgent.shared.log(category: .payments, message: "Process action: BACK: REMOTE START")
                            
                            // process parameters on server
                            let response = try await remoteStart(parameters, operation)
                            
                            // try to create next step
                            let nextStep = try await remoteStep(operation, response)
                            
                            // update step parameters values with data in source
                            let nextStepUpdatedWithSource = nextStep.updated(service: operation.service, source: operation.source, reducer: sourceReducer)
                            
                            // try to update operation with processed values
                            operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                            
                            // try to append next step to operation
                            operation = try operation.appending(step: nextStepUpdatedWithSource)
                        }
                        
                    case .next:
                        // check if it restart or regular flow
                        if stepIndex + 1 < operation.steps.count {
                            
                            LoggerAgent.shared.log(category: .payments, message: "Process action: BACK: REMOTE NEXT (restart)")
                            
                            // process parameters on server
                            let _ = try await remoteNext(parameters, operation)
                            
                            // try to update operation with processed values
                            operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                            
                        } else {
                            
                            LoggerAgent.shared.log(category: .payments, message: "Process action: BACK: REMOTE NEXT")
                            
                            // try to create next step
                            let response = try await remoteNext(parameters, operation)
                            
                            // try to create next step
                            let nextStep = try await remoteStep(operation, response)
                            
                            // update step parameters values with data in source
                            let nextStepUpdatedWithSource = nextStep.updated(service: operation.service, source: operation.source, reducer: sourceReducer)
                            
                            // try to update operation with processed values
                            operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                            
                            // try to append next step to operation
                            operation = try operation.appending(step: nextStepUpdatedWithSource)
                        }
                        
                    case .confirm:
                        LoggerAgent.shared.log(category: .payments, message: "Process action: BACK: REMOTE CONFIRM")
                        // try to confirm operation and receive success data
                        let success = try await remoteConfirm(parameters, operation)
                        return .complete(success)
                        
                    case .complete:
                        LoggerAgent.shared.log(category: .payments, message: "Process action: BACK: REMOTE COMPLETE")
                        // try to complete operation and receive success data
                        let success = try await remoteComplete(parameters, operation)
                        return .complete(success)
                    }
                }
                
            case .frontConfirm:
                LoggerAgent.shared.log(category: .payments, message: "Process action: FRONT: CONFIRM")
                return .confirm(operation)
                
            case let .rollback(stepIndex: stepIndex):
                LoggerAgent.shared.log(category: .payments, message: "Process action: ROLLBACK to step: \(stepIndex)")
                operation = try operation.rollback(to: stepIndex)
            }
            
        } while true
    }
}
