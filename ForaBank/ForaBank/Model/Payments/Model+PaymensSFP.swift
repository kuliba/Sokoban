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
            let phoneParameterIcon = ImageData(named: "ic24Smartphone") ?? .parameterSample
            let phoneParameter = Payments.ParameterInput(.init(id: phoneParameterId, value: nil), icon: phoneParameterIcon, title: "Номер телефона получателя", validator: .init(minLength: 8, maxLength: nil, regEx: nil), actionButtonType: .contact)
            
            // bank
            let bankParameterId = Payments.Parameter.Identifier.sfpBank.rawValue
            let bankParameter = Payments.ParameterSelect(.init(id: bankParameterId, value: nil), title: "Банк получателя", options: [], type: .banks)
            
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
            let messageParameter = Payments.ParameterInput(.init(id: messageParameterId, value: nil), icon: messageParameterIcon, title: "Сообщение получателю", validator: .init(minLength: 0, maxLength: nil, regEx: nil))
            
            // amount
            let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
            let amountParameter = Payments.ParameterAmount(value: "0", title: "Сумма перевода", currencySymbol: currencySymbol, validator: .init(minAmount: 0.01, maxAmount: product.balance))
            
            return .init(parameters: [operatorParameter, headerParameter, phoneParameter, bankParameter, productParameter, messageParameter, amountParameter], front: .init(visible: [headerParameter.id, phoneParameterId, bankParameterId, productParameterId, messageParameterId, amountParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [phoneParameterId, bankParameterId, productParameterId], processed: nil))
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    // update parameter value with source
    func paymentsProcessSourceReducerSFP(phone: String, bankId: BankData.ID, parameterId: Payments.Parameter.ID) -> Payments.Parameter.Value? {

        switch parameterId {
        case Payments.Parameter.Identifier.sfpPhone.rawValue:
            return phone
            
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
            
            let bankParameterId = Payments.Parameter.Identifier.sfpBank.rawValue
            if let bankParameter = parameters.first(where: { $0.id == bankParameterId }),
               let bankParameterValue = bankParameter.value,
               isForaBank(bankId: bankParameterValue) == true {
                
                return Payments.ParameterAmount(value: amountParameter.value, title: "Сумма перевода", currencySymbol: currencySymbol, validator: .init(minAmount: 0.01, maxAmount: maxAmount), info: .action(title: "Без комиссии", .name("ic24Info"), .feeInfo))
                
            } else {
                
                return Payments.ParameterAmount(value: amountParameter.value, title: "Сумма перевода", currencySymbol: currencySymbol, validator: .init(minAmount: 0.01, maxAmount: maxAmount), info: .action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo))
            }

        case Payments.Parameter.Identifier.header.rawValue:
            let codeParameterId = Payments.Parameter.Identifier.code.rawValue
            let parametersIds = parameters.map{ $0.id }
            guard parametersIds.contains(codeParameterId) else {
                return nil
            }
            return Payments.ParameterHeader(title: "Подтвердите реквизиты", icon: .name("ic24Sbp"))
            
        default:
            return nil
        }
    }
    
    // map additional data
    func paymentsParameterRepresentableSFP(_ operation: Payments.Operation, adittionalData: TransferAnywayResponseData.AdditionalData) throws -> PaymentsParameterRepresentable? {
        
        switch adittionalData.fieldName {
        case Payments.Parameter.Identifier.sftRecipient.rawValue:
            return Payments.ParameterInfo(
                .init(id: adittionalData.fieldName, value: adittionalData.fieldValue),
                icon: ImageData(named: "ic24Customer") ?? .parameterDocument,
                title: adittionalData.fieldTitle, placement: .feed)
            
        case Payments.Parameter.Identifier.sfpAmount.rawValue:
            guard let amountStringValue = adittionalData.fieldValue,
                  let amountValue = Double(amountStringValue),
                  let amountFormatted = paymentsAmountFormatted(amount: amountValue, parameters: operation.parameters) else {
                return nil
            }

            return Payments.ParameterInfo(
                .init(id: adittionalData.fieldName, value: amountFormatted),
                icon: ImageData(named: "ic24Coins") ?? .parameterDocument,
                title: adittionalData.fieldTitle, placement: .feed)

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

        return [Payments.Parameter.Identifier.header.rawValue,
                Payments.Parameter.Identifier.sfpPhone.rawValue,
                Payments.Parameter.Identifier.sftRecipient.rawValue,
                Payments.Parameter.Identifier.sfpBank.rawValue,
                Payments.Parameter.Identifier.sfpAmount.rawValue,
                Payments.Parameter.Identifier.fee.rawValue,
                Payments.Parameter.Identifier.code.rawValue]
    }
    
    // debug mock
    func paymentsMockSFP() -> Payments.Mock {
        
        return .init(service: .sfp,
                     parameters: [.init(id: Payments.Parameter.Identifier.sfpPhone.rawValue, value: "+7 0115110217"),
                                  .init(id: Payments.Parameter.Identifier.sfpBank.rawValue, value: "1crt88888881")])
    }
}

