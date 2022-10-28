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
    
    func paymentsTransferAnywayAmount(_ parameters: [PaymentsParameterRepresentable]) throws -> Double {
        
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
    
    func paymentsTransferAnywayStepParameters(service: Payments.Service, response: TransferAnywayResponseData) throws -> [PaymentsParameterRepresentable] {
        
        var result = [PaymentsParameterRepresentable]()
        
        for additionalData in response.additionalList {
            
            let parameter = try paymentsParameterRepresentable(service: service, adittionalData: additionalData)
            result.append(parameter)
        }
        
        for parameterData in response.parameterListForNextStep {
            
            if let parameter = try paymentsParameterRepresentable(service: service, parameterData: parameterData) {
                
                result.append(parameter)
                
            } else {
                
                let parameter = try paymentsParameterRepresentable(parameterData: parameterData)
                result.append(parameter)
            }
        }
        
        if response.finalStep == true {
            
            let codeParameter = Payments.ParameterInput(
                .init(id: Payments.Parameter.Identifier.code.rawValue, value: nil),
                icon: .parameterSMS,
                title: "Введите код из СМС", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
            result.append(codeParameter)
        }
        
        return result
    }
    
    func paymentsTransferAnywayStepVisible(service: Payments.Service, nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable], response: TransferAnywayResponseData) throws -> [Payments.Parameter.ID] {
        
        var result = [Payments.Parameter.ID]()
        
        let nexStepParametersIds = nextStepParameters.map{ $0.id }
        result.append(contentsOf: nexStepParametersIds)
        
        if response.needSum == true {
            
            let operationParametersIds = operationParameters.map{ $0.id }
            let allParametersIds = operationParametersIds + nexStepParametersIds
            
            guard allParametersIds.contains(Payments.Parameter.Identifier.product.rawValue) else {
                throw Payments.Error.missingProduct
            }
            
            result.append(Payments.Parameter.Identifier.product.rawValue)
            
            guard allParametersIds.contains(Payments.Parameter.Identifier.amount.rawValue) else {
                throw Payments.Error.missingAmount
            }
            
            result.append(Payments.Parameter.Identifier.amount.rawValue)
        }

        return result
    }
    
    func paymentsTransferAnywayStepStage(service: Payments.Service, operation: Payments.Operation, response: TransferAnywayResponseData) throws -> Payments.Operation.Stage {
        
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
    
    func paymentsTransferAnywayStepTerms(service: Payments.Service, visible: [Payments.Parameter.ID], nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable]) throws -> [Payments.Operation.Step.Term] {
        
        try paymentsTransferStepTerms(service: service, visible: visible, nextStepParameters: nextStepParameters, operationParameters: operationParameters)
    }
}
