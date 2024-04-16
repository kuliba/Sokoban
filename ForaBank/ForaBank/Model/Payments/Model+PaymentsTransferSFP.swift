//
//  Model+PaymentsTransferSFP.swift
//  ForaBank
//
//  Created by Max Gribov on 09.11.2022.
//

import Foundation

//MARK: - Request

extension Model {
    
    func paymentsTransferSFPProcess(parameters: [PaymentsParameterRepresentable], process: [Payments.Parameter]) async throws -> TransferResponseData {
        
        let bankParameterId = Payments.Parameter.Identifier.sfpBank.rawValue
        guard let bankParameterValue = parameters.first(where: { $0.id == bankParameterId })?.value else {
            
            throw Payments.Error.missingParameter(bankParameterId)
        }
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        if isForaBank(bankId: bankParameterValue) == true {
            
            let payer = try paymentsTransferSFPPayer(parameters)
            let amount = try paymentsTransferSFPAmount(parameters)
            let currency = try paymentsTransferSFPCurrency(parameters)
            let comment = try paymentsTransferSFPComment(parameters)
            let payeeInternal = try paymentsTransfersSFPPayeeInternalPhone(parameters)
            
            let command = ServerCommands.TransferController.CreateTransfer(token: token, payload: .init(amount: amount, check: false, comment: comment, currencyAmount: currency, payer: payer, payeeExternal: nil, payeeInternal: payeeInternal))
            
            return try await serverAgent.executeCommand(command: command)
            
        } else {
            
            let puref = try paymentsTransferSFPPuref(parameters)
            let payer = try paymentsTransferSFPPayer(parameters)
            let amount = try paymentsTransferSFPAmount(parameters)
            let currency = try paymentsTransferSFPCurrency(parameters)
            let comment = try paymentsTransferSFPComment(parameters)
            let additional = try paymentsTransferSFPAdditional(process, allParameters: parameters)
            
            let command = ServerCommands.TransferController.CreateSFPTransfer(token: token, payload: .init(amount: amount, check: true, comment: comment, currencyAmount: currency, payer: payer, additional: additional, puref: puref))
            
            return try await serverAgent.executeCommand(command: command)
        }
    }
    
    func paymentsTransferSFPProcessFora(parameters: [PaymentsParameterRepresentable], process: [Payments.Parameter]) async throws -> TransferResponseData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let payer = try paymentsTransferSFPPayer(parameters)
        let amount = try paymentsTransferSFPAmount(parameters)
        let currency = try paymentsTransferSFPCurrency(parameters)
        let comment = try paymentsTransferSFPComment(parameters)
        let payeeInternal = try paymentsTransfersSFPPayeeInternalPhone(parameters)
        
        let command = ServerCommands.TransferController.CreateTransfer(token: token, payload: .init(amount: amount, check: true, comment: comment, currencyAmount: currency, payer: payer, payeeExternal: nil, payeeInternal: payeeInternal))
        
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
    
    func paymentsTransferSFPAdditional(
        _ parameters: [Payments.Parameter],
        allParameters: [PaymentsParameterRepresentable]
    ) throws -> [TransferAnywayData.Additional] {
        
        var additional = [TransferAnywayData.Additional]()
        for (index, parameter) in parameters.enumerated() {
            
            guard let parameterValue = parameter.value, parameterValue.isEmpty == false else {
                continue
            }
            switch parameter.id {
            case Payments.Parameter.Identifier.sfpPhone.rawValue:
                let filterredValue = String(parameterValue.unicodeScalars.filter(CharacterSet.decimalDigits.contains))
                additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: filterredValue))
                
            default:
                additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: parameterValue))
            }
        }
        
        let messageParameterId = Payments.Parameter.Identifier.sfpMessage.rawValue
        if let messageParameterValue = allParameters.first(where: { $0.id == messageParameterId })?.value {
            
            additional.append(.init(fieldid: additional.count + 1, fieldname: messageParameterId, fieldvalue: messageParameterValue))
        }
        
        return additional
    }
    
    func paymentsTransfersSFPPayeeInternalPhone(_ parameters: [PaymentsParameterRepresentable]) throws -> TransferGeneralData.PayeeInternal {
        
        let phoneParameterId = Payments.Parameter.Identifier.sfpPhone.rawValue
        guard let phoneParameterValue = parameters.first(where: { $0.id == phoneParameterId })?.value else {
            
            throw Payments.Error.missingParameter(phoneParameterId)
        }
            
        return .init(accountId: nil, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: phoneParameterValue.digits, productCustomName: nil)
    }
}

//MARK: - Step

extension Model {
    
    func paymentsTransferSFPStepParameters(_ operation: Payments.Operation, response: TransferAnywayResponseData) throws -> [PaymentsParameterRepresentable] {
        
        var result = [PaymentsParameterRepresentable]()
        let spoilerGroup = Payments.Parameter.Group(id: UUID().uuidString, type: .spoiler)
        for additionalData in response.additionalList {
            
            guard let parameter = try paymentsParameterRepresentable(operation, additionalData: additionalData, group: spoilerGroup) else {
                continue
            }
            
            result.append(parameter)
        }
        
       
        if let feeAmount = response.fee,
           let feeAmountFormatted = paymentsAmountFormatted(amount: feeAmount, parameters: operation.parameters) {
            
            let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
            let feeParameter = Payments.ParameterInfo(
                .init(id: feeParameterId, value: feeAmountFormatted),
                icon: .local("ic24PercentCommission"),
                title: "Комиссия", placement: .feed)
            
            result.append(feeParameter)
        }

        result.append(Payments.ParameterCode.regular)
        
        if response.scenario == .suspect {
            
            result.append(Payments.ParameterInfo(
                .init(id: Payments.Parameter.Identifier.sfpAntifraud.rawValue, value: "SUSPECT"),
                icon: .image(.parameterDocument),
                title: "Antifraud"
            ))
        }
        
        return result
    }
    
    func paymentsTransferSFPStepVisible(_ operation: Payments.Operation, nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable], response: TransferAnywayResponseData) throws -> [Payments.Parameter.ID] {
        
        let antifraudParameterId = Payments.Parameter.Identifier.sfpAntifraud.rawValue
        return nextStepParameters.map{ $0.id }.filter({ $0 != antifraudParameterId })
    }
    
    func paymentsTransferSFPStepStage(_ operation: Payments.Operation, response: TransferAnywayResponseData) throws -> Payments.Operation.Stage {
        
        return .remote(.confirm)
    }
    
    func paymentsTransferSFPStepRequired(_ operation: Payments.Operation, visible: [Payments.Parameter.ID], nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable]) throws -> [Payments.Parameter.ID] {
        
        return []
    }
}
