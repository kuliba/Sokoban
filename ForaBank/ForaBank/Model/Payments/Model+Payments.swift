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
        
        enum Process {
            
            struct Request: Action {
                
                let operation: Payments.Operation
            }
            
            struct Response: Action {
                
                let result: Result
                
                enum Result {
                    
                    case step(Payments.Operation)
                    case confirm(Payments.Operation)
                    case complete(Payments.Success)
                    case failure(String)
                }
            }
        }
    }
}

//MARK: - Handlers

extension Model {

    func handlePaymentsProcessRequest(_ payload: ModelAction.Payment.Process.Request) {
        
        Task {

            do {

                let result = try await paymentsProcess(operation: payload.operation)
                
                switch result {
                case let .step(operation):
                    self.action.send(ModelAction.Payment.Process.Response(result: .step(operation)))
                    
                case let .confirm(operation):
                    self.action.send(ModelAction.Payment.Process.Response(result: .confirm(operation)))
                    
                case let .complete(success):
                    self.action.send(ModelAction.Payment.Process.Response(result: .complete(success)))
                }
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Failed continue operation: \(payload.operation) with error: \(error.localizedDescription)")
                self.action.send(ModelAction.Payment.Process.Response(result: .failure(error.localizedDescription)))
            }
        }
    }
}

//MARK: - Service

extension Model {
    
    enum PaymentsServiceResult {
        
        case select(Payments.ParameterSelectService)
        case selected(Payments.Service)
    }
    
    func paymentsService(for category: Payments.Category) async throws -> PaymentsServiceResult {
        
        switch category {
        case .taxes:
            if category.services.count > 1 {
                
                guard let anywayGroup = dictionaryAnywayOperatorGroup(for: category.rawValue) else {
                    throw Payments.Operation.Error.failedLoadServicesForCategory(category)
                }
                
                let operatorsCodes = category.services.compactMap{ $0.operators.first?.rawValue }
                let anywayOperators = anywayGroup.operators.filter{ operatorsCodes.contains($0.code)}
                let options = category.services.compactMap { paymentsParameterRepresentableSelectServiceOption(for: $0, with: anywayOperators)}
                
                let selectServiceParameter = Payments.ParameterSelectService(category: category, options: options)
                
                LoggerAgent.shared.log(level: .debug, category: .payments, message: "Select service parameter created with options: \(options.map({ $0.service })))")
                
                return .select(selectServiceParameter)
                
            } else {
                
                guard let service = category.services.first else {
                    throw Payments.Operation.Error.unableSelectServiceForCategory(category)
                }
                
                LoggerAgent.shared.log(level: .debug, category: .payments, message: "Selected service: \(service))")
                
                return .selected(service)
            }
            
        default:
            throw Payments.Error.unsupported
        }
    }
        
    func paymentsService(for source: Payments.Operation.Source) async throws -> Payments.Service {
        
        switch source {
        case let .mock(mock):
            return mock.service
            
        case .sfp: return .sfp
            
        default:
            throw Payments.Error.unsupported
        }
    }
}

//MARK: - Operation

extension Model {
    
    func paymentsOperation(with service: Payments.Service) async throws -> Payments.Operation {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Initial operation requested for service: \(service))")
        
        // create empty operation
        let operation = Payments.Operation(service: service)
        
        // process operation
        let result = try await paymentsProcess(operation: operation)
        
        guard case .step(let operation) = result else {
            throw Payments.Error.unexpectedProcessResult(result)
        }
        
        return operation
    }
    
    func paymentsOperation(with source: Payments.Operation.Source) async throws -> Payments.Operation {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Initial operation requested for source: \(source))")
        
        // try get service with source
        let service = try await paymentsService(for: source)
        
        // create empty operation
        let operation = Payments.Operation(service: service, source: source)
        
        // process operation
        let result = try await paymentsProcess(operation: operation)
        
        guard case .step(let operation) = result else {
            throw Payments.Error.unexpectedProcessResult(result)
        }
        
        return operation
    }
    
    /// Executes each time after appending step to operation.
    /// Return nil if no changes in parameters visibility and order required
    /// Othewise return parameters ids that must be visible in exact order
    func paymentsProcessOperationResetVisible(operation: Payments.Operation) async throws -> [Payments.Parameter.ID]? {
        
        switch operation.service {
        case .sfp:
            return try await paymentsProcessOperationResetVisibleSFP(operation)
            
        default:
            return nil
        }
    }
}

