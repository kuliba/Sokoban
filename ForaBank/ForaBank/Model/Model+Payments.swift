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
                
                let selectServiceParameter = Payments.ParameterSelectService(category: payload.category, options: payload.category.services.compactMap { paymentsParameterSelectServiceOption(for: $0, with: anywayOperators)})
                
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
                    let operationUpdatedDependedParameters = operationWithFirstStep.updated(reducer: paymentsDependedParameterUpdate(parameterId:parameters:))
                    
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
                    let stepUpdatedWithSource = step.updated(service: service, source: source, reducer: paymentsParameterSourceValue(service:source:parameterId:))
                    
                    // append first step to operation
                    let operationWithFirstStep = try operation.appending(step: stepUpdatedWithSource)
                    
                    // update depended parameters
                    let operationUpdatedDependedParameters = operationWithFirstStep.updated(reducer: paymentsDependedParameterUpdate(parameterId:parameters:))
                    
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
            var operation = payload.operation.updated(reducer: paymentsDependedParameterUpdate(parameterId:parameters:))
            
            do {
                
                repeat {
                    
                    let nextAction = operation.nextAction()
                    
                    switch nextAction {
                    case let .step(index: stepIndex):
                        // try to create step for the index
                        let step = try await paymentsStep(for: operation.service, stepIndex: stepIndex)
                        
                        // update step parameters values with data in source
                        let stepUpdatedWithSource = step.updated(service: operation.service, source: operation.source, reducer: paymentsParameterSourceValue(service:source:parameterId:))
                        
                        // try to append step to operation
                        operation = try operation.appending(step: stepUpdatedWithSource)
                        
                    case .frontUpdate:
                        self.action.send(ModelAction.Payment.Continue.Response(result: .step(operation)))
                        return
                        
                    case let .backProcess(parameters: parameters, stepIndex: stepIndex, stage: stage):
                        switch stage {
                        case .start:
                            // try to create next step
                            let nextStep = try await paymentsProcessStart(parameters: parameters, stepIndex: stepIndex, operation: operation)
                            
                            // update step parameters values with data in source
                            let nextStepUpdatedWithSource = nextStep.updated(service: operation.service, source: operation.source, reducer: paymentsParameterSourceValue(service:source:parameterId:))
                            
                            // try to update operation with processed values
                            operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                            
                            // try to append next step to operation
                            operation = try operation.appending(step: nextStepUpdatedWithSource)
                            
                        case .next:
                            // try to create next step
                            let nextStep = try await paymentsProcessNext(parameters: parameters, stepIndex: stepIndex, operation: operation)
                            
                            // update step parameters values with data in source
                            let nextStepUpdatedWithSource = nextStep.updated(service: operation.service, source: operation.source, reducer: paymentsParameterSourceValue(service:source:parameterId:))
                            
                            // try to update operation with processed values
                            operation = try operation.processed(parameters: parameters, stepIndex: stepIndex)
                            
                            // try to append next step to operation
                            operation = try operation.appending(step: nextStepUpdatedWithSource)
                            
                        case .confirm:
                            // try to confirm operation and receive success data
                            let success = try await paymentsProcessConfirm(parameters: parameters, stepIndex: stepIndex, operation: operation)
                            self.action.send(ModelAction.Payment.Continue.Response(result: .complete(success)))
                            return
                            
                        case .complete:
                            // try to complete operation and receive success data
                            let success = try await paymentsProcessComplete(parameters: parameters, stepIndex: stepIndex, operation: operation)
                            self.action.send(ModelAction.Payment.Continue.Response(result: .complete(success)))
                            return
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
}

//MARK: - Parameter

extension Model {
    
    func paymentsParameterSourceValue(service: Service, source: Operation.Source, parameterId: Parameter.ID) -> Parameter.Value? {
        
        //TODO: implementation required
        return nil
    }
    
    func paymentsDependedParameterUpdate(parameterId: Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
        
        //TODO: implementation required
        return nil
    }
    
    func paymentsParameterSelectServiceOption(for service: Service, with operators: [OperatorGroupData.OperatorData]) -> Payments.ParameterSelectService.Option? {
        
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

//MARK: - Process

extension Model {
    
    @discardableResult
    func paymentsProcessStart(parameters: [Parameter], stepIndex: Int, operation: Operation) async throws -> Operation.Step {
        
        //TODO: implementation required
        throw Payments.Error.unsupported
    }
    
    @discardableResult
    func paymentsProcessNext(parameters: [Parameter], stepIndex: Int, operation: Operation) async throws -> Operation.Step {
        
        //TODO: implementation required
        throw Payments.Error.unsupported
    }
    
    func paymentsProcessConfirm(parameters: [Parameter], stepIndex: Int, operation: Operation) async throws -> Payments.Success {
        
        //TODO: implementation required
        throw Payments.Error.unsupported
    }
    
    func paymentsProcessComplete(parameters: [Parameter], stepIndex: Int, operation: Operation) async throws -> Payments.Success {
        
        //TODO: implementation required
        throw Payments.Error.unsupported
    }
}

// MARK: - Service

extension Model {
    
    
}

// MARK: - Transfer

extension Model {
    
    @discardableResult
    func paymentsTransferAnywayStep(with parameters: [PaymentsParameterRepresentable], include: [Payments.Parameter.ID], step: TransferData.Step = .next) async throws -> TransferAnywayResponseData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        guard let puref = paymentsTransferPuref(with: parameters) else {
            throw Payments.Error.missingOperatorParameter
        }
        
        let amount = paymentsTransferAmount(with: parameters)
        
        guard let currency = paymentsTransferCurrency(with: parameters) else {
            throw Payments.Error.missingCurrency
        }
        
        guard let payer = paymentsTransferPayer(with: parameters, currency: .rub) else {
            throw Payments.Error.missingPayer
        }
        
        guard let additional = paymentsTransferAnywayAdditional(with: parameters, include) else {
            throw Payments.Error.missingAnywayTransferAdditional
        }
        
        let command = ServerCommands.TransferController.CreateAnywayTransfer(token: token, isNewPayment: step.isNewPayment, payload: .init(amount: amount, check: step.isCheck, comment: nil, currencyAmount: currency, payer: payer, additional: additional, puref: puref))
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let transferData = response.data else {
                            continuation.resume(with: .failure(Payments.Error.failedTransferWithEmptyDataResponse))
                            return
                        }
                        continuation.resume(with: .success(transferData))
                        
                    default:
                        continuation.resume(with: .failure(Payments.Error.failedTransfer(status: response.statusCode, message: response.errorMessage)))
                    }
                    
                case .failure(let error):
                    continuation.resume(with: .failure(error))
                }
            }
        })
    }
    
    func paymentsTransferComplete(code: String) async throws -> TransferResponseBaseData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let command = ServerCommands.TransferController.MakeTransfer(token: token, payload: .init(verificationCode: code))
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let transferData = response.data else {
                            continuation.resume(with: .failure(Payments.Error.failedMakeTransferWithEmptyDataResponse))
                            return
                        }
                        continuation.resume(with: .success(transferData))
                        
                    default:
                        continuation.resume(with: .failure(Payments.Error.failedMakeTransfer(status: response.statusCode, message: response.errorMessage)))
                    }
                    
                case .failure(let error):
                    continuation.resume(with: .failure(error))
                }
            }
        })
    }
    
    func paymentsTransferClientInfo() async throws -> ClientInfoData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let command = ServerCommands.PersonController.GetClientInfo(token: token)
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let transferData = response.data else {
                            continuation.resume(with: .failure(Payments.Error.clientInfoEmptyResponse))
                            return
                        }
                        continuation.resume(with: .success(transferData))
                        
                    default:
                        continuation.resume(with: .failure(Payments.Error.failedMakeTransfer(status: response.statusCode, message: response.errorMessage)))
                    }
                    
                case .failure(let error):
                    continuation.resume(with: .failure(error))
                }
            }
        })
    }
    
    func paymentsTransferPayer(with parameters: [PaymentsParameterRepresentable], currency: Currency) -> TransferData.Payer? {
        
        if let parameterCard = parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.product.rawValue }), let productIdValue = parameterCard.parameter.value,
           let productId = Int(productIdValue),
           let productType = paymentsProductType(for: productId) {
            
            switch productType {
            case .card:
                return .init(inn: nil, accountId: nil, accountNumber: nil, cardId: productId, cardNumber: nil, phoneNumber: nil)
            case .account:
                return .init(inn: nil, accountId: productId, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
            default:
                return nil
            }
            
        } else {
            
            if let cardId = paymentsFirstProductId(of: .card, currency: currency) {
                
                return .init(inn: nil, accountId: nil, accountNumber: nil, cardId: cardId, cardNumber: nil, phoneNumber: nil)
                
            } else if let accountId = paymentsFirstProductId(of: .account, currency: currency) {
                
                return .init(inn: nil, accountId: accountId, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
                
            } else {
                
                return nil
            }
        }
    }
    
    var productsData: [ProductData] { products.value.values.flatMap { $0 } }
    
    func paymentsProductType(for productId: Int) -> ProductType? {
        productsData.first(where: { $0.id == productId })?.productType
    }
    
    func paymentsFirstProductId(of type: ProductType, currency: Currency) -> Int? {
        productsData.first(where: { $0.productType == type && $0.currency == currency.description })?.id
    }
    
    func paymentsProduct(with id: Int) -> ProductData? {
        productsData.first(where: { $0.id == id })
    }
    
    func paymentsTransferAmount(with parameters: [PaymentsParameterRepresentable]) -> Double? {
        
        guard let amountParameter = parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.amount.rawValue}) as? Payments.ParameterAmount else {
            
            return nil
        }
        
        return amountParameter.amount
    }
    
    func paymentsTransferCurrency(with parameters: [PaymentsParameterRepresentable]) -> String? {
        
        //TODO: real implementation required
        return "RUB"
    }
    
    func paymentsTransferPuref(with parameters: [PaymentsParameterRepresentable]) -> String? {
        
        guard let operatorParameter = parameters.first(where: { $0.parameter.id ==  Payments.Parameter.Identifier.operator.rawValue}) else {
            
            return nil
        }
        
        return operatorParameter.parameter.value
    }
    
    func paymentsTransferAnywayAdditional(with parameters: [PaymentsParameterRepresentable], _ include: [Payments.Parameter.ID]) -> [TransferAnywayData.Additional]? {
        
        guard include.isEmpty == false else {
            return []
        }
        
        var additional = [TransferAnywayData.Additional]()
        for (index, paraneterId) in include.enumerated() {
            
            guard let parameter = parameters.first(where: { $0.parameter.id == paraneterId})?.parameter,
                  let parameterValue = parameter.value else {
                continue
            }
            
            additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: parameterValue))
        }
        
        return additional
    }
}

