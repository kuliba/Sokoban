//
//  ModelAction+Payments.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation
import ServerAgent
import PhoneNumberWrapper

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
                    case failure(Error)
                }
            }
        }
        
        enum Subscription {
            
            struct Request: Action {
                
                let parameters: [PaymentsParameterRepresentable]
                let action: SubscriptionAction
            
                enum SubscriptionAction {
                    
                    case link
                    case deny
                    case cancel
                    case update
                }
            }
            
            struct Response: Action {
                
                let result: Result<Payments.Success, Error>
            }
        }
    }
}

//MARK: - Handlers

extension Model {

    func handlePaymentsProcessRequest(_ payload: ModelAction.Payment.Process.Request) async {
        
            do {

                let result = try await paymentsProcess(operation: payload.operation)
                self.action.send(ModelAction.Payment.Process.Response(result: .init(result)))
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Failed continue operation: \(payload.operation) with error: \(error.localizedDescription)")
                self.action.send(ModelAction.Payment.Process.Response(result: .failure(error)))
            }
    }
    
    func handlePaymentSubscriptionRequest(_ payload: ModelAction.Payment.Subscription.Request) async {
        
        switch payload.action {
        case .link:
            
            await handlePaymentSubscriptionLinkRequest(payload)
            
        case .deny:
            
            await handlePaymentSubscriptionDenyRequest(payload)
            
        case .cancel:
            
            await handlePaymentSubscriptionCancelRequest(payload)
            
        case .update:
            
            do {
                
                try await handlePaymentSubscriptionUpdateRequest(payload)

            } catch(let error) {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Failed continue operation with error: \(error.localizedDescription)")
                self.action.send(ModelAction.Payment.Process.Response(result: .failure(error)))
            }
        }
    }
    
    internal func handlePaymentSubscriptionDenyRequest(
        _ payload: ModelAction.Payment.Subscription.Request
    ) async {
        
        let result = await Result {
            try await paymentsC2BDeny(parameters: payload.parameters)
        }
        
        self.action.send(ModelAction.Payment.Subscription.Response(result: result))
    }
    
    internal func handlePaymentSubscriptionLinkRequest(
        _ payload: ModelAction.Payment.Subscription.Request
    ) async {
        
        let result = await Result {
            try await paymentsC2BSubscribe(parameters: payload.parameters)
        }
        
        self.action.send(ModelAction.Payment.Subscription.Response(result: result))
    }
    
    internal func handlePaymentSubscriptionUpdateRequest(
        _ payload: ModelAction.Payment.Subscription.Request
    ) async throws {
        
        guard let productId = try? payload.parameters.value(forIdentifier: .product),
              let productIdInt = Int(productId),
              let product = product(productId: productIdInt)
        else {
            throw Payments.Error.missingParameter(Payments.Parameter.Identifier.product.rawValue)
        }
        
        switch product.productType {
        case .card:
            let makeCardCommend = { (token: String) in
                
                let (tokenSubscription, product) = try self.getRequestUpdatePayload(
                    parameters: payload.parameters
                )
                
                let command = ServerCommands.SubscriptionController.UpdateC2bSubscriptionCard(
                    token: token,
                    payload: .init(
                        subscriptionToken: tokenSubscription,
                        productId: product.id
                    )
                )
                
                return command
            }
            
            await updateSubscription(
                makeCommand: makeCardCommend,
                parameters: payload.parameters
            )
            
        default:
            
            let makeAccCommand = { (token: String) in
                
                let (tokenSubscription, product) = try self.getRequestUpdatePayload(
                    parameters: payload.parameters
                )
                
                let command = ServerCommands.SubscriptionController.UpdateC2bSubscriptionAcc(
                    token: token,
                    payload: .init(
                        subscriptionToken: tokenSubscription,
                        productId: product.id
                    )
                )
                
                return command
            }
            
            await updateSubscription(
                makeCommand: makeAccCommand,
                parameters: payload.parameters
            )
        }
    }
    
    internal func updateSubscription<Command: ServerCommand>(
        makeCommand: @escaping (String) throws -> Command,
        parameters: [PaymentsParameterRepresentable]
    ) async {
        
        let result = await Result {
            try await paymentsC2BActionSubscribe(
                makeCommand: makeCommand,
                parameters: parameters
            )
        }
        
        self.action.send(ModelAction.Payment.Subscription.Response(result: result))
    }
    
    internal func handlePaymentSubscriptionCancelRequest(
        _ payload: ModelAction.Payment.Subscription.Request
    ) async {
        
        let makeCommandCancel = { (token: String) in
            
            guard let tokenSubscription = try? payload.parameters.parameter(
                forIdentifier: .successSubscriptionToken).value
            else {
                throw Payments.Error.missingValueForParameter(
                    Payments.Parameter.Identifier.successSubscriptionToken.rawValue
                )
            }
            
            let command = ServerCommands.SubscriptionController.CancelC2bSubscriptions(
                token: token,
                payload: .init(
                    subscriptionToken: tokenSubscription
                )
            )
            
            return command
        }
        
        let result = await Result {
            try await paymentsC2BActionSubscribe(
                makeCommand: makeCommandCancel,
                parameters: payload.parameters
            )
        }
        
        self.action.send(ModelAction.Payment.Subscription.Response(result: result))
    }
    