//MARK: - Step

extension Model {
    
    func paymentsProcessLocalStep(operation: Payments.Operation, stepIndex: Int) async throws -> Payments.Operation.Step {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Local step for index: \(stepIndex) requested for operation: \(operation.shortDescription)")
        
        switch operation.service {
        case .fns:
            return try await paymentsStepFNS(operation, for: stepIndex)
            
        case .fms:
            return try await paymentsStepFMS(operation, for: stepIndex)
            
        case .fssp:
            return try await paymentsStepFSSP(operation, for: stepIndex)
            
        case .sfp:
            return try await paymentsStepSFP(operation, for: stepIndex)
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    func paymentsProcessRemoteStep(operation: Payments.Operation, response: TransferResponseData) async throws -> Payments.Operation.Step {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Remote step with response: \(response) requested for operation: \(operation.shortDescription)")
        
        switch response {
        case let anywayResponse as TransferAnywayResponseData:
            
            switch operation.transferType {
            case .anyway:
                
                let next = try paymentsTransferAnywayStepParameters(operation, response: anywayResponse)
                
                let duplicates = next.map({ $0.parameter }).filter({ operation.parametersIds.contains($0.id) })
                if duplicates.count > 0 {
                    LoggerAgent.shared.log(level: .error, category: .payments, message: "Anyway transfer response duplicates detected end removed: \(duplicates) from operation: \(operation.shortDescription)")
                }
                
                // next parameters without duplicates
                let nextParameters = next.filter({ operation.parametersIds.contains($0.id) == false })
                
                let visible = try paymentsTransferAnywayStepVisible(operation, nextStepParameters: nextParameters, operationParameters: operation.parameters, response: anywayResponse)
                let stepStage = try paymentsTransferAnywayStepStage(operation, response: anywayResponse)
                let required = try paymentsTransferAnywayStepRequired(operation, visible: visible, nextStepParameters: nextParameters, operationParameters: operation.parameters)
                
                return Payments.Operation.Step(parameters: nextParameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: stepStage, required: required, processed: nil))
                
            case .sfp:
                let next = try paymentsTransferSFPStepParameters(operation, response: anywayResponse)
                
                let duplicates = next.map({ $0.parameter }).filter({ operation.parametersIds.contains($0.id) })
                if duplicates.count > 0 {
                    LoggerAgent.shared.log(level: .error, category: .payments, message: "Anyway transfer response duplicates detected end removed: \(duplicates) from operation: \(operation.shortDescription)")
                }
                
                // next parameters without duplicates
                let nextParameters = next.filter({ operation.parametersIds.contains($0.id) == false })
                
                let visible = try paymentsTransferSFPStepVisible(operation, nextStepParameters: nextParameters, operationParameters: operation.parameters, response: anywayResponse)
                let stepStage = try paymentsTransferSFPStepStage(operation, response: anywayResponse)
                let required = try paymentsTransferSFPStepRequired(operation, visible: visible, nextStepParameters: nextParameters, operationParameters: operation.parameters)
                
                return Payments.Operation.Step(parameters: nextParameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: stepStage, required: required, processed: nil))
                
            default:
                throw Payments.Error.unsupported
                
            }

        default:
            throw Payments.Error.unsupported
        }
    }
}

//MARK: - Parameter Reducers

extension Model {
    
    func paymentsProcessSourceReducer(service: Payments.Service, source: Payments.Operation.Source, parameterId: Payments.Parameter.ID) -> Payments.Parameter.Value? {

        switch source {
        case let .mock(mock):
            return mock.parameters.first(where: { $0.id == parameterId })?.value
            
        case let .sfp(phone: phone, bankId: bankId):
            switch parameterId {
            case Payments.Parameter.Identifier.sfpPhone.rawValue:
                return phone
                
            case Payments.Parameter.Identifier.sfpBank.rawValue:
                return bankId
                
            default:
                return nil
            }
            
        default:
            return nil
        }
    }
    
    func paymentsProcessDependencyReducer(parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
        
        //TODO: implementation required
        return nil
    }
}

//MARK: - Remote Process

extension Model {
    
