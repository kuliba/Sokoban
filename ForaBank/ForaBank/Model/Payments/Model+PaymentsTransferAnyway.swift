//
//  Model+PaymentsTransferAnyway.swift
//  ForaBank
//
//  Created by Max Gribov on 21.10.2022.
//

import Foundation

//MARK: - Request

extension Model {
    
    func paymentsTransferAnywayProcess(parameters: [PaymentsParameterRepresentable], process: [Payments.Parameter], isNewPayment: Bool) async throws -> TransferAnywayResponseData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let puref = try paymentsTransferAnywayPuref(parameters)
        let payer = try paymentsTransferAnywayPayer(parameters)
        let amount = try paymentsTransferAnywayAmount(parameters)
        let currency = try paymentsTransferAnywayCurrency(parameters)
        let comment = try paymentsTransferAnywayComment(parameters)
        let additional = try paymentsTransferAnywayAdditional(process)
        
        let command = ServerCommands.TransferController.CreateAnywayTransfer(token: token, isNewPayment: isNewPayment, payload: .init(amount: amount, check: false, comment: comment, currencyAmount: currency, payer: payer, additional: additional, puref: puref))
        
        return try await serverAgent.executeCommand(command: command)
    }
}

//MARK: Request Parameters

extension Model {
    
    func paymentsTransferAnywayPuref(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        try paymentsTransferPuref(parameters)
    }
    
    func paymentsTransferAnywayPayer(_ parameters: [PaymentsParameterRepresentable]) throws -> TransferData.Payer {
        
        try paymentsTransferPayer(parameters)
    }
    
    func paymentsTransferAnywayAmount(_ parameters: [PaymentsParameterRepresentable]) throws -> Double? {
        
        try paymentsTransferAmount(parameters)
    }
    
    func paymentsTransferAnywayCurrency(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        try paymentsTransferCurrency(parameters)
    }
    
    func paymentsTransferAnywayComment(_ parameters: [PaymentsParameterRepresentable]) throws -> String? {
        
        try paymentsTransferComment(parameters)
    }
    
    func paymentsTransferAnywayAdditional(_ parameters: [Payments.Parameter]) throws -> [TransferAnywayData.Additional] {
        
        var additional = [TransferAnywayData.Additional]()
        for (index, parameter) in parameters.enumerated() {
            
            guard let parameterValue = parameter.value else {
                continue
            }
            additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: parameterValue))
        }
        
        return additional
    }
}

//MARK: - Step

extension Model {
    
    //TODO: remove async in proceess of refartoring Abroad payments
    func paymentsTransferAnywayStepParameters(
        _ operation: Payments.Operation,
        response: TransferAnywayResponseData
    ) async throws -> [PaymentsParameterRepresentable] {
        
        var result = [PaymentsParameterRepresentable]()
        for parameterData in response.parameterListForNextStep {
            
            if let parameter = try await paymentsParameterRepresentable(operation, parameterData: parameterData) {
                
                result.append(parameter)
                
            }
        }
        
        let spoilerGroup = Payments.Parameter.Group(id: UUID().uuidString, type: .spoiler)
        for additionalData in response.additionalList {
            
            guard let parameter = try paymentsParameterRepresentable(operation, additionalData: additionalData, group: spoilerGroup) else {
                
                continue
            }
            
            result.append(parameter)
        }

        if response.needSum {
            
            // amount
            if let amountParameter = try? amountParameter(
                parameters: operation.parameters,
                parameterListForNextStep: response.parameterListForNextStep
            ) {
                result.append(amountParameter)
            }
        }
        
        if response.finalStep == true {
            
            result.append(Payments.ParameterCode.regular)
        }
        
        return result
    }
    
    // TODO: Add tests
    func amountParameter(
        parameters: [PaymentsParameterRepresentable],
        parameterListForNextStep: [ParameterData]
    ) throws -> Payments.ParameterAmount {
        
        let productParameterId = Payments.Parameter.Identifier.product.rawValue
        guard let productParameter = parameters.first(where: { $0.id == productParameterId }) as? Payments.ParameterProduct,
              let productId = productParameter.productId,
              let product = product(productId: productId),
              let currencySymbol = dictionaryCurrencySymbol(for: product.currency)
        else {
            throw Payments.Error.missingParameter(productParameterId)
        }
        
        return .init(
            value: nil,
            title: "Сумма",
            currencySymbol: currencySymbol,
            deliveryCurrency: parameterListForNextStep.deliveryCurrency,
            validator: .init(
                minAmount: 10,
                maxAmount: product.balance
            )
        )
    }
    
    func paymentsTransferAnywayStepVisible(
        nextStepParametersIDs: [Payments.Parameter.ID],
        operationParametersIDs: [Payments.Parameter.ID],
        needSum: Bool
    ) throws -> [Payments.Parameter.ID] {
        
        var result = nextStepParametersIDs
                
        if needSum {
            
            let allParametersIds = operationParametersIDs + nextStepParametersIDs
            
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            guard allParametersIds.contains(productParameterId)
            else {
                throw Payments.Error.missingParameter(productParameterId)
            }
            
            result.append(Payments.Parameter.Identifier.product.rawValue)
        }

        return result
    }
    
    func paymentsTransferAnywayStepStage(
        _ operation: Payments.Operation,
        isFinalStep: Bool
    ) throws -> Payments.Operation.Stage {
        
        if isFinalStep {
            
            return .remote(.confirm)
            
        } else {
            
            let stepsStages = operation.steps.map(\.back.stage)
       
            return stepsStages.isEmpty ? .remote(.start) : .remote(.next)
        }
    }
    
    func paymentsTransferAnywayStepRequired(_ operation: Payments.Operation, visible: [Payments.Parameter.ID], nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable], restrictedParameters: [Payments.Parameter.ID]) throws -> [Payments.Parameter.ID] {
        
        try paymentsTransferStepRequired(operation, visible: visible, nextStepParameters: nextStepParameters, operationParameters: operationParameters, restrictedParameters: restrictedParameters)
    }
}

extension Array where Element == ParameterData {
    
    typealias DeliveryCurrency = Payments.ParameterAmount.DeliveryCurrency
    
    var deliveryCurrency: DeliveryCurrency? {
        
        let currencyList = first(where: { $0.id == Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue })?
            .options(style: .currency)?
            .compactMap { Currency(description: $0.id) }
        
        return currencyList?
            .first
            .map {
                
                .init(selectedCurrency: $0, currenciesList: currencyList)
            }
    }
}
