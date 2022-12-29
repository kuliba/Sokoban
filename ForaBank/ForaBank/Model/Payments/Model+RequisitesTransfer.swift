//
//  Model+RequisitesTransfer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 13.12.2022.
//

import Foundation

//MARK: - Request

extension Model {
    
    func paymentsTransferRequisitesProcess(parameters: [PaymentsParameterRepresentable], process: [Payments.Parameter]) async throws -> TransferResponseData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let payer = try paymentsTransfersRequisitsPayer(parameters)
        let amount = try paymentsTransferAmount(parameters)
        let currency = try paymentsTransferCurrency(parameters)
        let comment = try paymentsTransfersRequisitsMessage(parameters)
        let payeeExternal = try paymentsTransfersRequisitsPayeeExternal(parameters)
        
        let command = ServerCommands.TransferController.CreateTransfer(token: token, payload: .init(amount: amount, check: true, comment: comment, currencyAmount: currency, payer: payer, payeeExternal: payeeExternal, payeeInternal: nil))
        
        return try await serverAgent.executeCommand(command: command)
    }
}

extension Model {
    
    func paymentsTransfersRequisitsMessage(_ parameters: [PaymentsParameterRepresentable]) throws -> String? {
        
        let messageParameterId = Payments.Parameter.Identifier.requisitsMessage.rawValue
        guard let messageParameterValue = parameters.first(where: { $0.id == messageParameterId })?.value else {
            
            return nil
        }
        
        return messageParameterValue
    }
    
    func paymentsTransfersRequisitsPayer(_ parameters: [PaymentsParameterRepresentable]) throws -> TransferGeneralData.Payer {
        
        let productParameterId = Payments.Parameter.Identifier.product.rawValue
        guard let productParameter = parameters.first(where: { $0.parameter.id == productParameterId}) as? Payments.ParameterProduct,
              let productId = productParameter.productId,
              let productType = productType(for: productId) else {
            
            throw Payments.Error.missingParameter(productParameterId)
        }
        
        switch productType {
        case .card:
            return .init(inn: nil, accountId: nil, accountNumber: nil, cardId: productId, cardNumber: nil, phoneNumber: nil)
        case .account:
            return .init(inn: nil, accountId: productId, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        default:
            throw Payments.Error.unexpectedProductType(productType)
        }
    }
    
    func paymentsTransfersRequisitsPayeeExternal(_ parameters: [PaymentsParameterRepresentable]) throws -> TransferGeneralData.PayeeExternal {
        
        let accountParameterId = Payments.Parameter.Identifier.requisitsAccountNumber.rawValue
        guard let accountParameterValue = parameters.first(where: { $0.id == accountParameterId })?.value else {
            
            throw Payments.Error.missingParameter(accountParameterId)
        }
        
        let nameParameterId = Payments.Parameter.Identifier.requisitsName.rawValue
        let companyNameParameterId = Payments.Parameter.Identifier.requisitsCompanyName.rawValue
        
        guard let nameParameterValue = parameters.first(where: { $0.id == nameParameterId })?.value ?? parameters.first(where: { $0.id == companyNameParameterId })?.value else {
            
            throw Payments.Error.missingParameter(nameParameterId)
        }
        
        let bicParameterId = Payments.Parameter.Identifier.requisitsBankBic.rawValue
        guard let bicParameterValue = parameters.first(where: { $0.id == bicParameterId })?.value  else {
            throw Payments.Error.missingParameter(bicParameterId)
        }
        
        let innParameterId = Payments.Parameter.Identifier.requisitsInn.rawValue
        if let innParameterValue = parameters.first(where: { $0.id == innParameterId })?.value {
            
            return .init(inn: innParameterValue, kpp: nil, accountId: nil, accountNumber: accountParameterValue, bankBIC: bicParameterValue, cardId: nil, cardNumber: nil, compilerStatus: nil, date: nil, name: nameParameterValue, tax: nil)
        }
        
        return .init(inn: nil, kpp: nil, accountId: nil, accountNumber: accountParameterValue, bankBIC: bicParameterValue, cardId: nil, cardNumber: nil, compilerStatus: nil, date: nil, name: nameParameterValue, tax: nil)
    }
}
