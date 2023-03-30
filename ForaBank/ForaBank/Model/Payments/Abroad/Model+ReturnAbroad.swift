//
//  Model+ReturnAbroad.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 24.03.2023.
//

import Foundation

extension Model {
    
    func paymentsStepReturnPayment(_ operation: Payments.Operation, for stepIndex: Int) async throws -> Payments.Operation.Step {
        
        switch stepIndex {
        case 0:
            guard let source = operation.source else {
                throw Payments.Error.unsupported
            }
            
            switch source {
            case let .return(operationId: operationId, transferNumber: number, amount: amount):
             
                // header
                let headerParameter = Payments.ParameterHeader(title: "Возврат перевода", subtitle: "Денежные переводы CONTACT", icon: .name("Operation Type Contact Icon"))
                
                //number payment
                let numberPaymentParameter = Payments.ParameterInput(.init(id: Payments.Parameter.Identifier.countryReturnNumber.rawValue, value: number), icon: .parameterHash, title: "Номер перевода", hint: nil, info: nil, validator: .init(rules: []), limitator: nil, isEditable: false, placement: .feed, inputType: .number, group: nil)
                
                //amount
                let amountParameter = Payments.ParameterInfo(.init(id: Payments.Parameter.Identifier.countryReturnAmount.rawValue, value: amount), icon: .empty, title: "Сумма возврата", placement: .feed, group: .init(id: "info", type: .info))
                
                let operationId = Payments.ParameterHidden(id: Payments.Parameter.Identifier.countryOperationId.rawValue, value: operationId)

                let product = Payments.ParameterProduct(value: self.firstProduct(with: .generalTo)?.id.description, filter: .generalTo, isEditable: false)
                
                return .init(parameters: [headerParameter, numberPaymentParameter, amountParameter, operationId, product], front: .init(visible: [headerParameter.id, numberPaymentParameter.id, amountParameter.id, operationId.id, product.id], isCompleted: false), back: .init(stage: .remote(.complete), required: [numberPaymentParameter.id, amountParameter.id, operationId.id], processed: nil))
                
            default:
                throw Payments.Error.unsupported
                
            }
        default:
            
            throw Payments.Error.unsupported
        }
    }
}