    private func getRequestUpdatePayload(
        parameters: [PaymentsParameterRepresentable]
    ) throws -> (tokenSubscription: String, ProductData) {
        
        guard let tokenSubscription = try? parameters.parameter(forIdentifier: .successSubscriptionToken).value,
              let productParam = try? parameters.value(forIdentifier: .product),
              let productIdInt = Int(productParam)
        else {
            throw Payments.Error.missingValueForParameter(
                Payments.Parameter.Identifier.successSubscriptionToken.rawValue
            )
        }
        
        guard let product = self.product(productId: productIdInt)
        else {
            throw Payments.Error.missingValueForParameter(
                Payments.Parameter.Identifier.product.rawValue
            )
        }
        
        return (tokenSubscription: tokenSubscription, product)
    }
}

private extension ModelAction.Payment.Process.Response.Result {
    
    init(_ result: Payments.ProcessResult) {
        
        switch result {
        case let .step(operation):
            self = .step(operation)
        case let .confirm(operation):
            self = .confirm(operation)
        case let .complete(success):
            self = .complete(success)
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
        
    func paymentsService(for source: Payments.Operation.Source) throws -> Payments.Service {
        
        switch source {
        case let .mock(mock): return mock.service
        case .sfp: return .sfp
        case .requisites: return .requisites
        case .c2b: return .c2b
        case .c2bSubscribe: return .c2b
        case .direct: return .abroad
        case .return: return .return
        case .change: return .change
        case .template(let templateId):
                
            guard let template = self.paymentTemplates.value.first(where: { $0.id == templateId }) else {
                throw Payments.Error.unsupported
            }
            
            switch template.type {
            case .newDirect,
                    .direct,
                    .contactCash,
                    .contactAddressing,
                    .contactAdressless,
                    .contactAddressless:
                
                return .abroad
                
            case .sfp, .byPhone:
                return .sfp
                
            case .externalEntity, .externalIndividual:
                return .requisites
                
            case .mobile:
                return .mobileConnection
                
            case .taxAndStateService:
                guard let parameterList = template.parameterList as? [TransferAnywayData],
                      let puref = parameterList.first?.puref,
                      let `operator` = Payments.Operator(rawValue: puref) else {
                    throw Payments.Error.unsupported
                }
                
                switch `operator` {
                case .fms:
                    return .fms
                    
                case .fns, .fnsUin:
                    return .fns
                    
                case .fssp:
                    return .fssp
                    
                default:
                    throw Payments.Error.unsupported
                }
                
            case .insideBank:
                return .toAnotherCard
                
            case .housingAndCommunalService:
                return .utility
                
            case .internet:
                return .internetTV
                
            case .transport:
                return .transport
                
            default:
                throw Payments.Error.unsupported
            }
            
        case .servicePayment(let operatorCode, _, _):
            guard let operatorData = self.dictionaryAnywayOperator(for: operatorCode) else {
                throw Payments.Error.missingValueForParameter(operatorCode)
            }
            
            let parentCode = operatorData.parentCode
            switch parentCode {
                
            case Payments.Operator.internetTV.rawValue:
                return .internetTV
                
            case Payments.Operator.utility.rawValue:
                return .utility
                
            case Payments.Operator.transport.rawValue:
                return .transport
                
            default:
                throw Payments.Error.unsupported
            }
            
        case .avtodor:
            return .avtodor
            
        case .gibdd:
            return .gibdd
            
        case let .latestPayment(latestPaymentId):
            
            guard let latestPayment = self.latestPayments.value.first(where: { $0.id == latestPaymentId }) else {
                throw Payments.Error.unsupported
            }
            
            switch latestPayment.type {
            case .internet:
                return .internetTV
                
            case .service:
                return .utility
                
            case .mobile:
                return .mobileConnection
                
            case .phone:
                return .sfp
                
            case .outside:
                return .abroad
                
            case .transport:
                return .transport
           
            case .taxAndStateService:
                return try latestPayment.getServiceIdentifierForTaxService()

            default:
                throw Payments.Error.unsupported
            }
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
        let service = try paymentsService(for: source)
        
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
    /// Otherwise return parameters ids that must be visible in exact order
    func paymentsProcessOperationResetVisible(operation: Payments.Operation) async throws -> [Payments.Parameter.ID]? {
        
        switch operation.service {
        case .sfp:
            return try await paymentsProcessOperationResetVisibleSFP(operation)
        
        case .requisites:
            return try await paymentsProcessOperationResetVisibleRequisits(operation)

        case .abroad:
            return try await paymentsProcessOperationResetVisibleCountry(operation)
            
        case .toAnotherCard:
            return try await paymentsProcessOperationResetVisibleToAnotherCard(operation)
            
        case .internetTV, .utility, .transport:
            return paymentsProcessOperationResetVisibleToPaymentsServices(operation)
        
        case .mobileConnection:
            return try await paymentsProcessOperationResetVisibleMobileConnection(operation)

        case .fssp:
            return try await paymentsProcessOperationResetVisibleTaxesFSSP(operation)
            
        case .avtodor:
            return try await paymentsProcessOperationResetVisibleAvtodor(operation)
            
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
            return try paymentsStepFSSP(operation, for: stepIndex)
            
        case .sfp:
            return try await paymentsStepSFP(operation, for: stepIndex)
        
        case .requisites:
            return try await paymentsStepRequisites(operation, for: stepIndex)
            
        case .abroad:
            return try await paymentsStepDirect(operation, for: stepIndex)
            
        case .c2b:
            return try await paymentsStepC2B(operation, for: stepIndex)
            
        case .toAnotherCard:
            return try await paymentsLocalStepToAnotherCard(operation, for: stepIndex)

        case .mobileConnection:
            return try await paymentsProcessLocalStepMobileConnection(operation, for: stepIndex)
            
        case .internetTV, .utility, .transport:
            return try await paymentsProcessLocalStepServices(operation, for: stepIndex)
            
        case .avtodor:
            return try await paymentsProcessLocalStepAvtodor(
                parameters: operation.parameters,
                for: stepIndex
            )

        case .gibdd:
            return try await paymentsProcessLocalStepGibdd(
                parameters: operation.parameters,
                for: stepIndex
            )

        case .change:
            return try await paymentsStepChangePayment(operation, for: stepIndex)

        case .return:
            return try await paymentsStepReturnPayment(operation, for: stepIndex)
        }
    }
    
    func paymentsProcessRemoteStep(operation: Payments.Operation, response: TransferResponseData) async throws -> Payments.Operation.Step {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Remote step with response: \(response) requested for operation: \(operation.shortDescription)")
        
        switch response {
        case let anywayResponse as TransferAnywayResponseData:
            
            switch operation.transferType {
            case .anyway:
                
                return try await step(for: operation, with: anywayResponse)
                
            case .avtodor:
                
                return try await step(for: operation, with: anywayResponse)
                
            case .gibdd:
                
                return try await paymentsProcessRemoteGibdd(
                    operation,
                    response: anywayResponse
                )

            case .mobileConnection:
                
                return try await paymentsProcessRemoteStepMobileConnection(
                    operation,
                    response: anywayResponse
                )
                
            case .internetTV, .utility, .transport:
                
                guard !anywayResponse.finalStep else {
                    
                    return try await paymentsProcessRemoteStepServices(operation: operation, response: response)
                }
                
                let next = try await paymentsTransferPaymentsServicesStepParameters(operation, response: anywayResponse)
                let duplicates = next.map(\.parameter).filter { operation.parametersIds.contains($0.id) }
                if !duplicates.isEmpty {
                    
                    LoggerAgent.shared.log(level: .error, category: .payments, message: "Anyway transfer response duplicates detected end removed: \(duplicates) from operation: \(operation.shortDescription)")
                }
                
                // next parameters without duplicates
                let nextParameters = next.filter { !operation.parametersIds.contains($0.id) }
                
                let visible = try paymentsServicesStepVisible(operation, nextStepParameters: nextParameters, operationParameters: operation.parameters, response: anywayResponse)
                let stepStage = try paymentsServicesStepStage(operation, response: anywayResponse)
                let excludingParameters = try paymentsServicesStepExcludingParameters(response: anywayResponse)
                let required = try paymentsServicesStepRequired(
                    operation,
                    visible: visible,
                    nextStepParameters: nextParameters,
                    operationParameters: operation.parameters,
                    excludingParameters: excludingParameters)
                
                return Payments.Operation.Step(
                    parameters: nextParameters,
                    front: .init(visible: visible, isCompleted: false),
                    back: .init(stage: stepStage, required: required, processed: nil))

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
                
            case .abroad:
                let next = try await paymentsTransferAbroadStepParameters(operation, response: anywayResponse)
                
                if anywayResponse.finalStep == true {
                    return try await paymentsProcessRemoteStepAbroad(operation: operation, response: response)
                }
                let duplicates = next.map({ $0.parameter }).filter({ operation.parametersIds.contains($0.id) })
                if duplicates.count > 0 {
                    LoggerAgent.shared.log(level: .error, category: .payments, message: "Anyway transfer response duplicates detected end removed: \(duplicates) from operation: \(operation.shortDescription)")
                }
                
                // next parameters without duplicates
                let nextParameters = next.filter({ operation.parametersIds.contains($0.id) == false })
                
                let visible = try paymentsTransferAnywayStepVisible(
                    nextStepParametersIDs: nextParameters.map(\.id),
                    operationParametersIDs: operation.parameters.map(\.id),
                    needSum: anywayResponse.needSum
                )
                let stepStage = try paymentsTransferAnywayStepStage(operation, isFinalStep: anywayResponse.finalStep)
                let restricted: [Payments.Parameter.ID] = ["bSurName", "bIDnumber", "CURR"]
                let required = try paymentsTransferAnywayStepRequired(operation, visible: visible, nextStepParameters: nextParameters, operationParameters: operation.parameters, restrictedParameters: restricted)
                
                return Payments.Operation.Step(parameters: nextParameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: stepStage, required: required, processed: nil))
            
            default:
                throw Payments.Error.unsupported
            }

        default:
            switch operation.service {
            case .sfp:
                // Fora client payment first step response
                return try await paymentsProcessRemoteStepSFP(operation: operation, response: response)
            
            case .requisites:
                return try await paymentsProcessRemoteStepRequisits(operation: operation, response: response)

            case .toAnotherCard:
                return try await paymentsProcessRemoteStepToAnotherCard(operation: operation, response: response)
                
            case .abroad:
                return try await paymentsProcessRemoteStepAbroad(operation: operation, response: response)

            default:
                throw Payments.Error.unsupported
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Create next step for operation using response.
    func step(
        for operation: Payments.Operation,
        with response: TransferAnywayResponseData
    ) async throws -> Payments.Operation.Step {

        var nextParameters = try await uniqueNextParameters(
            for: operation,
            with: response
        )
        
        if response.scenario == .suspect {
            
            nextParameters.append(Payments.ParameterInfo(
                .init(id: Payments.Parameter.Identifier.sfpAntifraud.rawValue, value: "SUSPECT"),
                icon: .image(.parameterDocument),
                title: "Antifraud"
            ))
        }
        
        return try step(
            for: operation,
            withNextParameters: nextParameters,
            response: response
        )
    }
    
    /// Return next step parameters without duplication.
    func uniqueNextParameters(
        for operation: Payments.Operation,
        with response: TransferAnywayResponseData
    ) async throws -> [PaymentsParameterRepresentable] {
        
        let next = try await paymentsTransferAnywayStepParameters(operation, response: response)
        
        let duplicates = next
            .map { $0.parameter }
            .filter { operation.parametersIds.contains($0.id) }
        
        if duplicates.count > 0 {
            
            LoggerAgent.shared.log(level: .error, category: .payments, message: "Anyway transfer response duplicates detected end removed: \(duplicates) from operation: \(operation.shortDescription)")
        }
        
        // next parameters without duplicates
        let nextParameters = next.filter {
            
            !operation.parametersIds.contains($0.id)
        }
        
        return nextParameters
    }
    
    /// Create next step for operation using next step parameters and response.
    func step(
        for operation: Payments.Operation,
        withNextParameters nextParameters: [PaymentsParameterRepresentable],
        restrictedParameters: [Payments.Parameter.ID] = [],
        response: TransferAnywayResponseData
    ) throws -> Payments.Operation.Step {
        
        let visible = try paymentsTransferAnywayStepVisible(
            nextStepParametersIDs: nextParameters.map(\.id),
            operationParametersIDs: operation.parameters.map(\.id),
            needSum: response.needSum
        )
        let stepStage = try paymentsTransferAnywayStepStage(
            operation,
            isFinalStep: response.finalStep
        )
        let required = try paymentsTransferStepRequired(
            operation,
            visible: visible,
            nextStepParameters: nextParameters,
            operationParameters: operation.parameters,
            restrictedParameters: restrictedParameters
        )
        
        return Payments.Operation.Step(
            parameters: nextParameters,
            front: .init(
                visible: visible,
                isCompleted: false
            ),
            back: .init(
                stage: stepStage,
                required: required,
                processed: nil
            )
        )
    }
}

//MARK: - Parameter Reducers

extension Model {
    
    /// updates operation parameters with data in operation source
    func paymentsProcessSourceReducer(
        service: Payments.Service,
        source: Payments.Operation.Source,
        parameterId: Payments.Parameter.ID
    ) -> Payments.Parameter.Value? {

        switch source {
        case let .mock(mock):
            return mock.parameters.first(where: { $0.id == parameterId })?.value
            
        case let .sfp(phone: phone, bankId: bankId):
            return paymentsProcessSourceReducerSFP(
                phone: phone,
                bankId: bankId,
                parameterId: parameterId
            )
            
        case let .requisites(qrCode: qrCode):
            return paymentsProcessSourceReducerRequisites(qrCode: qrCode, parameterId: parameterId)
            
        case let .direct(phone: phone, countryId: country, serviceData: serviceData):
            return paymentsProcessSourceReducerCountry(countryId: country, phone: phone, serviceData: serviceData, parameterId: parameterId)
        
        case .template(let templateId):
            
            guard let template = self.paymentTemplates.value.first(where: { $0.id == templateId }) else {
               return nil
            }
            
            return paymentsTemplateParameterValue(
                service: service,
                parameterId: parameterId,
                template: template
            )
            
        case let .latestPayment(latestPaymentId):
            
            guard let latestPayment = self.latestPayments.value.first(where: { $0.id == latestPaymentId }) else {
                return nil
            }
           
            return latestsPaymentsParameterValue(
                parameterId: parameterId,
                latestPayment: latestPayment
            )
            
        default:
            return nil
        }
    }
    
    /// update dependend on each other parameters
    func paymentsProcessDependencyReducer(
        operation: Payments.Operation,
        parameterId: Payments.Parameter.ID,
        parameters: [PaymentsParameterRepresentable]
    ) -> PaymentsParameterRepresentable? {
        
        switch operation.service {
        case .fssp:
            return paymentsProcessDependencyReducerFSSP(parameterId: parameterId, parameters: parameters)
            
        case .sfp:
            return paymentsProcessDependencyReducerSFP(
                operation: operation,
                parameterId: parameterId,
                parameters: parameters
            )
        
        case .requisites:
            return paymentsProcessDependencyReducerRequisits(parameterId: parameterId, parameters: parameters)
            
        case .c2b:
            return paymentsProcessDependencyReducerC2B(parameterId: parameterId, parameters: parameters)

        case .abroad:
            return paymentsProcessDependencyReducerAbroad(
                parameterId: parameterId,
                parameters: parameters,
                operation: operation
            )
            
        case .internetTV, .utility, .transport:
            return paymentsProcessDependencyReducerPaymentsServices(parameterId: parameterId, parameters: parameters)
            
        case .toAnotherCard:
            return paymentsProcessDependencyReducerToAnotherCard(parameterId: parameterId, parameters: parameters)

        default:
            switch parameterId {
            case Payments.Parameter.Identifier.amount.rawValue:
                
                let productParameterId = Payments.Parameter.Identifier.product.rawValue
                guard let amountParameter = parameters.first(where: { $0.id == parameterId }) as? Payments.ParameterAmount,
                      let productParameter = parameters.first(where: { $0.id == productParameterId}) as? Payments.ParameterProduct,
                      let productId = productParameter.productId,
                      let product = product(productId: productId),
                      let currencySymbol = dictionaryCurrencySymbol(for: product.currency) else {
                    
                    return nil
                }
                
                //FIXME: check if currency & validator changed before return
                // see: paymentsProcessDependencyReducerSFP
                
                return Payments.ParameterAmount(value: amountParameter.value, title: "Сумма", currencySymbol: currencySymbol, validator: .init(minAmount: 0.01, maxAmount: product.balance))
                
            default:
                return nil
            }
        }
    }
    
    /// updates current step back stage on data in parameters
    func paymentsProcessCurrentStepStageReducer(service: Payments.Service, parameters: [PaymentsParameterRepresentable], stepIndex: Int, stepStage: Payments.Operation.Stage) -> Payments.Operation.Stage? {
        
        switch service {
        case .sfp:
            return paymentsProcessCurrentStepStageReducerSFP(service: service, parameters: parameters, stepIndex: stepIndex, stepStage: stepStage)
            
        default:
            return nil
        }
    }
}

//MARK: - Remote Process

extension Model {
    
    @discardableResult
    func paymentsProcessRemoteStart(_ process: [Payments.Parameter], _ operation: Payments.Operation) async throws -> TransferResponseData {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Remote: START: parameters \(process) requested for operation: \(operation.shortDescription)")
        
        switch operation.transferType {
        case .anyway, .gibdd:
            return try await paymentsTransferAnywayProcess(parameters: operation.parameters, process: process, isNewPayment: true)
            
        case .avtodor:
            return try await paymentsProcessRemoteStepAvtodor(parameters: operation.parameters, process: process, isNewPayment: true)
            
        case .sfp:
            return try await paymentsTransferSFPProcess(parameters: operation.parameters, process: process)
        
        case .requisites:
            return try await paymentsTransferRequisitesProcess(parameters: operation.parameters, process: process)
            
        case .abroad:
            return try await paymentsTransferAnywayAbroadProcess(parameters: operation.parameters, process: process, isNewPayment: true)
            
        case .toAnotherCard:
            return try await paymentsTransferToAnotherProcess(parameters: operation.parameters, process: process)
               
        case .mobileConnection:
            return try await paymentsTransferMobileConnectionProcess(parameters: operation.parameters, process: process)
            
        case .internetTV, .utility, .transport:
            return try await paymentsTransferPaymentsServicesProcess(parameters: operation.parameters, process: process, isNewPayment: true)

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
        
        case .avtodor:
            return try await paymentsProcessRemoteStepAvtodor(parameters: operation.parameters, process: process, isNewPayment: false)
        
        case .gibdd:
            return try await paymentsProcessRemoteNextGibdd(parameters: operation.parameters, process: process, isNewPayment: false)
        
        case .abroad:
            return try await paymentsTransferAnywayAbroadProcess(parameters: operation.parameters, process: process, isNewPayment: false)
            
        case .internetTV, .utility, .transport:
            return try await paymentsTransferPaymentsServicesProcess(parameters: operation.parameters, process: process, isNewPayment: false)


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
        
        switch operation.service {
        case .mobileConnection:
            return try await paymentsProcessRemoteMobileConnectionComplete(
                code: codeValue,
                operation: operation
            )
    
        case .abroad:
            return try await paymentsProcessAbroadComplete(
                code: codeValue,
                operation: operation
            )
    
        case .internetTV, .utility, .transport:
            return try await paymentsProcessRemoteServicesComplete(
                code: codeValue,
                operation: operation
            )
            
        default:
            let response = try await paymentsTransferComplete(code: codeValue)
            let success = try Payments.Success(with: response, operation: operation, amountFormatter: amountFormatted(amount:productID:style:))
            
            return success
        }
    }
    
    func paymentsProcessRemoteComplete(_ process: [Payments.Parameter], _ operation: Payments.Operation) async throws -> Payments.Success {
        
        LoggerAgent.shared.log(level: .debug, category: .payments, message: "Remote: COMPLETE: parameters \(process) requested for operation: \(operation.shortDescription)")
        
        switch operation.service {
        case .sfp:
            let response = try await paymentsTransferSFPProcessFora(parameters: operation.parameters, process: process)
            let success = try Payments.Success(with: response, operation: operation, amountFormatter: amountFormatted(amount:productID:style:))
            return success
            
        case .c2b:
            return try await paymentsC2BComplete(operation: operation)
            
        case .return:
            return try await paymentsReturnAbroad(operation: operation)
            
        case .change:
            return try await paymentsChangeAbroad(operation: operation)

        default:
            throw Payments.Error.unsupported
        }
    }
}

//MARK: - Parameter Representable

extension Model {

    func paymentsParameterRepresentable(_ operation: Payments.Operation, parameterData: ParameterData) async throws -> PaymentsParameterRepresentable? {
        
        switch operation.service {
        case .fns, .fms, .fssp:
            return try paymentsParameterRepresentableTaxes(operation: operation, parameterData: parameterData)
        
        case .abroad:
            return try await paymentsParameterRepresentableCountries(operation: operation, parameterData: parameterData)

        case .utility, .transport:
            return try await paymentsParameterRepresentablePaymentsServices(parameterData: parameterData)

        default:
            return try paymentsParameterRepresentable(parameterData: parameterData)
        }
    }
    
    func paymentsParameterRepresentable(parameterData: ParameterData) throws -> PaymentsParameterRepresentable {
        
        switch parameterData.view {
        case .select:
            guard let options = parameterData.options(style: .general)
            else {
                return Payments.ParameterSelect(
                    .init(id: parameterData.id, value: parameterData.value),
                    icon: .image(parameterData.iconData ?? .iconPlaceholder),
                    title: parameterData.title,
                    placeholder: "Выберете категорию",
                    options: [])
            }
            
            let selectOptions = options.map({ Payments.ParameterSelect.Option(id: $0.id, name: $0.name, subname: $0.subtitle) })
            
            return Payments.ParameterSelect(
                .init(id: parameterData.id,
                      value: parameterData.value),
                icon: .image(parameterData.iconData ?? .iconPlaceholder),
                title: parameterData.title,
                placeholder: "Выберете категорию",
                options: selectOptions)
            
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
            return Payments.ParameterInput(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterDocument,
                title: parameterData.title,
                validator: parameterData.validator)
            
        case .info:
            return Payments.ParameterInfo(
                .init(id: parameterData.id, value: parameterData.value),
                icon: .image(parameterData.iconData ?? .parameterLocation),
                title: parameterData.title)
        }
    }
    
    func paymentsParameterRepresentable(
        _ operation: Payments.Operation,
        additionalData: TransferAnywayResponseData.AdditionalData,
        group: Payments.Parameter.Group
    ) throws -> PaymentsParameterRepresentable? {
        
        switch operation.service {
        case .sfp:
            return try paymentsParameterRepresentableSFP(operation, additionalData: additionalData)
            
        case .requisites, .mobileConnection, .fms, .fns, .fssp, .internetTV, .toAnotherCard, .utility, .transport:
            return try paymentsParameterRepresentableSFP(operation, additionalData: additionalData)

        default:

            return Payments.ParameterInfo(
                .init(id: additionalData.fieldName, value: additionalData.fieldValue),
                icon: .image(additionalData.iconData ?? .parameterDocument),
                title: additionalData.fieldTitle ?? "", group: group) //FIXME: fix "" create case for .contact, .direct
        }
    }
    
    func paymentsParameterRepresentableSelectServiceOption(
        for service: Payments.Service,
        with operators: [OperatorGroupData.OperatorData]
    ) -> Payments.ParameterSelectService.Option? {
        
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
    
    func latestsPaymentsParameterValue(
        parameterId: Payments.Parameter.ID,
        latestPayment: LatestPaymentData
    ) -> Payments.Parameter.Value? {
        
        switch parameterId {
                
            case Payments.Operation.Parameter.Identifier.amount.rawValue:
                switch latestPayment {
                    case let latestPayment as PaymentGeneralData:
                        return latestPayment.amount
                        
                    case let latestPayment as PaymentServiceData:
                        return latestPayment.amount.description
                        
                    default:
                        return nil
                }
                
            default:
            switch latestPayment.type {
                
            case .phone:
                guard let paymentData = latestPayment as? PaymentGeneralData else {
                    return nil
                }
                
                let phoneNumber = PhoneNumberWrapper().format(paymentData.phoneNumber).digits
                let bankId = paymentData.bankId
                self.action.send(ModelAction.LatestPayments.BanksList.Request(
                    prePayment: true,
                    phone: phoneNumber.addCodeRuIfNeeded()
                ))
                
                return paymentsProcessSourceReducerSFP(
                    phone: phoneNumber,
                    bankId: bankId,
                    parameterId: parameterId
                )
                
            case .mobile:
                guard let latestPayment = latestPayment as? PaymentServiceData else {
                    return nil
                }
                
                let puref = latestPayment.puref
                
                switch parameterId {
                case Payments.Parameter.Identifier.mobileConnectionPhone.rawValue:
                    let operatorId = self.dictionaryAnywayOperator(for: puref)?.operatorID
                    guard let value = latestPayment.additionalList.first(where: { $0.fieldName == operatorId })?.mobilePhone else {
                        return nil
                    }
                    
                    return value
                    
                default:
                    return nil
                }
                
            case .internet,
                 .service,
                 .outside,
                 .transport:
                
                guard let paymentData = latestPayment  as? PaymentServiceData else {
                    return nil
                }
                
                let value = paymentData.additionalList.first(where: { $0.fieldName == parameterId })?.fieldValue
                
                return value
                
            default:
                return nil
            }
        }
    }
    
    func paymentsTemplateParameterValue(
        service: Payments.Service,
        parameterId: Payments.Parameter.ID,
        template: PaymentTemplateData
    ) -> Payments.Parameter.Value? {
     
        switch parameterId {
        case Payments.Parameter.Identifier.sfpMessage.rawValue:
            if let parameterList = template.parameterList as? [TransferGeneralData] {
                
                return parameterList.last?.comment
            }
            
            return nil
            
        case Payments.Parameter.Identifier.amount.rawValue:
            
            if let amount = template.amount?.description {
                return amount
                
            } else if let parameterList = template.parameterList as? [TransferAnywayData] {
                
                return parameterList.compactMap(\.amountDouble).first?.description
            }
            
            return nil
            
        case Payments.Parameter.Identifier.product.rawValue:
            return template.parameterList.last?.payer?.productIdDescription
            
        default:
            switch service {
            case .abroad, .sfp, .fms, .fns, .fssp, .utility, .internetTV, .transport:
                
                switch template.parameterList {
                case let payload as [TransferAnywayData]:
                    
                    switch parameterId {
                    case Payments.Operation.Parameter.Identifier.sfpPhone.rawValue:
                        return payload.last?.additional.sfpPhone
                        
                    default:
                        return payload.last?.additional.first(where: { $0.fieldname == parameterId })?.fieldvalue
                    }
                    
                case let payload as [TransferGeneralData]:
                    switch parameterId {
                    case Payments.Operation.Parameter.Identifier.sfpPhone.rawValue:
                        return template.phoneNumber
                        
                    case Payments.Operation.Parameter.Identifier.sfpBank.rawValue:
                        return template.foraBankId
                        
                    case Payments.Operation.Parameter.Identifier.sfpMessage.rawValue:
                        return payload.last?.comment
                        
                    default:
                        return nil
                    }
                    
                default:
                    return nil
                }
                
            case .requisites:
                return paymentsProcessSourceTemplateReducerRequisites(templateData: template,
                                                                      parameterId: parameterId)
            case .mobileConnection:
                guard let anywayDataList = template.parameterList as? [TransferAnywayData],
                      let puref = anywayDataList.last?.puref else {
                    return nil
                }
                
                switch parameterId {
                case Payments.Parameter.Identifier.mobileConnectionPhone.rawValue:
                    let operatorId = self.dictionaryAnywayOperator(for: puref)?.operatorID
                    
                    if let phone = anywayDataList.last?.additional.first(where: { $0.fieldname == operatorId })?.fieldvalue {
                        
                        return PhoneNumberKitFormater().format(phone.digits.addCodeRuIfNeeded())
                    }
                    
                    return nil
                    
                default:
                    return nil
                }
            case .toAnotherCard:
                
                switch parameterId {
                case Payments.Parameter.Identifier.productTemplate.rawValue:
                    
                    guard let parameterList = template.parameterList as? [TransferGeneralData] else {
                        return nil
                    }
                    
                    var productId: String?
                    
                    switch parameterList.lastPayeeProductId {
                    case let .some(payeeProductId):
                        productId = self.productTemplates.value.first(where: { $0.id == payeeProductId })?.id.description
                        
                    default:
                        
                        if let suffixCardNumber = parameterList.last?.suffixCardNumber {
                            
                            productId = self.productTemplates.value.first(where: { $0.numberMaskSuffix == suffixCardNumber })?.id.description
                            
                        }
                    }
                    
                    guard let productId else {
                        return nil
                    }
                    
                    let templateProductId = Payments.ParameterProductTemplate.ParametrValue.templateId(productId).stringValue
                    
                    return templateProductId
                    
                default:
                    return nil
                }
                
            default:
                return nil
            }
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
    
    func paymentsParameterValue(
        _ parameters: [PaymentsParameterRepresentable],
        id: Payments.Parameter.ID
    ) -> Payments.Parameter.Value {
        
        return parameters.first(where: { $0.id == id })?.value
    }
    
    func paymentsProduct(from parameters: [PaymentsParameterRepresentable]) -> ProductData? {
        
        let productParameterId = Payments.Parameter.Identifier.product.rawValue
        guard let productParameter = parameters.first(where: { $0.id == productParameterId}) as? Payments.ParameterProduct,
              let productId = productParameter.productId else {
            return nil
        }
        
        return product(productId: productId)
    }
    
    func paymentsAmountFormatted(amount: Double, parameters: [PaymentsParameterRepresentable]) -> String? {
        
        guard let product = paymentsProduct(from: parameters),
        let amountFormatted = amountFormatted(amount: amount, currencyCode: product.currency, style: .normal) else {
            return nil
        }
        
        return amountFormatted
    }
    
    func paymentsMock(for service: Payments.Service) -> Payments.Mock? {
        
        switch service {
        case .fns: return paymentsMockFNS()  
        case .fms: return paymentsMockFMS()  
        case .fssp: return paymentsMockFSSP()
        case .sfp: return Model.paymentsMockSFP()
            
        default:
            return nil
        }
    }
    
    func paymentsIsAutoContinueRequired(operation: Payments.Operation, updated: Payments.Parameter.ID) -> Bool {
        
        guard let parameter = operation.parameters.first(where: { $0.id == updated }) else {
            return false
        }
        
        switch parameter {
        case _ as Payments.ParameterProduct,
             _ as Payments.ParameterSelect,
             _ as Payments.ParameterSelectBank,
             _ as Payments.ParameterSelectCountry,
             _ as Payments.ParameterSelectService,
             _ as Payments.ParameterSelectDropDownList,
             _ as Payments.ParameterCheck,
             _ as Payments.ParameterSelectSimple,
             _ as Payments.ParameterSelectSwitch:
            return true
            
        default:
            return false
        }
    }
    
    func paymentsIsRollbackRequired(operation: Payments.Operation, updated: Payments.Parameter.ID) -> Int? {
        
        guard let nextAction = try? operation.nextAction() else {
            return nil
        }
        
        switch nextAction {
        case let .rollback(step):
            switch updated {
            case Payments.Parameter.Identifier.amount.rawValue:
                return nil
                
            default:
                return step
            }
            
        default:
            return nil
        }
    }
     
    func antifraudStatus() -> [String] {
        ["F", "G1", "S", "SUSPECT"]
    }
    
    func paymentsAntifraudData(
        for operation: Payments.Operation
    ) -> Payments.AntifraudData? {
        
        let antifraudParameterId = Payments.Parameter.Identifier.sfpAntifraud.rawValue
        let antifraudParameter = paymentsParameterValue(
            operation.parameters,
            id: antifraudParameterId
        )
        
        guard antifraudStatus().contains(where: { $0 == antifraudParameter }) || (operation.service == .sfp && antifraudParameter == nil) else {
            return nil
        }
        
        var name: String?
        var phone: String?
        
        switch operation.service {
        case .sfp:
            
            let recipientParameterId = Payments.Parameter.Identifier.sftRecipient.rawValue
            let phoneParameterId = Payments.Parameter.Identifier.sfpPhone.rawValue
            let amountParameterId = Payments.Parameter.Identifier.sfpAmount.rawValue
            
            guard let recipientValue = paymentsParameterValue(operation.parameters, id: recipientParameterId),
                  let phoneValue = paymentsParameterValue(operation.parameters, id: phoneParameterId),
                  let amountValue = paymentsParameterValue(operation.parameters, id: amountParameterId)
            else {
                return nil
            }
            
            let formatPhone = PhoneNumberKitFormater().format(phoneValue.digits)
            return .init(
                payeeName: recipientValue,
                phone: formatPhone,
                amount: "- \(amountValue)"
            )
            
        case .requisites:
            if let newName = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.requisitsName.rawValue
            ) {
                name = newName
            } else if let newName = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.requisitsCompanyName.rawValue
            ) {
                name = newName
            }
            
            let amount = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.requisitsAmount.rawValue
            )
            
            return .init(
                payeeName: name ?? "",
                phone: phone ?? "",
                amount: "- \(amount ?? "")"
            )
            
        case .abroad:
            if let newName = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.countryPayee.rawValue
            ) {
                name = newName
            }
            
            let amount = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.amount.rawValue
            )
            
            let numberCard = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.p1.rawValue
            )
            
            let value = numberCard?.masked(mask: StringValueMask.card)
            
            let amountFormatted = amountWithParameterProductCurrency(
                operation: operation,
                amount: amount
            )
            
            return .init(
                payeeName: value ?? name ?? "",
                phone: phone ?? "",
                amount: "- \(amountFormatted ?? amount ?? "")"
            )
            
        case  .fms, .fns, .fssp, .gibdd, .transport, .utility, .avtodor, .internetTV:
            
            if let newName = operation.parameters.first(
                where: { $0.id == Payments.Parameter.Identifier.header.rawValue
                }) as? Payments.ParameterHeader {
                name = newName.title
            }
            
            let amount = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.amount.rawValue
            )
            
            let paymentsServiceAmount = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.paymentsServiceAmount.rawValue
            )
            
            return .init(
                payeeName: name ?? "",
                phone: phone ?? "",
                amount: "- \(amount ?? paymentsServiceAmount ?? "") ₽"
            )
            
        case .mobileConnection:
            if let newPhone = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.mobileConnectionPhone.rawValue
            ) {
                phone = newPhone
            }
            
            let amount = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.mobileConnectionAmount.rawValue
            )
            
            let formatPhone = PhoneNumberKitFormater().format(phone?.digits.addCodeRuIfNeeded() ?? "")
            return .init(
                payeeName: name ?? "",
                phone: formatPhone,
                amount: "- \(amount ?? "")"
            )
            
        case .toAnotherCard:
            if let newName = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.productTemplate.rawValue
            ) {
                name = newName
            }
                    
            let productNumberMask = name?.dropFirst(2) ?? ""
            let maskCardNumber = String(productNumberMask.prefix(4)) + " **** **** " + String(productNumberMask.suffix(4))
            
            let amount = paymentsParameterValue(
                operation.parameters,
                id: Payments.Parameter.Identifier.amount.rawValue
            )

            let amountFormatted = amountWithParameterProductCurrency(
                operation: operation,
                amount: amount
            )
            
            return .init(
                payeeName: maskCardNumber,
                phone: phone ?? "",
                amount: "- \(amountFormatted ?? amount ?? "")"
            )
            
        default:
            return nil
        }
    }
    
    func amountWithParameterProductCurrency(
        operation: Payments.Operation,
        amount: String?
    ) -> String? {
        
        if let product = paymentsParameterValue(
            operation.parameters,
            id: Payments.Parameter.Identifier.product.rawValue
        ), let amount = Double(amount ?? "") {
            
            let currency = self.allProducts.first(where: { $0.id == Int(product) })?.currency
            let amountFormatted = amountFormatted(
                amount: amount,
                currencyCode: currency,
                style: .fraction
            )
            
            return amountFormatted
        }
        
        return nil
    }
        
    func isSingleService(_ puref: String) async throws -> Bool {
        
        LoggerAgent.shared.log(category: .model, message: "isSingleService")
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let command = ServerCommands.TransferController.IsSingleService(token: token, payload: .init(puref: puref))
        
        LoggerAgent.shared.log(category: .model, message: "execute command: \(command)")
        return try await withCheckedThrowingContinuation({ continuation in
            
            serverAgent.executeCommand(command: command) { result in
                switch result{
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        
                        guard let data = response.data else {
                            continuation.resume(with: .failure(Payments.Error.isSingleService.emptyData(message: response.errorMessage)))
                            return
                        }
                        
                        continuation.resume(returning: (data))
                        
                    default:
                        continuation.resume(with: .failure(Payments.Error.isSingleService.statusError(status: response.statusCode, message: response.errorMessage)))
                    }
                case .failure(let error):
                    continuation.resume(with: .failure(Payments.Error.isSingleService.serverCommandError(error: error.localizedDescription)))
                }
            }
        })
    }
}