    @discardableResult
    func paymentsProcessRemoteStart(_ process: [Payments.Parameter], _ operation: Payments.Operation) async throws -> TransferResponseData {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Remote: START: parameters \(process) requested for operation: \(operation.shortDescription)")
        
        switch operation.transferType {
        case .anyway:
            return try await paymentsTransferAnywayProcess(parameters: operation.parameters, process: process, isNewPayment: true)
            
        case .sfp:
            return try await paymentsTransferSFPProcess(parameters: operation.parameters, process: process)
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    @discardableResult
    func paymentsProcessRemoteNext(_ process: [Payments.Parameter], _ operation: Payments.Operation) async throws -> TransferResponseData {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Remote: NEXT: parameters \(process) requested for operation: \(operation.shortDescription)")
        
        switch operation.transferType {
        case .anyway:
            return try await paymentsTransferAnywayProcess(parameters: operation.parameters, process: process, isNewPayment: false)
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    func paymentsProcessRemoteConfirm(_ process: [Payments.Parameter], _ operation: Payments.Operation) async throws -> Payments.Success {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Remote: CONFIRM: parameters \(process) requested for operation: \(operation.shortDescription)")
        
        let codeParameterId = Payments.Parameter.Identifier.code.rawValue
        guard let codeValue = operation.parameters.first(where: { $0.id == codeParameterId })?.value else {
            throw Payments.Error.missingParameter(codeParameterId)
        }
        
        let response = try await paymentsTransferComplete(code: codeValue)
        let success = try Payments.Success(with: response, operation: operation)
        
        return success
    }
    
    func paymentsProcessRemoteComplete(_ process: [Payments.Parameter], _ operation: Payments.Operation) async throws -> Payments.Success {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Remote: COMPLETE: parameters \(process) requested for operation: \(operation.shortDescription)")
        
        //FIXME: optional code value?
        let response = try await paymentsTransferComplete(code: "")
        let success = try Payments.Success(with: response, operation: operation)
        
        return success
    }
}

//MARK: - Parameter Representable

extension Model {

    func paymentsParameterRepresentable(_ operation: Payments.Operation, parameterData: ParameterData) throws -> PaymentsParameterRepresentable? {
        
        switch operation.service {
        case .fns, .fms, .fssp:
            return try paymentsParameterRepresentableTaxes(operation: operation, parameterData: parameterData)
            
        default:
            throw Payments.Error.unsupported
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
    
    func paymentsParameterRepresentable(_ operation: Payments.Operation, adittionalData: TransferAnywayResponseData.AdditionalData) throws -> PaymentsParameterRepresentable? {
        
        switch operation.service {
        case .sfp:
            return try paymentsParameterRepresentableSFP(operation, adittionalData: adittionalData)
            
        default:
            return Payments.ParameterInfo(
                .init(id: adittionalData.fieldName, value: adittionalData.fieldValue),
                icon: adittionalData.iconData ?? .parameterDocument,
                title: adittionalData.fieldTitle, placement: .spoiler)
        }
    }
    
    func paymentsParameterRepresentableSelectServiceOption(for service: Payments.Service, with operators: [OperatorGroupData.OperatorData]) -> Payments.ParameterSelectService.Option? {
        
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
            
        default:
            return nil
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

//MARK: - Helpers

extension Model {
    
    func paymentsParameterValue(_ parameters: [PaymentsParameterRepresentable], id: Payments.Parameter.ID) -> Payments.Parameter.Value {
        
        return parameters.first(where: { $0.id == id })?.value
    }
    
    func paymentsMock(for service: Payments.Service) -> Payments.Mock? {
        
        switch service {
        case .fns: return paymentsMockFNS()  
        case .fms: return paymentsMockFMS()  
        case .fssp: return paymentsMockFSSP()
        case .sfp: return paymentsMockSFP()
            
        default:
            return nil
        }
    }
    
    func paymentsIsAutoContinueRequired(operation: Payments.Operation, updated: Payments.Parameter.ID) -> Bool {
        
        guard let nextAction = try? operation.nextAction() else {
            return false
        }
        
        switch nextAction {
        case .rollback:
            switch updated {
            case Payments.Parameter.Identifier.operator.rawValue, Payments.Parameter.Identifier.amount.rawValue:
                return false
                
            default:
                return true
            }
            
        default:
            return false
        }
    }
}
