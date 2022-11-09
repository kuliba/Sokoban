//
//  Model+PaymentsTransferSFP.swift
//  ForaBank
//
//  Created by Max Gribov on 09.11.2022.
//

import Foundation

//MARK: - Request

extension Model {
    
    func paymentsTransferSFPProcess(parameters: [PaymentsParameterRepresentable], process: [Payments.Parameter]) async throws -> TransferAnywayResponseData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let puref = try paymentsTransferSFPPuref(parameters)
        let payer = try paymentsTransferSFPPayer(parameters)
        let amount = try paymentsTransferSFPAmount(parameters)
        let currency = try paymentsTransferSFPCurrency(parameters)
        let comment = try paymentsTransferSFPComment(parameters)
        let additional = try paymentsTransferSFPAdditional(process)
        
        let command = ServerCommands.TransferController.CreateSFPTransfer(token: token, payload: .init(amount: amount, check: false, comment: comment, currencyAmount: currency, payer: payer, additional: additional, puref: puref))
        
        return try await serverAgent.executeCommand(command: command)
    }
}

//MARK: Request Parameters

extension Model {
    
    func paymentsTransferSFPPuref(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        try paymentsTransferPuref(parameters)
    }
    
    func paymentsTransferSFPPayer(_ parameters: [PaymentsParameterRepresentable]) throws -> TransferData.Payer {
        
        try paymentsTransferPayer(parameters)
    }
    
    func paymentsTransferSFPAmount(_ parameters: [PaymentsParameterRepresentable]) throws -> Double? {
        
        try paymentsTransferAmount(parameters)
    }
    
    func paymentsTransferSFPCurrency(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        try paymentsTransferCurrency(parameters)
    }
    
    func paymentsTransferSFPComment(_ parameters: [PaymentsParameterRepresentable]) throws -> String? {
        
        try paymentsTransferComment(parameters)
    }
    
    func paymentsTransferSFPAdditional(_ parameters: [Payments.Parameter]) throws -> [TransferAnywayData.Additional] {
        
        var additional = [TransferAnywayData.Additional]()
        for (index, parameter) in parameters.enumerated() {
            
            guard let parameterValue = parameter.value else {
                continue
            }
            switch parameter.id {
            case Payments.Parameter.Identifier.sfpPhone.rawValue:
                let filterredValue = String(parameterValue.unicodeScalars.filter(CharacterSet.decimalDigits.contains))
                let updatedValue = String(filterredValue.dropFirst(1))
                additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: updatedValue))
                
            default:
                additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: parameterValue))
            }
        }
        
        return additional
    }
}

//MARK: - Step

extension Model {
    
    func paymentsTransferSFPStepParameters(service: Payments.Service, response: TransferAnywayResponseData) throws -> [PaymentsParameterRepresentable] {
        
        var result = [PaymentsParameterRepresentable]()
        
        for additionalData in response.additionalList {
            
            guard let parameter = try paymentsParameterRepresentable(service: service, adittionalData: additionalData) else {
                continue
            }
            
            result.append(parameter)
        }
        
        let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
        let feeAmount = response.fee ?? 0
        let feeParameter = Payments.ParameterInfo(
            .init(id: feeParameterId, value: String(feeAmount)),
            icon: .init(named: "ic24PercentCommission") ?? .parameterDocument,
            title: "Комиссия", placement: .feed)
        
        result.append(feeParameter)
        
        let codeParameter = Payments.ParameterInput(
            .init(id: Payments.Parameter.Identifier.code.rawValue, value: nil),
            icon: .parameterSMS,
            title: "Введите код из СМС", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
        result.append(codeParameter)
        
        return result
    }
    
    func paymentsTransferSFPStepVisible(service: Payments.Service, nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable], response: TransferAnywayResponseData) throws -> [Payments.Parameter.ID] {
        
        nextStepParameters.map{ $0.id }
    }
    
    func paymentsTransferSFPStepStage(service: Payments.Service, operation: Payments.Operation, response: TransferAnywayResponseData) throws -> Payments.Operation.Stage {
        
        return .remote(.confirm)
    }
    
    func paymentsTransferSFPStepRequired(service: Payments.Service, visible: [Payments.Parameter.ID], nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable]) throws -> [Payments.Parameter.ID] {
        
        return []
    }
}