// MARK: - Transfer Restart

extension Model {
    
    /// This method checks if transfer restart is required. If any parameter has property 'processStep' other than 'nil', and current parameter value has any difference with values from the history - in this case transfer restart is required.
    /// - Parameters:
    ///   - parameters: list of parameters
    ///   - history: history of parameters values changing
    /// - Returns: true - restart is required
    func paymentsIsTransferRestartRequired(parameters: [PaymentsParameterRepresentable], history: [[Parameter]]) -> Bool {
        
        //FIXME: refactor
        return false
        
        /*
        for parameter in parameters {
            
            // check if parameter should be processed on some step of transaction
            guard parameter.processStep != nil else {
                continue
            }
            
            let parameterHistory = history.flatMap({ $0 }).filter({ $0.id == parameter.parameter.id })
            
            // check if any parameter's value in history doesn't match to the parameter's value
            for parameterHistroryItem in parameterHistory {
                
                guard parameterHistroryItem.value == parameter.parameter.value else {
                    // some parameter's value in the history doesn't match, this means that transfer restart is requiered
                    return true
                }
            }
        }
        
        return false
         */
    }
    
    /// Returns minmal transfer step. This value required to determinate parameters for 'initial' transfer step.
    /// - Parameter parameters: list of parameters
    /// - Returns: minimal transfer step or nil
    func paymentsTransferProcessStepMin(parameters: [PaymentsParameterRepresentable]) -> Int? {
        
        //FIXME: refactor
        return nil
        /*
        parameters.compactMap({ $0.processStep }).min()
         */
    }
    
