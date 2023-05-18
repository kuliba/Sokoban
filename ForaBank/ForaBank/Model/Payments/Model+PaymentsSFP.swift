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
            let headerParameter = Payments.ParameterHeader(title: "Перевод по номеру телефона", icon: .name("ic24Sbp"))
            
            // phone
            let phoneParameterId = Payments.Parameter.Identifier.sfpPhone.rawValue
            let phoneParameter = Payments.ParameterInputPhone(.init(id: phoneParameterId, value: nil), title: "Номер телефона получателя", countryCode: .russian)
            
            // bank
            let bankParameterId = Payments.Parameter.Identifier.sfpBank.rawValue
            
            let options = self.bankList.value.map( { Payments.ParameterSelectBank.Option(id: $0.id, name: $0.memberNameRus, subtitle: nil, icon: .init(with: $0.svgImage), searchValue: $0.memberNameRus)} )

            let bankParameter = Payments.ParameterSelectBank(.init(id: bankParameterId, value: nil), icon: .iconPlaceholder, title: "Банк получателя", options: options, placeholder: "Начните ввод для поиска", selectAll: .init(type: .banks), keyboardType: .normal)
            
            // product
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            let filter = ProductData.Filter.generalFrom
            guard let product = firstProduct(with: filter),
                  let currencySymbol = dictionaryCurrencySymbol(for: product.currency) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            let productParameter = Payments.ParameterProduct(value: String(product.id), filter: filter, isEditable: true)
            
            //message
            let messageParameterId = Payments.Parameter.Identifier.sfpMessage.rawValue
            let messageParameterIcon = ImageData(named: "ic24IconMessage") ?? .parameterSample
            let messageParameter = Payments.ParameterInput(.init(id: messageParameterId, value: nil), icon: messageParameterIcon, title: "Сообщение получателю", validator: .anyValue)
            
            // amount
            let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
            let amountParameter = Payments.ParameterAmount(value: "0", title: "Сумма перевода", currencySymbol: currencySymbol, validator: .init(minAmount: 0.01, maxAmount: product.balance))
            
            return .init(parameters: [operatorParameter, headerParameter, phoneParameter, bankParameter, productParameter, messageParameter, amountParameter], front: .init(visible: [headerParameter.id, phoneParameterId, bankParameterId, productParameterId, messageParameterId, amountParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [phoneParameterId, bankParameterId], processed: nil))
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    // update parameter value with source
    func paymentsProcessSourceReducerSFP(phone: String, bankId: BankData.ID, parameterId: Payments.Parameter.ID) -> Payments.Parameter.Value? {

        switch parameterId {
        case Payments.Parameter.Identifier.sfpPhone.rawValue:
            //FIXME: fix on server for latest operations and remove this
            if phone.digits.prefix(1) != "7" {
                
                return "+7\(phone.digits)"
                
            } else {
                
                return "+\(phone.digits)"
            }
            
        case Payments.Parameter.Identifier.sfpBank.rawValue:
            return bankId
            
        default:
            return nil
        }
    }
    
    // update depependend parameters
    func paymentsProcessDependencyReducerSFP(parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
        
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
            
            return .remote(.complete)
            
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
                icon: ImageData(named: "ic24Customer") ?? .parameterDocument,
                title: "Получатель", placement: .feed)
            
            parameters.append(customerParameter)
        }

        if let amountValue = response.debitAmount,
              let amountFormatted = paymentsAmountFormatted(amount: amountValue, parameters: operation.parameters) {
            
            let amountParameterId = Payments.Parameter.Identifier.sfpAmount.rawValue
            let amountParameter = Payments.ParameterInfo(
                .init(id: amountParameterId, value: amountFormatted),
                icon: ImageData(named: "ic24Coins") ?? .parameterDocument,
                title: "Сумма перевода", placement: .feed)
            
            parameters.append(amountParameter)
        }
        
        if let feeAmount = response.fee,
           let feeAmountFormatted = paymentsAmountFormatted(amount: feeAmount, parameters: operation.parameters) {
            
            let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
            let feeParameter = Payments.ParameterInfo(
                .init(id: feeParameterId, value: feeAmountFormatted),
                icon: .init(named: "ic24PercentCommission") ?? .parameterDocument,
                title: "Комиссия", placement: .feed)
            
            parameters.append(feeParameter)
        }
        
        if response.needOTP == true {
            
            parameters.append(Payments.ParameterCode.regular)
            
            return .init(parameters: parameters, front: .init(visible: parameters.map({ $0.id }), isCompleted: false), back: .init(stage: .remote(.confirm), required: [], processed: nil))
            
        } else {
            
            return .init(parameters: parameters, front: .init(visible: parameters.map({ $0.id }), isCompleted: false), back: .init(stage: .remote(.next), required: [], processed: nil))
        }
    }
    
    // map additional data
    func paymentsParameterRepresentableSFP(_ operation: Payments.Operation, adittionalData: TransferAnywayResponseData.AdditionalData) throws -> PaymentsParameterRepresentable? {
        
        switch adittionalData.fieldName {
        case Payments.Parameter.Identifier.sftRecipient.rawValue:
            return Payments.ParameterInfo(
                .init(id: adittionalData.fieldName, value: adittionalData.fieldValue),
                icon: ImageData(named: "ic24Customer") ?? .parameterDocument,
                title: adittionalData.fieldTitle ?? "", placement: .feed) //FIXME: fix unwrap optional title
            
        case Payments.Parameter.Identifier.sfpAmount.rawValue:
            guard let amountStringValue = adittionalData.fieldValue,
                  let amountValue = Double(amountStringValue),
                  let amountFormatted = paymentsAmountFormatted(amount: amountValue, parameters: operation.parameters) else {
                return nil
            }

            return Payments.ParameterInfo(
                .init(id: adittionalData.fieldName, value: amountFormatted),
                icon: ImageData(named: "ic24Coins") ?? .parameterDocument,
                title: adittionalData.fieldTitle ?? "", placement: .feed) //FIXME: fix unwrap optional title
            
        case Payments.Parameter.Identifier.sfpAntifraud.rawValue:
            return Payments.ParameterInfo(
                .init(id: adittionalData.fieldName, value: adittionalData.fieldValue),
                icon: .parameterDocument,
                title: adittionalData.fieldTitle ?? "", placement: .feed) //FIXME: fix unwrap optional title

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
    func paymentsMockSFP() -> Payments.Mock {
        
        return .init(service: .sfp,
                     parameters: [.init(id: Payments.Parameter.Identifier.sfpPhone.rawValue, value: "+7 0115110217"),
                                  .init(id: Payments.Parameter.Identifier.sfpBank.rawValue, value: "1crt88888881")])
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
