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
            
            // phone
            let phoneParameterId = Payments.Parameter.Identifier.sfpPhone.rawValue
            let phoneParameterIcon = ImageData(named: "ic24Smartphone") ?? .parameterSample
            let phoneParameter = Payments.ParameterInput(.init(id: phoneParameterId, value: nil), icon: phoneParameterIcon, title: "Номер телефона получателя", validator: .init(minLength: 8, maxLength: nil, regEx: nil), actionButtonType: .contact)
            
            // bank
            let bankParameterId = Payments.Parameter.Identifier.sfpBank.rawValue
            let bankParameter = Payments.ParameterSelect(.init(id: bankParameterId, value: nil), title: "Банк получателя", options: [], type: .banks)
            
            // product
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            guard let productId = firstProductId(of: .card, currency: .rub) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            let productParameter = Payments.ParameterProduct(value: String(productId), isEditable: true)
            
            //message
            let messageParameterId = Payments.Parameter.Identifier.sfpMessage.rawValue
            let messageParameterIcon = ImageData(named: "ic24IconMessage") ?? .parameterSample
            let messageParameter = Payments.ParameterInput(.init(id: messageParameterId, value: nil), icon: messageParameterIcon, title: "Сообщение получателю", validator: .init(minLength: 0, maxLength: nil, regEx: nil))
            
            // amount
            let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
            let amountParameter = Payments.ParameterAmount(value: "0", title: "Сумма", currency: .rub, validator: .init(minAmount: 1, maxAmount: 100000))
            
            return .init(parameters: [operatorParameter, phoneParameter, bankParameter, productParameter, messageParameter, amountParameter], front: .init(visible: [phoneParameterId, bankParameterId, productParameterId, messageParameterId, amountParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [phoneParameterId, bankParameterId, productParameterId], processed: nil))
            
        default:
            throw Payments.Error.unsupported
        }
    }
}

