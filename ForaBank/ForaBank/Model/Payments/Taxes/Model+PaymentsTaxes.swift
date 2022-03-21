//
//  Model+PaymentsTaxes.swift
//  ForaBank
//
//  Created by Max Gribov on 21.03.2022.
//

import Foundation

extension Model {
    
    func paymentsTaxesNextStepParameters(for transferData: TransferAnywayResponseData, samples: [String: String] = [:]) -> [ParameterRepresentable] {
        
        var parameters = [ParameterRepresentable]()
        
        for parameter in transferData.parameterListForNextStep {
            
            let parameterValue = samples[parameter.id] ?? parameter.value
            
            switch parameter.id {
            case "a3_categorySelect_3_1":
                guard let categoryParameterOptions = parameter.options else {
                    continue
                }
                let result = Payments.ParameterSelectSimple(
                    Parameter(id: parameter.id, value: parameterValue ?? categoryParameterOptions.first?.id),
                    icon: parameter.iconData ?? .parameterSample,
                    title: parameter.title,
                    selectionTitle: "Выберете категорию",
                    options: categoryParameterOptions, autoContinue: false)
                parameters.append(result)
                
            case "a3_INN_4_1":
                let result = Payments.ParameterInput(
                    .init(id: parameter.id, value: parameterValue),
                    icon: parameter.iconData ?? .parameterDocument,
                    title: parameter.title,
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                parameters.append(result)
                
            case "a3_OKTMO_5_1":
                let result = Payments.ParameterInput(
                    .init(id: parameter.id, value: parameterValue),
                    icon: parameter.iconData ?? .parameterDocument,
                    title: parameter.title,
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                parameters.append(result)
                
            case "a3_DIVISION_4_1":
                let result = Payments.ParameterInput(
                    .init(id: parameter.id, value: parameterValue),
                    icon: parameter.iconData ?? .parameterDocument,
                    title: parameter.title,
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                parameters.append(result)
                
            case "a3_fio_1_2":
                let result = Payments.ParameterName(id: parameter.id, value: parameterValue, title: parameter.title)
                parameters.append(result)
                
            case "a3_address_2_2":
                let result = Payments.ParameterInfo(
                    .init(id: parameter.id, value: parameterValue),
                    icon: parameter.iconData ?? .parameterLocation,
                    title: "Адрес проживания")
                parameters.append(result)
                
            case "a3_docType_3_2":
                let result = Payments.ParameterSelectSimple(
                    Parameter(id: parameter.id, value: parameterValue),
                    icon: parameter.iconData ?? .parameterSample,
                    title: parameter.title,
                    selectionTitle: "Выберете тип документа",
                    options: parameter.options ?? [], autoContinue: false)
                parameters.append(result)
                
            case "a3_docValue_4_2":
                let result = Payments.ParameterInput(
                    .init(id: parameter.id, value: parameterValue),
                    icon: parameter.iconData ?? .parameterDocument,
                    title: parameter.title,
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                parameters.append(result)
                
            default:
                continue
            }
        }
        
        if transferData.needSum == true {
            
            parameters.append(Payments.ParameterCard())
            
            let amountParameter = Payments.ParameterAmount(
                .init(id: Payments.Parameter.Identifier.amount.rawValue, value: nil),
                title: "Сумма перевода",
                currency: .init(description: "RUB"),
                validator: .init(minAmount: 10))
            parameters.append(amountParameter)
        }
        
        if transferData.finalStep == true {
            
            let codeParameter = Payments.ParameterInput(
                .init(id: Payments.Parameter.Identifier.code.rawValue, value: nil),
                icon: .parameterSMS,
                title: "Введите код из СМС", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
            parameters.append(codeParameter)
            
            parameters.append(Payments.ParameterFinal())
        }
        
        return parameters
    }
}
