//
//  Model+PaymentsAnywayAbroad.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.02.2023.
//

import Foundation

//MARK: - Request

extension Model {
    
    func paymentsTransferAnywayAbroadProcess(parameters: [PaymentsParameterRepresentable], process: [Payments.Parameter], isNewPayment: Bool) async throws -> TransferAnywayResponseData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let puref = try paymentsTransferAnywayPuref(parameters)
        let payer = try paymentsTransferAnywayPayer(parameters)
        let amount = try paymentsTransferAnywayAmount(parameters)
        let currency = try paymentsTransferCurrencyAbroad(parameters)
        let comment = try paymentsTransferAnywayComment(parameters)
        
        let restrictedParameters: [String] = [Payments.Parameter.Identifier.amount.rawValue,
                                              Payments.Parameter.Identifier.code.rawValue,
                                              Payments.Parameter.Identifier.product.rawValue,
                                              Payments.Parameter.Identifier.`continue`.rawValue,
                                              Payments.Parameter.Identifier.header.rawValue,
                                              Payments.Parameter.Identifier.`operator`.rawValue,
                                              Payments.Parameter.Identifier.service.rawValue,
                                              Payments.Parameter.Identifier.category.rawValue,
                                              Payments.Parameter.Identifier.countryDropDownList.rawValue]
        
        let additional = try paymentsTransferAnywayAbroadAdditional(parameters, restrictedParameters: restrictedParameters)
        
        let command = ServerCommands.TransferController.CreateAnywayTransfer(token: token, isNewPayment: isNewPayment, payload: .init(amount: amount, check: false, comment: comment, currencyAmount: currency, payer: payer, additional: additional, puref: puref))
        
        return try await serverAgent.executeCommand(command: command)
    }
}

//MARK: Request Parameters

extension Model {
    
    func paymentsTransferAnywayAbroadAdditional(_ parameters: [PaymentsParameterRepresentable], restrictedParameters: [String]) throws -> [TransferAnywayData.Additional] {
        
        var parameters = parameters.filter({!restrictedParameters.contains($0.id)})
        
        if parameters.contains(where: {$0.id == Payments.Parameter.Identifier.countryCitySearch.rawValue}),
            parameters.contains(where: {$0.id == Payments.Parameter.Identifier.countryBankSearch.rawValue}) {
            
            parameters = parameters.filter({$0.id != Payments.Parameter.Identifier.countryCitySearch.rawValue})
        }
                
        var additional = [TransferAnywayData.Additional]()
        for (index, parameter) in parameters.enumerated() {
                
            switch parameter.id {
            case Payments.Parameter.Identifier.countrybSurName.rawValue:
                if let value = parameter.value {
                    
                    additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: value))
                } else {
                    
                    additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: ""))
                }

            default:
                guard let parameterValue = parameter.value  else {
                    continue
                }
                
                additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: parameterValue))
            }
        }
        
        return additional
    }
    
    func paymentsTransferAbroadStepParameters(_ operation: Payments.Operation, response: TransferAnywayResponseData) async throws -> [PaymentsParameterRepresentable] {
        
        var result = [PaymentsParameterRepresentable]()
        let spoilerGroup = Payments.Parameter.Group(id: UUID().uuidString, type: .spoiler)
        for additionalData in response.additionalList {
            
            guard let parameter = try paymentsParameterRepresentable(operation, adittionalData: additionalData, group: spoilerGroup) else {
                
                continue
            }
            
            result.append(parameter)
        }
        
        for parameterData in response.parameterListForNextStep {
            
            if let parameter = try await paymentsParameterRepresentable(operation, parameterData: parameterData) {
                
                result.append(parameter)
                
            } else {
                
                switch operation.service {
                case .abroad:
                    let parameter = try await paymentsParameterRepresentableCountries(operation: operation, parameterData: parameterData)
                    
                    if let parameter = parameter {
                        
                        result.append(parameter)
                    }
                    
                default:
                    let parameter = try paymentsParameterRepresentable(parameterData: parameterData)
                    result.append(parameter)
                }
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

            if let dataSplitted = response.parameterListForNextStep.first(where: {$0.id == Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue})?.dataType?.description.split(separator: ";") {

                var currencies: String = ""

                for chunk in dataSplitted {

                    let chunkSplitted = chunk.split(separator: "=")

                    guard chunkSplitted.count >= 1, chunkSplitted[0] != "" else {
                        continue
                    }

                    let name = String(chunkSplitted[0])
                    currencies += "\(name) "
                }
                
                result.append(Payments.ParameterHidden.init(id: Payments.Parameter.Identifier.countryCurrencyFilter.rawValue, value: currencies))
            }
                        
            if let currencies = response.parameterListForNextStep.first(where: {$0.id == Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue}) {
                
                let currencies = currencies.options(style: .currency)?.compactMap({$0.id}).joined(separator: "-")
                let currency = currencies?.components(separatedBy: "-")

                var currencyArr: [Currency] = []
                if let currency = currency {
                    
                    for item in currency {
                        
                        currencyArr.append(Currency(description: item))
                    }
                }
                
                if let first = currencyArr.first {
                    
                    let amountParameter = Payments.ParameterAmount(value: "0", title: "Сумма перевода", currencySymbol: currencySymbol, deliveryCurrency: .init(selectedCurrency: first, currenciesList: currencyArr), transferButtonTitle: "Продолжить", validator: .init(minAmount: 10, maxAmount: product.balance))
                    result.append(amountParameter)
                }
                
            } else {
                
                let amountParameter = Payments.ParameterAmount(value: "0", title: "Сумма перевода", currencySymbol: currencySymbol, transferButtonTitle: "Продолжить", validator: .init(minAmount: 10, maxAmount: product.balance))
                result.append(amountParameter)
            }
        }
        
        if response.finalStep == true {
            
            result.append(Payments.ParameterCode.regular)
        }
        
        return result
    }
    
    func paymentsTransferCurrencyAbroad(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        if let currencyDelivery = parameters.first(where: {$0.id == Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue}),
           let currency = currencyDelivery.value{
            
            return currency
        } else {
            
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            guard let productParameter = parameters.first(where: { $0.parameter.id ==  productParameterId}) as? Payments.ParameterProduct,
                  let productId = productParameter.productId,
                  let product = product(productId: productId) else {
                
                throw Payments.Error.missingParameter(productParameterId)
            }
            
            return product.currency
        }
    }
}
