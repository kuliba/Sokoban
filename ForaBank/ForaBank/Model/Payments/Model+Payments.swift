//
//  ModelAction+Payments.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum Payment {
        
        typealias Category = Payments.Category
        typealias Service = Payments.Service
        typealias Operator = Payments.Operator
        typealias Parameter = Payments.Parameter
        typealias Operation = Payments.Operation
        
        // service(s) for payments category
        enum Services {
            
            struct Request: Action {
                
                let category: Category
            }
            
            enum Response: Action {
                
                case select(Payments.ParameterSelectService)
                case selected(Service)
                case failed(Error)
            }
        }
        
        // begin payment process
        enum Begin {
            
            struct Request: Action {
                
                let base: Base
                
                enum Base {
                    
                    case service(Service)
                    case source(Operation.Source)
                }
            }
            
            enum Response: Action {
                
                case success(Operation)
                case failure(String)
            }
        }
        
        // continue payment process
        enum Continue {
            
            struct Request: Action {
                
                let operation: Operation
            }
            
            struct Response: Action {
                
                let result: Result
                
                enum Result {
                    
                    case step(Operation)
                    case confirm(Operation)
                    case complete(Payments.Success)
                    case failure(String)
                }
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    typealias Category = Payments.Category
    typealias Service = Payments.Service
    typealias Operator = Payments.Operator
    typealias Parameter = Payments.Parameter
    typealias Operation = Payments.Operation
    
    func handlePaymentsServicesRequest(_ payload: ModelAction.Payment.Services.Request) {
        
        let category = payload.category
        
        switch category {
        case .taxes:
            let services = category.services
            if services.count > 1 {
                
                guard let anywayGroup = dictionaryAnywayOperatorGroup(for: category.rawValue) else {
                    
                    action.send(ModelAction.Payment.Services.Response.failed(Payments.Operation.Error.failedLoadServicesForCategory(category)))
                    return
                }
                
                let operatorsCodes = services.compactMap{ $0.operators.first?.rawValue }
                let anywayOperators = anywayGroup.operators.filter{ operatorsCodes.contains($0.code)}
                
                let selectServiceParameter = Payments.ParameterSelectService(category: payload.category, options: payload.category.services.compactMap { paymentsParameterRepresentableSelectServiceOption(for: $0, with: anywayOperators)})
                
                action.send(ModelAction.Payment.Services.Response.select(selectServiceParameter))
                
            } else if let service = payload.category.services.first {
                
                action.send(ModelAction.Payment.Services.Response.selected(service))
                
            } else {
                
                action.send(ModelAction.Payment.Services.Response.failed(Payments.Operation.Error.unableSelectServiceForCategory(payload.category)))
            }
        }
    }
    
    func handlePaymentsBeginRequest(_ payload: ModelAction.Payment.Begin.Request) {
        
        Task {
            
            switch payload.base {
            case let .service(service):
                
                do {
                    
                    // create empty operation
                    let operation = Operation(service: service)
                    
                    // try to create first step
                    let step = try await paymentsStep(for: service, stepIndex: 0)
                    
                    // append first step to operation
                    let operationWithFirstStep = try operation.appending(step: step)
                    
                    // update depended parameters
                    let operationUpdatedDependedParameters = operationWithFirstStep.updated(reducer: paymentsReduceDependedParameter(parameterId:parameters:))
                    
                    self.action.send(ModelAction.Payment.Begin.Response.success(operationUpdatedDependedParameters))

                } catch {
                    
                    LoggerAgent.shared.log(level: .error, category: .model, message: "Failed create operation for service: \(service) with error: \(error.localizedDescription)")
                    self.action.send(ModelAction.Payment.Begin.Response.failure(self.paymentsAlertMessage(with: error)))
                }
               
            case let .source(source):
                
                do {
                    
                    // try get service with source
                    let service = try await paymentsService(for: source)
                    
                    // create empty operation
                    let operation = Operation(service: service, source: source)
                    
                    // try to create first step
                    let step = try await paymentsStep(for: service, stepIndex: 0)
                    
                    // update step parameters values with data in source
                    let stepUpdatedWithSource = step.updated(service: service, source: source, reducer: paymentsReduceParameterSourceValue(service:source:parameterId:))
                    
                    // append first step to operation
                    let operationWithFirstStep = try operation.appending(step: stepUpdatedWithSource)
                    
                    // update depended parameters
                    let operationUpdatedDependedParameters = operationWithFirstStep.updated(reducer: paymentsReduceDependedParameter(parameterId:parameters:))
                    
                    self.action.send(ModelAction.Payment.Begin.Response.success(operationUpdatedDependedParameters))

                } catch {
                    
                    LoggerAgent.shared.log(level: .error, category: .model, message: "Failed create operation for source: \(source) with error: \(error.localizedDescription)")
                    self.action.send(ModelAction.Payment.Begin.Response.failure(self.paymentsAlertMessage(with: error)))
                }
            }
        }
    }
    
    func handlePaymentsContinueRequest(_ payload: ModelAction.Payment.Continue.Request) {
        
        Task {
            
            /// operation from continue action payload updated depended parameters
            var operation = payload.operation.updated(reducer: paymentsReduceDependedParameter(parameterId:parameters:))
            
            do {
                
                repeat {
                    
                    let nextAction = operation.nextAction()
                    
                    switch nextAction {
                    case let .step(index: stepIndex):
                        // try to create step for the index
                        let step = try await paymentsStep(for: operation.service, stepIndex: stepIndex)
                        
                        // update step parameters values with data in source
                        let stepUpdatedWithSource = step.updated(service: operation.service, source: operation.source, reducer: paymentsReduceParameterSourceValue(service:source:parameterId:))
                        
                        // try to append step to operation
                        operation = try operation.appending(step: stepUpdatedWithSource)
                        
                    case .frontUpdate:
                        self.action.send(ModelAction.Payment.Continue.Response(result: .step(operation)))
                        return
                        
                    case let .backProcess(parameters: parameters, stepIndex: stepIndex, stage: stage):
                        switch stage {
                        case .local:
                            //TODO: local stage
                            break
                            
                        case let .remote(remoteStage):
                            switch remoteStage {
                            case .start:
                                if stepIndex < operation.steps.count {
                                    
                                    // process parameters on server
                                    try await paymentsProcessStart(parameters, operation)
                                    
                                    // try to update operation with processed values
                                    operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                                    
                                } else {
                                    
                                    // process parameters on server
                                    let response = try await paymentsProcessStart(parameters, operation)
                                    
                                    // try to create next step
                                    let nextStep = try await paymentsStep(operation: operation, response: response)
                                    
                                    // update step parameters values with data in source
                                    let nextStepUpdatedWithSource = nextStep.updated(service: operation.service, source: operation.source, reducer: paymentsReduceParameterSourceValue(service:source:parameterId:))
                                    
                                    // try to update operation with processed values
                                    operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                                    
                                    // try to append next step to operation
                                    operation = try operation.appending(step: nextStepUpdatedWithSource)
                                }
                               
                            case .next:
                                if stepIndex < operation.steps.count {
                                    
                                    // process parameters on server
                                    try await paymentsProcessNext(parameters, operation)
                                    
                                    // try to update operation with processed values
                                    operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                                    
                                } else {
                                    
                                    // try to create next step
                                    let response = try await paymentsProcessNext(parameters, operation)
                                    
                                    // try to create next step
                                    let nextStep = try await paymentsStep(operation: operation, response: response)
                                    
                                    // update step parameters values with data in source
                                    let nextStepUpdatedWithSource = nextStep.updated(service: operation.service, source: operation.source, reducer: paymentsReduceParameterSourceValue(service:source:parameterId:))
                                    
                                    // try to update operation with processed values
                                    operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                                    
                                    // try to append next step to operation
                                    operation = try operation.appending(step: nextStepUpdatedWithSource)
                                }
                                
                            case .confirm:
                                // try to confirm operation and receive success data
                                let success = try await paymentsProcessConfirm(parameters, operation)
                                self.action.send(ModelAction.Payment.Continue.Response(result: .complete(success)))
                                return
                                
                            case .complete:
                                // try to complete operation and receive success data
                                let success = try await paymentsProcessComplete(parameters, operation)
                                self.action.send(ModelAction.Payment.Continue.Response(result: .complete(success)))
                                return
                                
                            }
                        
                        }

                    case .frontConfirm:
                        self.action.send(ModelAction.Payment.Continue.Response(result: .confirm(operation)))
                        return
                        
                    case let .rollback(stepIndex: stepIndex):
                        operation = try operation.rollback(to: stepIndex)
                    
                    case .restart:
                        operation = operation.restarted()
                    }
                    
                } while true
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Failed continue operation: \(operation) with error: \(error.localizedDescription)")
                self.action.send(ModelAction.Payment.Continue.Response(result: .failure(self.paymentsAlertMessage(with: error))))
            }
        }
    }
}

//MARK: - Service

extension Model {
        
    func paymentsService(for source: Operation.Source) async throws -> Service {
        
        //TODO: implementation required
        throw Payments.Error.unsupported
    }
}

//MARK: - Step

extension Model {
    
    func paymentsStep(for service: Service, stepIndex: Int) async throws -> Operation.Step {
        
        switch service {
        case .fns:
            return try await paymentsStepFNS(for: stepIndex)
            
        case .fms:
            return try await paymentsStepFMS(for: stepIndex)
            
        case .fssp:
            return try await paymentsStepFSSP(for: stepIndex)
        }
    }
    
    func paymentsStep(operation: Operation, response: TransferResponseData) async throws -> Operation.Step {
        
        if let anywayResponse = response as? TransferAnywayResponseData {
            
            let nextParameters = try paymentsTransferAnywayStepParameters(service: operation.service, response: anywayResponse)
            let visible = try paymentsTransferAnywayStepVisible(service: operation.service, nextStepParameters: nextParameters, operationParameters: operation.parameters, response: anywayResponse)
            let stepStage = try paymentsTransferAnywayStepStage(service: operation.service, operation: operation, response: anywayResponse)
            let stepTerms = try paymentsTransferAnywayStepTerms(service: operation.service, visible: visible, nextStepParameters: nextParameters, operationParameters: operation.parameters)
            
            return Operation.Step(parameters: nextParameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: stepStage, terms: stepTerms, processed: nil))
            
        } else {
            
            //TODO: implementation required
            throw Payments.Error.unsupported
        }
    }
}

