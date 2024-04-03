//
//  Model+PaymensSFP.swift
//  ForaBank
//
//  Created by Max Gribov on 09.11.2022.
//

import Foundation
import UIKit

extension Model {
    
    func paymentsStepSFP(_ operation: Payments.Operation, for stepIndex: Int) async throws -> Payments.Operation.Step {
        
        switch stepIndex {
        case 0:
            // operator
            let operatorParameter = Payments.ParameterOperator(operatorType: .sfp)
            
            // header              
            let headerParameter: Payments.ParameterHeader = parameterHeader(
                source: operation.source,
                header: .init(
                    title: "Перевод по номеру телефона",
                    icon: .name("ic24Sbp"))
            )
            
            // phone
            let phoneParameterId = Payments.Parameter.Identifier.sfpPhone.rawValue
            let phoneParameter = Self.phoneInput
            
            // bank
            let bankParameter = bankParameter(operation, operationPhone: nil)
            let bankParameterId = Payments.Parameter.Identifier.sfpBank.rawValue

            // product
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            let filter = ProductData.Filter.generalFrom
            guard let product = firstProduct(with: filter),
                  let currencySymbol = dictionaryCurrencySymbol(for: product.currency) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            
            let productId = productWithSource(source: operation.source, productId: String(product.id))
            let productParameter = Payments.ParameterProduct(value: productId, filter: filter, isEditable: true)
            
            //message
            let messageParameterId = Payments.Parameter.Identifier.sfpMessage.rawValue
            let messageParameterIcon = ImageData(named: "ic24IconMessage") ?? .parameterSample
            let messageParameter = Payments.ParameterInput(.init(id: messageParameterId, value: nil), icon: messageParameterIcon, title: "Сообщение получателю", validator: .anyValue)
            
            // amount
            let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
            let amountParameter = Payments.ParameterAmount(value: nil, title: "Сумма перевода", currencySymbol: currencySymbol, validator: .init(minAmount: 0.01, maxAmount: product.balance))
            
            return .init(parameters: [operatorParameter, headerParameter, phoneParameter, bankParameter, productParameter, messageParameter, amountParameter], front: .init(visible: [headerParameter.id, phoneParameterId, bankParameterId, productParameterId, messageParameterId, amountParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [phoneParameterId, bankParameterId], processed: nil))
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    // update parameter value with source
    func paymentsProcessSourceReducerSFP(
        phone: String,
        bankId: BankData.ID,
        parameterId: Payments.Parameter.ID
    ) -> Payments.Parameter.Value? {

        switch parameterId {
        case Payments.Parameter.Identifier.sfpPhone.rawValue:
            let phoneFormatted = phone.digits.addCodeRuIfNeeded()
            return PhoneNumberKitFormater().format(phoneFormatted)
            
        case Payments.Parameter.Identifier.sfpBank.rawValue:
            return bankId
            
        default:
            return nil
        }
    }
    
    // update depependend parameters
    func paymentsProcessDependencyReducerSFP(
        operation: Payments.Operation,
        parameterId: Payments.Parameter.ID,
        parameters: [PaymentsParameterRepresentable]
    ) -> PaymentsParameterRepresentable? {
        
        switch parameterId {
        case Payments.Parameter.Identifier.sfpBank.rawValue:
            guard let parameter = parameters.first(where: { $0.id == parameterId }) as? Payments.ParameterSelectBank else {
                return nil
            }
            
            if let operationPhone = try? parameters.value(forIdentifier: .sfpPhone),
               PhoneValidator().isValid(operationPhone) {
                
                let newBankParameter = bankParameter(operation, operationPhone: operationPhone)
                
                if parameter.options == newBankParameter.options {
                    
                    return parameter
                } else {
                    
                    return newBankParameter
                }
                
            } else {
                
                return parameter
            }
                        
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
            
            var isForaBankValue: Bool? = nil
            
            let bankParameterId = Payments.Parameter.Identifier.sfpBank.rawValue
            if let bankParameter = parameters.first(where: { $0.id == bankParameterId }),
               let bankParameterValue = bankParameter.value {
             
                isForaBankValue = isForaBank(bankId: bankParameterValue)
            }
            
            let updatedAmountParameter = amountParameter.updated(currencySymbol: currencySymbol, maxAmount: maxAmount, isForaBank: isForaBankValue)
            
            guard updatedAmountParameter.currencySymbol != amountParameter.currencySymbol || updatedAmountParameter.validator != amountParameter.validator || updatedAmountParameter.info != amountParameter.info else {
                return nil
            }
            
            return updatedAmountParameter

        case Payments.Parameter.Identifier.header.rawValue:
            let codeParameterId = Payments.Parameter.Identifier.code.rawValue
            let parametersIds = parameters.map{ $0.id }
            guard parametersIds.contains(codeParameterId) else {
                return nil
            }
            return Payments.ParameterHeader(title: "Подтвердите реквизиты", icon: .name("ic24Sbp"))
            
        case Payments.Parameter.Identifier.sfpMessage.rawValue:
            
            guard let messageParameter = parameters.first(where: { $0.id == parameterId }) as? Payments.ParameterInput else {
                return nil
            }
            
            let bankParameterId = Payments.Parameter.Identifier.sfpBank.rawValue
            guard let bankParameter = parameters.first(where: { $0.id == bankParameterId }),
               let bankParameterValue = bankParameter.value else {
                return nil
            }
            
            if isForaBank(bankId: bankParameterValue) == true {
                
                return messageParameter.updated(isEditable: false)

            } else {
                
                return messageParameter.updated(isEditable: true)
            }
            
        default:
            return nil
        }
    }
    
    /// update current step stage
    func paymentsProcessCurrentStepStageReducerSFP(service: Payments.Service, parameters: [PaymentsParameterRepresentable], stepIndex: Int, stepStage: Payments.Operation.Stage) -> Payments.Operation.Stage? {
        
        guard stepIndex == 0 else {
            return nil
        }
        
        let phoneParameterId = Payments.Parameter.Identifier.sfpPhone.rawValue
        let bankParameterId = Payments.Parameter.Identifier.sfpBank.rawValue
        guard let phoneParameterValue = parameters.first(where: { $0.id == phoneParameterId })?.value,
              let bankParameterValue = parameters.first(where: { $0.id == bankParameterId })?.value,
              let clientPhone = clientInfo.value?.phone else {
            
            return nil
        }
        
        if isForaBank(bankId: bankParameterValue) == true, phoneParameterValue.digits == clientPhone.digits {
            
            return .remote(.start)
            
        } else {
            
            return .remote(.start)
        }
    }

    // process remote confirm step for payment to Fora clint
    func paymentsProcessRemoteStepSFP(operation: Payments.Operation, response: TransferResponseData) async throws -> Payments.Operation.Step {

        var parameters = [PaymentsParameterRepresentable]()
        
        if let customerName = response.payeeName {
            
            let customerParameterId = Payments.Parameter.Identifier.sftRecipient.rawValue
            let customerParameter = Payments.ParameterInfo(
                .init(id: customerParameterId, value: customerName),
                icon: .local("ic24Customer"),
                title: "Получатель", placement: .feed)
            
            parameters.append(customerParameter)
        }

        if let amountValue = response.debitAmount,
              let amountFormatted = paymentsAmountFormatted(amount: amountValue, parameters: operation.parameters) {
            
            let amountParameterId = Payments.Parameter.Identifier.sfpAmount.rawValue
            let amountParameter = Payments.ParameterInfo(
                .init(id: amountParameterId, value: amountFormatted),
                icon: .local("ic24Coins"),
                title: "Сумма перевода", placement: .feed)
            
            parameters.append(amountParameter)
        }
        
        if let feeAmount = response.fee,
           let feeAmountFormatted = paymentsAmountFormatted(amount: feeAmount, parameters: operation.parameters) {
            
            let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
            let feeParameter = Payments.ParameterInfo(
                .init(id: feeParameterId, value: feeAmountFormatted),
                icon: .local("ic24PercentCommission"),
                title: "Комиссия", placement: .feed)
            
            parameters.append(feeParameter)
        }
        
        if response.scenario == .suspect {
            
            parameters.append(Payments.ParameterInfo(
                .init(id: Payments.Parameter.Identifier.sfpAntifraud.rawValue, value: "SUSPECT"),
                icon: .image(.parameterDocument),
                title: "Antifraud"
            ))
            
        } else if response.scenario == .ok {
            
            parameters.append(Payments.ParameterInfo(
                .init(id: Payments.Parameter.Identifier.sfpAntifraud.rawValue, value: "OK"),
                icon: .image(.parameterDocument),
                title: "Antifraud"
            ))
        }
        
        if response.needOTP == true {
            
            parameters.append(Payments.ParameterCode.regular)
            
            return .init(parameters: parameters, front: .init(visible: parameters.map({ $0.id }), isCompleted: false), back: .init(stage: .remote(.confirm), required: [], processed: nil))
            
        } else {
            
            return .init(parameters: parameters, front: .init(visible: parameters.map({ $0.id }), isCompleted: false), back: .init(stage: .remote(.next), required: [], processed: nil))
        }
    }
    
    // map additional data
    func paymentsParameterRepresentableSFP(
        _ operation: Payments.Operation,
        additionalData: TransferAnywayResponseData.AdditionalData
    ) throws -> PaymentsParameterRepresentable? {
        
        switch additionalData.fieldName {
        case Payments.Parameter.Identifier.sftRecipient.rawValue:
            return Payments.ParameterInfo(
                .init(id: additionalData.fieldName, value: additionalData.fieldValue),
                icon: .local("ic24Customer"),
                title: additionalData.fieldTitle ?? "", placement: .feed) //FIXME: fix unwrap optional title
            
        case Payments.Parameter.Identifier.sfpAmount.rawValue:
            guard let amountStringValue = additionalData.fieldValue,
                  let amountValue = Double(amountStringValue),
                  let amountFormatted = paymentsAmountFormatted(amount: amountValue, parameters: operation.parameters) else {
                return nil
            }

            return Payments.ParameterInfo(
                .init(id: additionalData.fieldName, value: amountFormatted),
                icon: .local("ic24Coins"),
                title: additionalData.fieldTitle ?? "", placement: .feed) //FIXME: fix unwrap optional title
            
        case Payments.Parameter.Identifier.sfpAntifraud.rawValue:
            return Payments.ParameterInfo(
                .init(id: additionalData.fieldName, value: additionalData.fieldValue),
                icon: .image(.parameterDocument),
                title: additionalData.fieldTitle ?? "", placement: .feed) //FIXME: fix unwrap optional title

        default:
            return nil
        }
    }
    
    // resets visible items and order 
    func paymentsProcessOperationResetVisibleSFP(_ operation: Payments.Operation) async throws -> [Payments.Parameter.ID]? {
        
        // check if current step stage is confirm
        guard case .remote(let remote) = operation.steps.last?.back.stage,
              remote == .confirm else {
            return nil
        }
        
        if operation.parameters.first(where: { $0.id == Payments.Parameter.Identifier.sfpMessage.rawValue })?.value != nil {
            
            return [Payments.Parameter.Identifier.header.rawValue,
                    Payments.Parameter.Identifier.sfpPhone.rawValue,
                    Payments.Parameter.Identifier.sftRecipient.rawValue,
                    Payments.Parameter.Identifier.sfpBank.rawValue,
                    Payments.Parameter.Identifier.sfpAmount.rawValue,
                    Payments.Parameter.Identifier.sfpMessage.rawValue,
                    Payments.Parameter.Identifier.fee.rawValue,
                    Payments.Parameter.Identifier.code.rawValue]
            
        } else {

            return [Payments.Parameter.Identifier.header.rawValue,
                    Payments.Parameter.Identifier.sfpPhone.rawValue,
                    Payments.Parameter.Identifier.sftRecipient.rawValue,
                    Payments.Parameter.Identifier.sfpBank.rawValue,
                    Payments.Parameter.Identifier.sfpAmount.rawValue,
                    Payments.Parameter.Identifier.fee.rawValue,
                    Payments.Parameter.Identifier.code.rawValue]
        }

    }
    
    // debug mock
    static func paymentsMockSFP() -> Payments.Mock {
        
        return .init(
            service: .sfp,
            parameters: [
                .init(id: Payments.Parameter.Identifier.sfpPhone.rawValue, value: "+7 0115110217"),
                .init(id: Payments.Parameter.Identifier.sfpBank.rawValue, value: "1crt88888881")
            ]
        )
    }
}

extension Payments.ParameterAmount {
    
    func updated(currencySymbol: String, maxAmount: Double?, isForaBank: Bool?) -> Payments.ParameterAmount {
        
        if isForaBank == true {
            
            return Payments.ParameterAmount(value: value, title: "Сумма перевода", currencySymbol: currencySymbol, validator: .init(minAmount: 0.01, maxAmount: maxAmount), info: .action(title: "Без комиссии", .name("ic24Info"), .feeInfo))
            
        } else {
            
            return Payments.ParameterAmount(value: value, title: "Сумма перевода", currencySymbol: currencySymbol, validator: .init(minAmount: 0.01, maxAmount: maxAmount), info: .action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo))
        }
    }
}

extension Model {
    
    func bankParameter(
        _ operation: Payments.Operation,
        operationPhone: String?
    ) -> Payments.ParameterSelectBank {
    
        switch operation.source {
        case let .latestPayment(latestPaymentId):
            if let latestPayment = self.latestPayments.value.first(where: { $0.id == latestPaymentId }) as? PaymentGeneralData {
            
                return filterByPhone(operationPhone ?? latestPayment.phoneNumber.digits, bankId: latestPayment.bankId)
            } else {
                return filterByPhone(nil, bankId: nil)
            }
            
        case let .sfp(phone: phone, bankId: bankId):
            return filterByPhone(operationPhone ?? phone, bankId: bankId)
            
        case let .mock(mock):
            return filterByPhone(mock.parameters.first?.value, bankId: nil)
            
        default:
            return filterByPhone(nil, bankId: nil)
        }
    }
    
    private func filterByPhone(
        _ phone: String?,
        bankId: String?
    ) -> Payments.ParameterSelectBank{
    
        let banksByPhone = paymentsByPhone.value[phone?.digits ?? ""]?
            .sorted(by: { $0.defaultBank && $1.defaultBank })
        
        let defaultBank = paymentsByPhone.value[phone?.digits ?? ""]?
            .filter { $0.defaultBank == true }.first
        
        let banksID = banksByPhone?
            .compactMap({ $0.bankId })
        
        let options = self.reduceBanks(
            bankList: bankList.value.filter { $0.bankCountry == "RU" } ,
            preferred: banksID ?? [],
            defaultBankId: defaultBank?.bankId
        )

        let bankParameterId = Payments.Parameter.Identifier.sfpBank.rawValue
        return Payments.ParameterSelectBank(
            .init(id: bankParameterId, value: bankId),
            icon: .iconPlaceholder,
            title: "Банк получателя",
            options: options,
            placeholder: "Начните ввод для поиска",
            selectAll: .init(type: .banks),
            keyboardType: .normal
        )
    }
    
    func productWithSource(source: Payments.Operation.Source?, productId: String) -> String? {
    
        switch source {
        case let .template(templateID):
            let template = paymentTemplates.value.first { $0.id == templateID }
            return template?.payerProductId?.description
            
        default:
            return productId
        }
    }
    
    private func reduceBanks(
        bankList: [BankData],
        preferred: [String],
        defaultBankId: String?
    ) -> [Payments.ParameterSelectBank.Option] {
        
        let preferredBanks = preferred.compactMap { bankId in bankList.first(where: { $0.id == bankId }) }
        
        return preferredBanks
            .filter { $0.bankType == .sfp }
            .map { item in
                Payments.ParameterSelectBank.Option(
                    id: item.id,
                    name: item.memberNameRus,
                    subtitle: nil,
                    icon: .init(with: item.svgImage),
                    isFavorite: item.id == defaultBankId,
                    searchValue: item.memberNameRus
                )
            }
    }
    
    private static let phoneInput = Payments.ParameterInputPhone(
        .init(id: Payments.Parameter.Identifier.sfpPhone.rawValue, value: nil),
        title: "Номер телефона получателя",
        countryCode: .russian
    )
}
