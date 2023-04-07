//
//  Model+ChangeAbroad.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 24.03.2023.
//

import Foundation

extension Model {
    
    func paymentsStepChangePayment(_ operation: Payments.Operation, for stepIndex: Int) async throws -> Payments.Operation.Step {
        
        switch stepIndex {
        case 0:
            guard let source = operation.source else {
                throw Payments.Error.unsupported
            }
            
            switch source {
            case let .change(operationId: opetationId, transferNumber: number, name: name):
             
                // header
                let headerParameter = Payments.ParameterHeader(title: "Изменение перевода", subtitle: "Денежные переводы CONTACT", icon: .name("Operation Type Contact Icon"))
                
                //number payment
                let numberPaymentParameter = Payments.ParameterInput(.init(id: Payments.Parameter.Identifier.countryReturnNumber.rawValue, value: number), icon: .parameterHash, title: "Номер перевода", hint: nil, info: nil, validator: .init(rules: []), limitator: nil, isEditable: false, placement: .feed, inputType: .number, group: nil)
                
                //name
                let firstName = Payments.ParameterName.name(with: name, index: 1)
                let middleName = Payments.ParameterName.name(with: name, index: 2)
                let lastName = Payments.ParameterName.name(with: name, index: 0)

                let nameParameter = Payments.ParameterName(.init(id: Payments.Parameter.Identifier.countryReturnName.rawValue, value: name), title: "ФИО получателя", lastName: .init(title: "Фамилия получателя*", value: lastName, validator: .init(rules: []), limitator: .init(limit: 200)), firstName: .init(title: "Имя получателя*", value: firstName, validator: .init(rules: []), limitator: .init(limit: 200)), middleName: .init(title: "Отчество получателя (если есть)", value: middleName, validator: .init(rules: []), limitator: .init(limit: 200)), isEditable: true, mode: .abroad, group: nil)
                
                let operationId = Payments.ParameterHidden(id: Payments.Parameter.Identifier.countryOperationId.rawValue, value: opetationId)
                
                return .init(parameters: [headerParameter, numberPaymentParameter, nameParameter, operationId], front: .init(visible: [headerParameter.id, numberPaymentParameter.id, nameParameter.id, operationId.id], isCompleted: false), back: .init(stage: .remote(.complete), required: [numberPaymentParameter.id, nameParameter.id, operationId.id], processed: nil))
                
            default:
                throw Payments.Error.unsupported
                
            }
            
        default:
            
            throw Payments.Error.unsupported
        }
    }
}