//MARK: - Parameter Reducers

extension Model {
    
    func paymentsReduceParameterSourceValue(service: Service, source: Operation.Source, parameterId: Parameter.ID) -> Parameter.Value? {

        //TODO: implementation required
        return nil
    }
    
    func paymentsReduceDependedParameter(parameterId: Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
        
        //TODO: implementation required
        return nil
    }
}

//MARK: - Process

extension Model {
    
    @discardableResult
    func paymentsProcessStart(_ process: [Parameter], _ operation: Operation) async throws -> TransferResponseData {
        
        switch operation.transferType {
        case .anyway:
            return try await paymentsTransferAnywayProcess(parameters: operation.parameters, process: process, isNewPayment: true)
        }
    }
    
    @discardableResult
    func paymentsProcessNext(_ process: [Parameter], _ operation: Operation) async throws -> TransferResponseData {
        
        switch operation.transferType {
        case .anyway:
            return try await paymentsTransferAnywayProcess(parameters: operation.parameters, process: process, isNewPayment: false)
        }
    }
    
    func paymentsProcessConfirm(_ process: [Parameter], _ operation: Operation) async throws -> Payments.Success {
        
        guard let codeValue = operation.parameters.first(where: { $0.id == Parameter.Identifier.code.rawValue })?.value else {
            throw Payments.Error.missingCodeParameter
        }
        
        let response = try await paymentsTransferComplete(code: codeValue)
        let success = try Payments.Success(with: response, operation: operation)
        
        return success
    }
    
