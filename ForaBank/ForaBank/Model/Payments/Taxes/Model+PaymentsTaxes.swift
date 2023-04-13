//
//  Model+PaymentsTaxes.swift
//  ForaBank
//
//  Created by Max Gribov on 21.03.2022.
//

import Foundation

extension Model {
    
    func paymentsParameterRepresentableTaxes(operation: Payments.Operation, parameterData: ParameterData) throws -> PaymentsParameterRepresentable? {
        
        switch parameterData.id {
        case "a3_categorySelect_3_1":
            guard let options = parameterData.options(style: .general) else {
                throw Payments.Error.missingOptions(parameterData)
            }
            return Payments.ParameterSelect(
                .init(id: parameterData.id, value: parameterData.value),
                icon: .image(parameterData.iconData ?? .parameterSample),
                title: parameterData.title,
                placeholder: "Начните ввод для поиска",
                options: options.map({ .init(id: $0.id, name: $0.name)}))
            
        case "a3_INN_4_1", "a3_docValue_4_2":
            let validator = Payments.Validation.RulesSystem(rules: [
                Payments.Validation.LengthLimitsRule(lengthLimits: [10, 12], actions: [.post: .warning("Должен состоять из 10 или 12 цифр")])
            ])
            return Payments.ParameterInput(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterDocument,
                title: parameterData.title,
                validator: validator,
                inputType: .number)
            
        case "a3_OKTMO_5_1":
            let validator = Payments.Validation.RulesSystem(rules: [
                Payments.Validation.LengthLimitsRule(lengthLimits: [8, 11], actions: [.post: .warning("Должен состоять из 8 или 11 цифр")])
            ])
            return Payments.ParameterInput(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterDocument,
                title: parameterData.title,
                validator: validator,
                inputType: .number)
            
        case "a3_fio_1_2", "a3_fio_4_1":
            return Payments.ParameterName(id: parameterData.id, value: parameterData.value, title: parameterData.title)

        case "a3_address_2_2", "a3_address_10_1", "a3_address_4_2", "a3_address_4_3":
            return Payments.ParameterInfo(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterLocation,
                title: "Адрес проживания")
            
        case "a3_docType_3_2", "a3_docName_1_1":
            guard let options = parameterData.options(style: .general) else {
                throw Payments.Error.missingOptions(parameterData)
            }
            return Payments.ParameterSelect(
                Payments.Parameter(id: parameterData.id, value: parameterData.value),
                icon: .image(parameterData.iconData ?? .parameterSample),
                title: parameterData.title,
                placeholder: "Начните ввод для поиска",
                options: options.map({.init(id: $0.id, name: $0.name)}))
            
        case "a3_BillNumber_1_1":
            let validator = Payments.Validation.RulesSystem(rules: [
                Payments.Validation.LengthLimitsRule(lengthLimits: [20, 25], actions: [.post: .warning("Должен состоять из 20 или 25 цифр")])
            ])
            
            return Payments.ParameterInput(
                Payments.Parameter(id: parameterData.id, value: parameterData.value),
                icon: .parameterDocument,
                title: "УИН",
                validator: validator,
                inputType: .number)
            
        case "a3_IPnumber_1_1":
            let validator = Payments.Validation.RulesSystem(rules: [
                Payments.Validation.RegExpRule(regExp: "^[0-9]{1,7}[/][0-9]{2}[/][0-9]{2}[/][0-9]{2}$|^[0-9]{1,7}[/][0-9]{2}[/][0-9]{5}-ИП$", actions: [.post: .warning("Пример: 1108/10/41/33 или 107460/09/21014-И")])
            ])
            
            return Payments.ParameterInput(
                Payments.Parameter(id: parameterData.id, value: parameterData.value),
                icon: .parameterDocument,
                title: "Номер ИП",
                validator: validator)
            
        default:
            return nil
        }
    }
}
