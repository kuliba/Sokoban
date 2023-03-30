//
//  Model+PaymentsReturn.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 29.03.2023.
//

import Foundation

extension Model {
    
    func paymentReturnAbroadTransferReference(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        if let transferReference = parameters.first(where: { $0.id == Payments.Parameter.Identifier.countryReturnNumber.rawValue} )?.value {
            
            return transferReference
        } else {
            
            throw Payments.Error.missingParameter(Payments.Parameter.Identifier.countryReturnNumber.rawValue)
        }
    }
    
    func paymentReturnAbroadOperationDetailId(_ parameters: [PaymentsParameterRepresentable]) throws -> Int {
        
        if let operationIdData = parameters.first(where: { $0.id == Payments.Parameter.Identifier.countryOperationId.rawValue} )?.value,
           let operationId = Int(operationIdData) {
            
            return operationId
        } else {
            
            throw Payments.Error.missingParameter(Payments.Parameter.Identifier.countryOperationId.rawValue)
        }
    }
}

extension Model {
    
    func paymentsReturnAbroad(operation: Payments.Operation) async throws -> Payments.Success {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let transferRefence = try paymentReturnAbroadTransferReference(operation.parameters)
        let operationDetailId = try paymentReturnAbroadOperationDetailId(operation.parameters)
            
        let command = ServerCommands.TransferController.ReturnOutgoing(token: token, payload: .init(paymentOperationDetailId: operationDetailId, transferReference: transferRefence))
        let result = try await serverAgent.executeCommand(command: command)
        
        return .init(operationDetailId: operationDetailId, status: .inProgress, productId: 0, amount: 0, service: .return, serviceData: .abroadPayments(result))
    }
}