    func paymentsProcessComplete(_ process: [Parameter], _ operation: Operation) async throws -> Payments.Success {
        
        //FIXME: optional code value?
        let response = try await paymentsTransferComplete(code: "")
        let success = try Payments.Success(with: response, operation: operation)
        
        return success
    }
}

//MARK: - Parameter Representable

extension Model {

    func paymentsParameterRepresentable(service: Service, parameterData: ParameterData) throws -> PaymentsParameterRepresentable? {
        
        switch service {
        case .fns, .fms, .fssp:
            return try paymentsParameterRepresentableTaxes(service: service, parameterData: parameterData)
        }
    }
    
    func paymentsParameterRepresentable(parameterData: ParameterData) throws -> PaymentsParameterRepresentable {
        
        switch parameterData.view {
        case .select:
            guard let options = parameterData.options else {
                throw Payments.Error.missingOptions(parameterData)
            }
            return Payments.ParameterSelectSimple(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterSample,
                title: parameterData.title,
                selectionTitle: "Выберете категорию",
                options: options)
            
        case .selectSwitch:
            guard let value = parameterData.value else {
                throw Payments.Error.missingValue(parameterData)
            }
            guard let options = parameterData.switchOptions else {
                throw Payments.Error.missingOptions(parameterData)
            }
            return Payments.ParameterSelectSwitch(
                .init(id: parameterData.id, value: value),
                options: options)
            
        case .input:
            //TODO: validator with ParameterData
            return Payments.ParameterInput(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterDocument,
                title: parameterData.title,
                validator: .init(minLength: 1, maxLength: nil, regEx: nil))
            
        case .info:
            return Payments.ParameterInfo(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterLocation,
                title: parameterData.title)
        }
    }
    
