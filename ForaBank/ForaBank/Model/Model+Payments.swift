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
                
                let source: Source
                
                enum Source {
                    
                    case service(Service)
                    case templateId(PaymentTemplateData.ID)
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
                    case failure(String)
                }
            }
        }
        
        // complete payment
        enum Complete {
            
            struct Request: Action {
                
                let operation: Operation
            }
            
            enum Response: Action {
                
                case success(Payments.Success)
                case failure(String)
            }
        }
        
        enum OperationDetail {
            
            struct Request: Action {
                
                let documentId: String
            }
            
            enum Response: Action {
                //FIXME: Result<OperationDetailData, Error>
                case success(details: OperationDetailData)
                case failture
            }
        }
        
        enum OperationDetailByPaymentId {
            
            struct Request: Action {
                
                let paymentOperationDetailId: Int
            }
            
            enum Response: Action {

                case success(OperationDetailData)
                case failture(ModelError)
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
    
    //MARK: - Handlers
    
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
                
                let selectServiceParameter = Payments.ParameterSelectService(category: payload.category, options: payload.category.services.compactMap { paymentsAnywayOperatorOption(for: $0, with: anywayOperators)})
                
                action.send(ModelAction.Payment.Services.Response.select(selectServiceParameter))
                
            } else if let service = payload.category.services.first {
                
                action.send(ModelAction.Payment.Services.Response.selected(service))
                
            } else {
                
                action.send(ModelAction.Payment.Services.Response.failed(Payments.Operation.Error.unableSelectServiceForCategory(payload.category)))
            }
        }
    }
    
    func handlePaymentsBeginRequest(_ payload: ModelAction.Payment.Begin.Request) {
        
        switch payload.source {
        case .service(let service):
            
            operation(for: service) { result in
                switch result {
                case .success(let operation):
                    self.action.send(ModelAction.Payment.Begin.Response.success(operation))
                    
                case .failure(let error):
                    self.action.send(ModelAction.Payment.Begin.Response.failure(self.paymentsAlertMessage(with: error)))
                }
            }
            
        case .templateId(let templateId):
            
            operation(for: templateId) { result in
                
                switch result {
                case .success(let operation):
                    self.action.send(ModelAction.Payment.Begin.Response.success(operation))
                    
                case .failure(let error):
                    self.action.send(ModelAction.Payment.Begin.Response.failure(self.paymentsAlertMessage(with: error)))
                }
            }
        }
    }
    
    func handlePaymentsContinueRequest(_ payload: ModelAction.Payment.Continue.Request) {
        
        let operation = payload.operation
        
        parameters(for: operation.service, parameters: operation.parameters, history: operation.history) { result in
            
            switch result {
            case .success(let parameters):
                
                var historyUpdated = operation.history
                let historyValues = Operation.history(for: parameters)
                historyUpdated.append(historyValues)
                
                let continueOperation = Operation(service: operation.service, parameters: parameters, history: historyUpdated)
                
                if parameters.filter({ $0 is Payments.ParameterFinal }).count > 0 {
                    
                    self.action.send(ModelAction.Payment.Continue.Response(result: .confirm(continueOperation)))
                    
                } else {
                    
                    self.action.send(ModelAction.Payment.Continue.Response(result: .step(continueOperation)))
                }
                
            case .failure(let error):
                self.action.send(ModelAction.Payment.Continue.Response(result: .failure(self.paymentsAlertMessage(with: error))))
            }
        }
    }
    
    func handlePaymentsCompleteRequest(_ payload: ModelAction.Payment.Complete.Request) {
        
        guard let codeParameter = payload.operation.parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.code.rawValue })?.parameter, let codeValue = codeParameter.value else {
            
            self.action.send(ModelAction.Payment.Complete.Response.failure(self.paymentsAlertMessage(with: Payments.Error.missingCodeParameter)))
            return
        }
        
        Task {
            
            do {
                
                let result = try await paymentsTransferComplete(code: codeValue)
                let success = try Payments.Success(with: result, operation: payload.operation)
                self.action.send(ModelAction.Payment.Complete.Response.success(success))
                
            } catch {
                
                self.action.send(ModelAction.Payment.Complete.Response.failure(self.paymentsAlertMessage(with: error)))
            }
        }
        
        //paymentsTransferComplete mock
        /*
         DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(200)) {
         
         guard let amountParameter = payload.operation.parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.amount.rawValue}) as? Payments.ParameterAmount else {
         
         self.action.send(ModelAction.Payment.Complete.Response.failure(self.paymentsAlertMessage(with: Payments.Error.missingAmountParameter)))
         return
         }
         
         self.action.send(ModelAction.Payment.Complete.Response.success(.init(status: .complete, amount: amountParameter.amount, currency: amountParameter.currency, icon: nil, operationDetailId: 0)))
         }
         */
    }
    
    func handleOperationDetailRequest(_ payload: ModelAction.Payment.OperationDetail.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PaymentOperationDetailContoller.GetOperationDetail(token: token, payload: .init(documentId: payload.documentId))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let details = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Payment.OperationDetail.Response.failture)
                        return
                    }
                    
                    self.action.send(ModelAction.Payment.OperationDetail.Response.success(details: details))
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    self.action.send(ModelAction.Payment.OperationDetail.Response.failture)
                }
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Payment.OperationDetail.Response.failture)
            }
        }
    }
    
    func handleOperationDetailByPaymentIdRequest(_ payload: ModelAction.Payment.OperationDetailByPaymentId.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PaymentOperationDetailContoller.GetOperationDetailByPaymentId(token: token, payload: .init(paymentOperationDetailId: payload.paymentOperationDetailId))
        let errorMessage = "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения."
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let details = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Payment.OperationDetailByPaymentId.Response.failture(.statusError(status: response.statusCode, message: response.errorMessage)))
                        return
                    }
                    
                    self.action.send(ModelAction.Payment.OperationDetailByPaymentId.Response.success(details))
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    self.action.send(ModelAction.Payment.OperationDetailByPaymentId.Response.failture(.statusError(status: response.statusCode, message: response.errorMessage)))
                }
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Payment.OperationDetailByPaymentId.Response.failture(.statusError(status: .serverError, message: errorMessage)))
            }
        }
    }
    
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
    
    //MARK: - Operation
    
    func operation(for service: Service, completion: @escaping (Result<Operation, Error>) -> Void) {
        
        parameters(for: service, parameters: [], history: []) { result in
            
            switch result {
            case .success(let parameters):
                
                // selected operator required
                guard parameters.contains(where: { $0.parameter.id == Parameter.Identifier.operator.rawValue}) else {
                    completion(.failure(Payments.Operation.Error.operatorNotSelectedForService(service)))
                    return
                }
                
                let historyValues = Operation.history(for: parameters)
                let operation = Operation(service: service, parameters: parameters, history: [historyValues])
                completion(.success(operation))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func operation(for tempaleId: PaymentTemplateData.ID, completion: @escaping (Result<Operation, Error>) -> Void) {
        
        completion(.failure(Payments.Error.unsupported))
        
        //TODO: implementation required
        // - find template with id
        // - extract from template data:
        //      - payment service
        //      - create operation
    }
    
    //MARK: - Parameters
    
    func parameters(for service: Service, parameters: [ParameterRepresentable], history: [[Parameter]] , completion: @escaping (Result<[ParameterRepresentable], Error>) -> Void) {
        
        let step = history.count
        
        switch service {
        case .fns:
            parametersFNS(parameters, step, completion)
            
        case .fms:
            parametersFMS(parameters, step, completion)
            
        case .fssp:
            parametersFSSP(parameters, step, completion)
        }
    }
    
    func paymentsAnywayOperatorOption(for service: Service, with operators: [OperatorGroupData.OperatorData]) -> Payments.ParameterSelectService.Option? {
        
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

// MARK: - Transfer

extension Model {
    
    @discardableResult
    func paymentsTransferAnywayStep(with parameters: [ParameterRepresentable], include: [Payments.Parameter.ID], step: TransferData.Step = .next) async throws -> TransferAnywayResponseData {
        
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
        
        let command = ServerCommands.TransferController.CreateAnywayTransfer(token: token, isNewPayment: step.isNewPayment, payload: .init(amount: amount, check: step.check, comment: nil, currencyAmount: currency, payer: payer, additional: additional, puref: puref))
        
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
    
    func paymentsTransferPayer(with parameters: [ParameterRepresentable], currency: Currency) -> TransferData.Payer? {
        
        if let parameterCard = parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.card.rawValue }), let productIdValue = parameterCard.parameter.value,
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
    
    func paymentsTransferAmount(with parameters: [ParameterRepresentable]) -> Double? {
        
        guard let amountParameter = parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.amount.rawValue}) as? Payments.ParameterAmount else {
            
            return nil
        }
        
        return amountParameter.amount
    }
    
    func paymentsTransferCurrency(with parameters: [ParameterRepresentable]) -> String? {
        
        //TODO: real implementation required
        return "RUB"
    }
    
    func paymentsTransferPuref(with parameters: [ParameterRepresentable]) -> String? {
        
        guard let operatorParameter = parameters.first(where: { $0.parameter.id ==  Payments.Parameter.Identifier.operator.rawValue}) else {
            
            return nil
        }
        
        return operatorParameter.parameter.value
    }
    
    func paymentsTransferAnywayAdditional(with parameters: [ParameterRepresentable], _ include: [Payments.Parameter.ID]) -> [TransferAnywayData.Additional]? {
        
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

// MARK: - Parameters Helpers

extension Model {
    
    func paymentsParametersContains(_ parameters: [ParameterRepresentable], id: Payments.Parameter.ID) -> Bool {
        
        let parametersIds = parameters.map{ $0.parameter.id }
        
        return parametersIds.contains(id)
    }
    
    func paymentsParameter(_ parameters: [ParameterRepresentable], id: Payments.Parameter.ID) -> Payments.Parameter? {
        
        return parameters.first(where: { $0.parameter.id == id })?.parameter
    }
    
    func paymentsParameterValue(_ parameters: [ParameterRepresentable], id: Payments.Parameter.ID) -> Payments.Parameter.Value {
        
        return parameters.first(where: { $0.parameter.id == id })?.parameter.value
    }
    
    func paymentsParametersEditable(_ parameters: [ParameterRepresentable], editable: Bool, filter: [String]? = nil) -> [ParameterRepresentable] {
        
        if let filter = filter {
            
            return parameters.map { parameter in
                
                if filter.contains(parameter.parameter.id) {
                    
                    return parameter.updated(editable: editable)
                    
                } else {
                    
                    return parameter
                }
            }
            
        } else {
            
            return parameters.map{ $0.updated(editable: editable) }
        }
    }
    
    func paymentsParametersRemove(_ parameters: [ParameterRepresentable], filter: [String]) -> [ParameterRepresentable] {
        
        return parameters.compactMap { parameter in
            
            guard filter.contains(parameter.parameter.id) == false else { return nil }
            return parameter
        }
    }
}
