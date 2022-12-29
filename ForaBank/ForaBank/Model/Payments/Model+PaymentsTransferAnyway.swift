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
    
    func paymentsTransferAnywayStepParameters(_ operation: Payments.Operation, response: TransferAnywayResponseData) throws -> [PaymentsParameterRepresentable] {
        
        var result = [PaymentsParameterRepresentable]()
        
        for additionalData in response.additionalList {
            
            guard let parameter = try paymentsParameterRepresentable(operation, adittionalData: additionalData) else {
                
                continue
            }
            
            result.append(parameter)
        }
        
        for parameterData in response.parameterListForNextStep {
            
            if let parameter = try paymentsParameterRepresentable(operation, parameterData: parameterData) {
                
                result.append(parameter)
                
            } else {
                
                let parameter = try paymentsParameterRepresentable(parameterData: parameterData)
                result.append(parameter)
            }
        }
        
        if response.needSum == true {
            
            // amount
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            guard let productParameter = operation.parameters.first(where: { $0.id == productParameterId}) as? Payments.ParameterProduct,
                  let productId = productParameter.productId,
                  let product = product(productId: productId),
                  let currencySymbol = dictionaryCurrencySymbol(for: product.currency) else {
                throw Payments.Error.missingParameter(productParameterId)
            }
            
            let amountParameter = Payments.ParameterAmount(value: "0", title: "Сумма", currencySymbol: currencySymbol, validator: .init(minAmount: 10, maxAmount: product.balance))
            result.append(amountParameter)
        }
        
        if response.finalStep == true {
            
            result.append(Payments.ParameterCode.regular)
        }
        
        return result
    }
    
    func paymentsTransferAnywayStepVisible(_ operation: Payments.Operation, nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable], response: TransferAnywayResponseData) throws -> [Payments.Parameter.ID] {
        
        var result = [Payments.Parameter.ID]()
        
        let nexStepParametersIds = nextStepParameters.map{ $0.id }
        result.append(contentsOf: nexStepParametersIds)
        
        if response.needSum == true {
            
            let operationParametersIds = operationParameters.map{ $0.id }
            let allParametersIds = operationParametersIds + nexStepParametersIds
            
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            guard allParametersIds.contains(productParameterId) else {
                throw Payments.Error.missingParameter(productParameterId)
            }
            
            result.append(Payments.Parameter.Identifier.product.rawValue)
        }

        return result
    }
    
    func paymentsTransferAnywayStepStage(_ operation: Payments.Operation, response: TransferAnywayResponseData) throws -> Payments.Operation.Stage {
        
        if response.finalStep == true {
            
            return .remote(.confirm)
            
        } else {
            
            let operationStepsStages = operation.steps.map{ $0.back.stage }
            if operationStepsStages.count > 0 {
                
                return .remote(.next)
                
            } else {
                
                return .remote(.start)
            }
        }
    }
    
    func paymentsTransferAnywayStepRequired(_ operation: Payments.Operation, visible: [Payments.Parameter.ID], nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable]) throws -> [Payments.Parameter.ID] {
        
        try paymentsTransferStepRequired(operation, visible: visible, nextStepParameters: nextStepParameters, operationParameters: operationParameters)
    }
}