    func paymentsParameterRepresentable(service: Service, adittionalData: TransferAnywayResponseData.AdditionalData) throws -> PaymentsParameterRepresentable {
        
        Payments.ParameterInfo(
            .init(id: adittionalData.fieldName, value: adittionalData.fieldValue),
            icon: adittionalData.iconData ?? .parameterDocument,
            title: adittionalData.fieldTitle, placement: .spoiler)
    }
    
    func paymentsParameterRepresentableSelectServiceOption(for service: Service, with operators: [OperatorGroupData.OperatorData]) -> Payments.ParameterSelectService.Option? {
        
        switch service {
        case .fns:
            
            guard let anywayOperator = operators.first(where: { $0.code == service.operators.first?.rawValue })  else {
                return nil
            }
            
            let title = anywayOperator.title
            let description = anywayOperator.description ?? "Налоги"
            let icon = anywayOperator.iconImageData ?? .serviceFNS
            
            return .init(service: service, title: title, description: description, icon: icon)
            
        case .fms:
            
            guard let anywayOperator = operators.first(where: { $0.code == service.operators.first?.rawValue })  else {
                return nil
            }
            
            let title = anywayOperator.title
            let description = anywayOperator.description ?? "Госпошлины"
            let icon = anywayOperator.iconImageData ?? .serviceFMS
            
            return .init(service: service, title: title, description: description, icon: icon)
            
        case .fssp:
            
            guard let anywayOperator = operators.first(where: { $0.code == service.operators.first?.rawValue })  else {
                return nil
            }
            
            let title = anywayOperator.title
            let description = anywayOperator.description ?? "Задолженность"
            let icon = anywayOperator.iconImageData ?? .serviceFSSP
            
            return .init(service: service, title: title, description: description, icon: icon)
        }
    }
}

// MARK: - Transfer Complete

extension Model {
    
    func paymentsTransferComplete(code: String) async throws -> TransferResponseBaseData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let command = ServerCommands.TransferController.MakeTransfer(token: token, payload: .init(verificationCode: code))
        
        return try await serverAgent.executeCommand(command: command)
    }
}

//MARK: - Error Message

extension Model {
    
    func paymentsAlertMessage(with error: Error) -> String {
        
        return "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения."
        //TODO: refactor
        /*
        if let paymentsError = error as? Payments.Error {
            
            switch paymentsError {
            case .unableLoadFMSCategoryOptions:
                return "unableLoadFMSCategoryOptions"
                
            case .unableLoadFTSCategoryOptions:
                return "unableLoadFTSCategoryOptions"
                
            case .unableLoadFSSPDocumentOptions:
                return "unableLoadFSSPDocumentOptions"
                
            case .unableCreateOperationForService(let service):
                return "unableCreateOperationForService \(service.name) "
                
            case .unexpectedOperatorValue:
                return "unexpectedOperatorValue"
                
            case .missingOperatorParameter:
                return "missingOperatorParameter"
                
            case .missingParameter:
                return "missingParameter"
                
            case .missingPayer:
                return "missingPayer"
                
            case .missingCurrency:
                return "missingCurrency"
                
            case .missingCodeParameter:
                return "missingCodeParameter"
                
            case .missingAmountParameter:
                return "missingAmountParameter"
                
            case .missingAnywayTransferAdditional:
                return "missingAnywayTransferAdditional"
                
            case .failedObtainProductId:
                return "failedObtainProductId"
                
            case .failedTransferWithEmptyDataResponse:
                return "failedTransferWithEmptyDataResponse"
                
            case .failedTransfer(let status, let message):
                return "failedTransfer status \(status), message: \(String(describing: message))"
                
            case .failedMakeTransferWithEmptyDataResponse:
                return "failedMakeTransferWithEmptyDataResponse"
                
            case .failedMakeTransfer(let status, let message):
                return "failedMakeTransfer status \(status), message: \(String(describing: message))"
                
            case .clientInfoEmptyResponse:
                return "clientInfoEmptyResponse"
                
            case .anywayTransferFinalStepExpected:
                return "anywayTransferFinalStepExpected"
                
            case .notAuthorized:
                return "notAuthorized"
                
            case .unsupported:
                return "unsupported"
            }
            
        } else {
            
            return "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения."
        }
         */
    }
}
