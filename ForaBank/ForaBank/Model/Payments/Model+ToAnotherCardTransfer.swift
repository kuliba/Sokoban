//
//  Model+ToAnotherCardTransfer.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 22.02.2023.
//

import Foundation

//MARK: - Request

extension Model {
    
    func paymentsTransferToAnotherProcess(parameters: [PaymentsParameterRepresentable],
                                          process: [Payments.Parameter]) async throws -> TransferResponseData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let payer = try paymentsTransfersRequisitsPayer(parameters)
        let amount = try paymentsTransferAmount(parameters)
        let currency = try paymentsTransferCurrency(parameters)
        
        var payeeInternal: TransferGeneralData.PayeeInternal? = nil
        
        let productTemplateParameterId = Payments.Parameter.Identifier.productTemplate.rawValue
        guard let productTemplate = parameters
            .first(where: {$0.id == productTemplateParameterId }) as? Payments.ParameterProductTemplate,
              let productTemplateValue = productTemplate.parameterValue
                
        else {
            throw Payments.Error.missingParameter(productTemplateParameterId)
        }
        
        switch productTemplateValue {
        case let .cardNumber(cardNumber):
            
            if let productTemplateName = paymentsTransfersToAnotherCardProductTemplateName(parameters) {
                
                payeeInternal = .init(accountId: nil, accountNumber: nil, cardId: nil, cardNumber: cardNumber, phoneNumber: nil, productCustomName: productTemplateName)
                
            } else {
            
                payeeInternal = .init(accountId: nil, accountNumber: nil, cardId: nil, cardNumber: cardNumber, phoneNumber: nil, productCustomName: nil)
            }
            
        case let .templateId(templateId):
            
            guard let templateId = Int(templateId)
            else { throw Payments.Error.missingValueForParameter(productTemplateParameterId) }
            
            payeeInternal = .init(accountId: nil, accountNumber: nil, cardId: templateId, cardNumber: nil, phoneNumber: nil, productCustomName: nil)
        }
        
        let command = ServerCommands.TransferController.CreateTransfer
            .init(token: token,
                  payload: .init(amount: amount,
                                 check: false,
                                 comment: nil,
                                 currencyAmount: currency,
                                 payer: payer,
                                 payeeExternal: nil,
                                 payeeInternal: payeeInternal))
        
        return try await serverAgent.executeCommand(command: command)
    }
}

extension Model {
    
    func paymentsTransfersToAnotherCardProductTemplateName(_ parameters: [PaymentsParameterRepresentable]) -> String? {
        
        let productTemplateNameParameterId = Payments.Parameter.Identifier.productTemplateName.rawValue
        
        guard let productTemplateNameParameterValue = parameters.first(where: { $0.id == productTemplateNameParameterId })?.value
        else { return nil }
        
        return productTemplateNameParameterValue
    }
    
}

