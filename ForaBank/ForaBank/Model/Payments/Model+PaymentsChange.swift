//
//  Model+PaymentsChange.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 29.03.2023.
//

import Foundation

extension Model {
    
    func paymentsChangeAbroadName(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        if let name = parameters.first(where: { $0.id == Payments.Parameter.Identifier.countryReturnName.rawValue} )?.value {
            
            return name
        } else {
            
            throw Payments.Error.missingParameter(Payments.Parameter.Identifier.countryReturnName.rawValue)
        }
    }
}

extension Model {
    
    func paymentsChangeAbroad(operation: Payments.Operation) async throws -> Payments.Success {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let transferReference = try paymentReturnAbroadTransferReference(operation.parameters)
        let name = try paymentsChangeAbroadName(operation.parameters)
        
        let bLastName = Payments.ParameterName.name(with: name, index: 0) ?? ""
        let bName = Payments.ParameterName.name(with: name, index: 1) ?? ""
        let bSurName = Payments.ParameterName.name(with: name, index: 2) ?? ""
        
        let command = ServerCommands.TransferController.ChangeOutgoing(token: token, payload: .init(bLastName: bLastName, bName: bName, bSurName: bSurName, transferReference: transferReference))
        let result = try await serverAgent.executeCommand(command: command)
            
        return .init(operationDetailId: 0, status: .inProgress, productId: 0, amount: 0, service: .change, serviceData: .abroadPayments(result))
    }
}
