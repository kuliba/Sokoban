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
        
        let puref = try paymentsTransferAnywayAbroadPuref(parameters)
        let payer = try paymentsTransferAnywayPayer(parameters)
        let amount = try paymentsTransferAnywayAmount(parameters)
        let currency = try paymentsTransferCurrencyAbroad(parameters)
        let comment = try paymentsTransferAnywayComment(parameters)
        
        let additional = try paymentsTransferAnywayAbroadAdditional(parameters, restrictedParameters: restrictedParametersAbroad)
        
        let command = ServerCommands.TransferController.CreateAnywayTransfer(token: token, isNewPayment: isNewPayment, payload: .init(amount: amount, check: false, comment: comment, currencyAmount: currency, payer: payer, additional: additional, puref: puref))
        
        return try await serverAgent.executeCommand(command: command)
    }
}

//MARK: Request Parameters

extension Model {
    
    func paymentsTransferAnywayAbroadAdditional(_ parameters: [PaymentsParameterRepresentable], restrictedParameters: [String]) throws -> [TransferAnywayData.Additional] {
        
        var parameters = parameters.filter({!restrictedParameters.contains($0.id)})
        
        if parameters.hasValue(forIdentifier: .countryCitySearch),
           parameters.hasValue(forIdentifier: .countryBankSearch) {
            
            parameters = parameters.filter {
                $0.id != Payments.Parameter.Identifier.countryCitySearch.rawValue
            }
        }
                
        var additional = [TransferAnywayData.Additional]()
        for (index, parameter) in parameters.enumerated() {
                
            switch parameter.id {
            case Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue:
                guard let amount = parameters.parameterAmount else {
                    break
                }
                
                //TODO: simplify using helpers
                let currencies = self.currencyList.value.filter({ $0.currencySymbol == amount.currencySymbol })
                
                if let currency = amount.deliveryCurrency?.currenciesList?.first(where: { $0.description.contained(in: currencies.map(\.code)) }) {
                    
                    additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: currency.description))
                }
                                    
            case Payments.Parameter.Identifier.countryFamilyName.rawValue:
                if let value = parameter.value {
                    
                    additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: value))
                } else {
                    
                    additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: ""))
                }

            case Payments.Parameter.Identifier.amount.rawValue:
                continue
                
            default:
                guard let parameterValue = parameter.value  else {
                    continue
                }
                
                additional.append(.init(fieldid: index + 1, fieldname: parameter.id, fieldvalue: parameterValue))
            }
        }
        
        return additional
    }
    
    func abroadAmountParameter(
        _ currencySymbol: String,
        _ selectedCurrency: Currency,
        _ currenciesList: [Currency],
        _ maxAmount: Double?
    ) -> Payments.ParameterAmount
    {
        let amountParameter = Payments.ParameterAmount(
            value: "0",
            title: "Сумма перевода",
            currencySymbol: currencySymbol,
            deliveryCurrency: .init(
                selectedCurrency: selectedCurrency,
                currenciesList: currenciesList
            ),
            transferButtonTitle: "Продолжить",
            validator: .init(
                minAmount: 0.1,
                maxAmount: maxAmount
            )
        )
        return amountParameter
    }
    
    func paymentsTransferAbroadStepParameters(
        _ operation: Payments.Operation,
        response: TransferAnywayResponseData
    ) async throws -> [PaymentsParameterRepresentable] {
        
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

            if let dataSplitted = response.parameterListForNextStep.first(where: {$0.id == Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue}) {
                
                result.append(Payments.ParameterHidden(id: Payments.Parameter.Identifier.countryCurrencyFilter.rawValue, value: dataSplitted.dataType))
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
                
                let filter = ProductData.Filter(
                    rules: [ProductData.Filter.DebitRule(),
                            ProductData.Filter.ProductTypeRule([.card, .account]),
                            ProductData.Filter.CurrencyRule(Set(currencyArr)),
                            ProductData.Filter.CardActiveRule(),
                            ProductData.Filter.CardAdditionalSelfRule(),
                            ProductData.Filter.AccountActiveRule()])
                
                if let product = firstProduct(with: filter),
                   let first = currencyArr.first {
                    
                    switch operation.source {
                    case let .template(templateId):
                        
                        let template = self.paymentTemplates.value.first(where: { $0.id == templateId })
                        let parameterList = template?.parameterList.last as? TransferAnywayData
                        let currency = parameterList?.additional.first(where: { $0.fieldname == Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue })
                        
                        
                        let selectedCurrency = self.currencyList.value.first(where: { $0.code == currency?.fieldvalue })
                        
                        let amountParameter = Payments.ParameterAmount(value: nil, title: "Сумма перевода", currencySymbol: currencySymbol, deliveryCurrency: .init(selectedCurrency: Currency.init(description: currency?.fieldvalue ?? "RUB"), currenciesList: currencyArr), transferButtonTitle: "Продолжить", validator: .init(minAmount: 0.1, maxAmount: product.balance))
                        result.append(amountParameter)
                       
                    case .latestPayment:
                        let amountParameter = abroadAmountParameter(
                            currencySymbol,
                            first,
                            currencyArr,
                            product.balance
                        )
                        result.append(amountParameter)
                        
                    default:
                       
                        let amountParameter = Payments.ParameterAmount(value: nil, title: "Сумма перевода", currencySymbol: currencySymbol, deliveryCurrency: .init(selectedCurrency: first, currenciesList: currencyArr), transferButtonTitle: "Продолжить", validator: .init(minAmount: 0.1, maxAmount: product.balance))
                        result.append(amountParameter)
                    }
                    
                } else {
                    
                    let message = "К сожалению, мы не смогли найти счета или карты в валюте \(currencyArr.first?.description ?? ""), которая требуется для данных параметров перевода"
                    throw Payments.Error.action(.alert(title: "Ошибка", message: message))
                }
                
            } else {
                
                let amount: String? = {
                    
                    switch operation.source {
                    case .latestPayment:
                        return "0"
                    default:
                        return nil
                    }
                }()

                let amountParameter = Payments.ParameterAmount(value: amount, title: "Сумма перевода", currencySymbol: currencySymbol, transferButtonTitle: "Продолжить", validator: .init(minAmount: 10, maxAmount: product.balance))
                result.append(amountParameter)
            }
        }
        
        if response.finalStep == true {
            
            result.append(Payments.ParameterCode.regular)
        }
        
        return result
    }
    
    func paymentsTransferCurrencyAbroad(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        let productParameterId = Payments.Parameter.Identifier.product.rawValue
        guard let productParameter = parameters.first(where: { $0.parameter.id ==  productParameterId}) as? Payments.ParameterProduct,
              let productId = productParameter.productId,
              let product = product(productId: productId) else {
            
            throw Payments.Error.missingParameter(productParameterId)
        }
        
        if let amount = parameters.first(where: { $0.id == Payments.Parameter.Identifier.amount.rawValue }),
           let amount = amount as? Payments.ParameterAmount {
            
            let currencies = self.currencyList.value.filter({ $0.currencySymbol == amount.currencySymbol })
            
            if let currency = amount.deliveryCurrency?.currenciesList?.first(where: {$0.description.contained(in: currencies.map(\.code))}) {
                
                return currency.description
                
            } else {
                
                return product.currency
                
            }
            
        } else {
            
            return product.currency
        }
    }
    
    func paymentsTransferAnywayAbroadPuref(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        let operatorParameterId = Payments.Parameter.Identifier.countryDropDownList.rawValue
        
        guard let operatorParameterValue = parameters.first(where: { $0.parameter.id == operatorParameterId})?.value else {
            
            throw Payments.Error.missingParameter(operatorParameterId)
        }
        
        return operatorParameterValue
    }
}

extension Model {
    
    var restrictedParametersAbroad: [String] {
        [Payments.Parameter.Identifier.code,
         Payments.Parameter.Identifier.product,
         Payments.Parameter.Identifier.`continue`,
         Payments.Parameter.Identifier.header,
         Payments.Parameter.Identifier.`operator`,
         Payments.Parameter.Identifier.service,
         Payments.Parameter.Identifier.category,
         Payments.Parameter.Identifier.countryDropDownList,
         Payments.Parameter.Identifier.countryCurrencyFilter,
         Payments.Parameter.Identifier.paymentSystem,
        ].map(\.rawValue)
    }
}
