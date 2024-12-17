//
//  Model+PaymentsChange.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 29.03.2023.
//

import Foundation

extension Model {
    
    func paymentsChangeAbroadName(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        let id = Payments.Parameter.Identifier.countryReturnName
        
        if let name = parameters.first(where: { $0.id == id.rawValue} )?.value {
            
            return name
        } else {
            
            throw Payments.Error.missingParameter(id.rawValue)
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
            
        return try .init(with: result, operation: operation, title: "Запрос на изменение перевода принят в обработку")
    }
}