    /// Returns parameters for transfer step
    /// - Parameters:
    ///   - parameters: list of parameters
    ///   - step: transfer step
    /// - Returns: parameters for step or nil
    func paymentsTransferParametersForStep(parameters: [PaymentsParameterRepresentable], step: Int) -> [Payments.Parameter]? {
        
        //FIXME: refactor
        return nil
        /*
        let result = parameters.filter({$0.processStep == step }).map({ $0.parameter })
        
        return result.isEmpty == false ? result : nil
         */
    }
}

// MARK: - Parameters Helpers

extension Model {
    
    func paymentsParametersContains(_ parameters: [PaymentsParameterRepresentable], id: Payments.Parameter.ID) -> Bool {
        
        let parametersIds = parameters.map{ $0.parameter.id }
        
        return parametersIds.contains(id)
    }
    
    func paymentsParameter(_ parameters: [PaymentsParameterRepresentable], id: Payments.Parameter.ID) -> Payments.Parameter? {
        
        return parameters.first(where: { $0.parameter.id == id })?.parameter
    }
    
    func paymentsParameterValue(_ parameters: [PaymentsParameterRepresentable], id: Payments.Parameter.ID) -> Payments.Parameter.Value {
        
        return parameters.first(where: { $0.parameter.id == id })?.parameter.value
    }
    
    func paymentsParametersEditable(_ parameters: [PaymentsParameterRepresentable], editable: Bool, filter: [String]? = nil) -> [PaymentsParameterRepresentable] {
        
        if let filter = filter {
            
            return parameters.map { parameter in
                
                if filter.contains(parameter.parameter.id) {
                    
                    return parameter.updated(isEditable: editable)
                    
                } else {
                    
                    return parameter
                }
            }
            
        } else {
            
            return parameters.map{ $0.updated(isEditable: editable) }
        }
    }
    
    func paymentsParametersRemove(_ parameters: [PaymentsParameterRepresentable], filter: [String]) -> [PaymentsParameterRepresentable] {
        
        return parameters.compactMap { parameter in
            
            guard filter.contains(parameter.parameter.id) == false else { return nil }
            return parameter
        }
    }
}

//MARK: - Error Message

extension Model {
    
    func paymentsAlertMessage(with error: Error) -> String {
        
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
    }
}
