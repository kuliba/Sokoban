//
//  Model+PaymentsTransfersServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 16.05.2023.
//

import Foundation

//MARK: - Request

extension Model {
    
    func paymentsTransferPaymentsServicesProcess(parameters: [PaymentsParameterRepresentable], process: [Payments.Parameter], isNewPayment: Bool) async throws -> TransferAnywayResponseData {
        
        guard let token = token else {
            
            throw Payments.Error.notAuthorized
        }
        
        let puref = try paymentsTransferAnywayPuref(parameters)
        let payer = try paymentsTransferAnywayPayer(parameters)
        let amount = try paymentsTransferAnywayAmount(parameters)
        let currency = try paymentsTransferAnywayCurrency(parameters)
        let comment = try paymentsTransferAnywayComment(parameters)
                
        let excludingParameters: [Payments.Parameter.Identifier] = [
            .amount,
            .code,
            .product,
            .`continue`,
            .header,
            .`operator`,
            .service,
            .category
        ]
        let excludingParametersIDs = excludingParameters.map(\.rawValue)
        
        let additional = try paymentsTransferPaymentsServicesAdditional(parameters, excludingParameters: excludingParametersIDs)
        
        let command = ServerCommands.TransferController.CreateAnywayTransfer(token: token, isNewPayment: isNewPayment, payload: .init(amount: amount, check: false, comment: comment, currencyAmount: currency, payer: payer, additional: additional, puref: puref))
        
        return try await serverAgent.executeCommand(command: command)
    }
    
}

//MARK: Request Parameters

extension Model {
    
    func paymentsTransferPaymentsServicesAdditional(_ parameters: [PaymentsParameterRepresentable], excludingParameters: [String]) throws -> [TransferAnywayData.Additional] {
        
        let parameters = parameters.filter({!excludingParameters.contains($0.id)})
        var additional = [TransferAnywayData.Additional]()
        for (index, parameter) in parameters.enumerated() {
            
            guard let parameterValue = parameter.value else {
                continue
            }
            additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: parameterValue))
        }
        return additional
    }
    
    func paymentsTransferPaymentsServicesStepParameters(_ operation: Payments.Operation, response: TransferAnywayResponseData) async throws -> [PaymentsParameterRepresentable] {
        func amountForPayment(operation: Payments.Operation) -> String? {
            if case let .servicePayment(_, _, amountValue, _) = operation.source {
                
                let amount = Decimal(amountValue)
                return "\(amount)"
            }
            return nil
        }
        var result = [PaymentsParameterRepresentable]()
        let spoilerGroup = Payments.Parameter.Group(id: UUID().uuidString, type: .spoiler)
        for additionalData in response.additionalList {
            
            guard let parameter = try paymentsParameterRepresentable(operation, additionalData: additionalData, group: spoilerGroup) else {
                continue
            }
            result.append(parameter)
        }
        
        for parameterData in response.parameterListForNextStep {
            if let parameter = try await paymentsParameterRepresentable(operation, parameterData: parameterData) {
                
                result.append(parameter)
            } else {
                
                let parameter = try paymentsParameterRepresentable(parameterData: parameterData)
                result.append(parameter)
            }
        }
        
        if response.needSum {
            
            // amount
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            guard let productParameter = operation.parameters.first(where: { $0.id == productParameterId}) as? Payments.ParameterProduct,
                  let productId = productParameter.productId,
                  let product = product(productId: productId),
                  let currencySymbol = dictionaryCurrencySymbol(for: product.currency) else {
                throw Payments.Error.missingParameter(productParameterId)
            }
            let amount = amountForPayment(operation: operation)
            let amountParameter = Payments.ParameterAmount(value: amount, title: "Сумма платежа", currencySymbol: currencySymbol, transferButtonTitle: "Продолжить", validator: .init(minAmount: 0.01, maxAmount: product.balance), info: .action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo))
            result.append(amountParameter)
        }
        
        if response.finalStep {
            
            result.append(Payments.ParameterCode.regular)
        }
        
        return result
    }
    
    // update depependend parameters
    func paymentsProcessDependencyReducerPaymentsServices(parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {

        switch parameterId {
        case Payments.Parameter.Identifier.amount.rawValue:
            
            guard let amountParameter = parameters.first(where: { $0.id == parameterId }) as? Payments.ParameterAmount else {
                return nil
            }
            
            var currencySymbol = amountParameter.currencySymbol
            var maxAmount = amountParameter.validator.maxAmount
            
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            if let productParameter = parameters.first(where: { $0.id == productParameterId}) as? Payments.ParameterProduct,
               let productId = productParameter.productId,
               let product = product(productId: productId),
               let productCurrencySymbol = dictionaryCurrencySymbol(for: product.currency) {
                
                currencySymbol = productCurrencySymbol
                maxAmount = product.balance
            }
         
            return amountParameter.update(currencySymbol: currencySymbol, maxAmount: maxAmount)
                    
        default:
            return nil
        }
    }
}
