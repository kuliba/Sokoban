//
//  Model+PaymentsTaxesFSSPMock.swift
//  ForaBank
//
//  Created by Max Gribov on 30.03.2022.
//

import Foundation

extension Model {
    
    func parametersFSSPMock(_ parameters: [PaymentsParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[PaymentsParameterRepresentable], Error>) -> Void) {
        
        switch step {
        case 0:
            
            if let searchTypeParameter = parameters.first(where: { $0.parameter.id == "a3_SearchType_1_1" }),
                let searchTypeParameterValue = searchTypeParameter.parameter.value  {
                
                var updatedParameters = [PaymentsParameterRepresentable]()
                for parameter in parameters {
                    
                    switch parameter.parameter.id {
                    case "a3_dutyCategory_1_1_document", "a3_docNumber_2_2":
                        continue
                        
                    default:
                        updatedParameters.append( parameter)
                    }
                }
                    
                switch searchTypeParameterValue {
                case "document":
                    let documentParameter = Payments.ParameterSelect(
                        Payments.Parameter(id: "a3_dutyCategory_1_1_document", value: nil),
                        title: "Тип документа",
                        options: [
                            .init(id: "1", name: "Паспорт РФ", icon: .parameterSample),
                            .init(id: "2", name: "ИНН", icon: .parameterSample),
                            .init(id: "3", name: "СНИЛС", icon: .parameterSample),
                            .init(id: "4", name: "Водительское удостоверение", icon: .parameterSample),
                            .init(id: "5", name: "Свидетельство о регистрации ТС (СТС)", icon: .parameterSample)])
                    
                    completion(.success( parameters + [documentParameter]))
                    
                case "uin":
                    let documentNumberParameter = Payments.ParameterInput(
                        .init(id: "a3_docNumber_2_2", value: nil),
                        icon: .parameterDocument,
                        title: "УИН",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    completion(.success( parameters + [documentNumberParameter]))
                    
                case "ip":
                    let documentNumberParameter = Payments.ParameterInput(
                        .init(id: "a3_docNumber_2_2", value: nil),
                        icon: .parameterDocument,
                        title: "ИП",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    completion(.success( parameters + [documentNumberParameter]))
                    
                
                default:
                    completion(.failure(Payments.Error.unexpectedOperatorValue))
                }
             
            } else {
                
                // operator
                let operatorParameter = Payments.ParameterOperator(operatorType: .fssp)
                
                // operator
                let searchTypeParameter = Payments.ParameterSelectSwitch(
                    .init(id: "a3_SearchType_1_1", value: "document"),
                    options: [
                        .init(id: "document", name: "Документ"),
                        .init(id: "uin", name: "УИН"),
                        .init(id: "ip", name: "ИП")
                    ])
                
                let documentParameter = Payments.ParameterSelect(
                    Payments.Parameter(id: "a3_dutyCategory_1_1_document", value: nil),
                    title: "Тип документа",
                    options: [
                        .init(id: "1", name: "Паспорт РФ", icon: .parameterSample),
                        .init(id: "2", name: "ИНН", icon: .parameterSample),
                        .init(id: "3", name: "СНИЛС", icon: .parameterSample),
                        .init(id: "4", name: "Водительское удостоверение", icon: .parameterSample),
                        .init(id: "5", name: "Свидетельство о регистрации ТС (СТС)", icon: .parameterSample)])
                
                completion(.success( parameters + [operatorParameter, searchTypeParameter, documentParameter]))
                
            }
            
        case 1:
            guard let searchTypeParameter = parameters.first(where: { $0.parameter.id == "a3_SearchType_1_1" }),
                let searchTypeParameterValue = searchTypeParameter.parameter.value else {
                    
                    completion(.failure(Payments.Error.unexpectedOperatorValue))
                    return
                }
            
            switch searchTypeParameterValue {
            case "document":
                let documentNumberParameter = Payments.ParameterInput(
                    .init(id: "a3_docNumber_2_2", value: nil),
                    icon: .parameterDocument,
                    title: "Номер документа",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                
                completion(.success( parameters + [documentNumberParameter]))
                
            case "uin", "ip":
                let infoParameter = Payments.ParameterInfo(
                    .init(id: "a3_iComment_6_1", value: "Налог на имущество физических лиц, взимаемый по ставкам, применяемым к объектам налогообложения, расположенным  в границах внутригородских муниципальных образований городов федерального значения (сумма платеж...)"),
                    icon: .parameterSample,
                    title: "Основание")
                
                let fioParameter = Payments.ParameterName(
                    .init(id: "a3_Name_6_1", value: "Иванов Иван Иванович"),
                    title: "ФИО:",
                    lastName: .init(title: "Фамилия", value: "Иванов"),
                    firstName: .init(title: "Имя", value: "Иван"),
                    middleName: .init(title: "Отчество", value: "Петрович"))
                
                let productParameter = Payments.ParameterProduct()
                
                let innParameter = Payments.ParameterInput(
                    .init(id: UUID().uuidString,
                          value: "7726062105"),
                    icon: .parameterDocument,
                    title: "ИНН Получателя",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil),
                    placement: .spoiler)
                
                let oktmoParameter = Payments.ParameterInput(
                    .init(id: UUID().uuidString,
                          value: "20701000"),
                    icon: .parameterHash,
                    title: "ОКТМО (ОКАТО)",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil),
                    placement: .spoiler)
                
                let adressParameter = Payments.ParameterInfo(
                    .init(id: "a3_address_2_2", value: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 432011, Ульяновская обл, Ульяновск г, Радищева ул ,  д. 124,  кв. 28"),
                    icon: .parameterLocation,
                    title: "Адрес проживания", placement: .spoiler)
                
                let amountParameter = Payments.ParameterAmount(
                    .init(id: Payments.Parameter.Identifier.amount.rawValue, value: "1234"),
                    title: "Сумма перевода",
                    currency: .init(description: "RUB"),
                    validator: .init(minAmount: 10, maxAmount: 1000))
                
                completion(.success( parameters + [infoParameter, fioParameter, productParameter, innParameter, oktmoParameter, adressParameter, amountParameter]))
            
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
            
        case 2:
            guard let searchTypeParameter = parameters.first(where: { $0.parameter.id == "a3_SearchType_1_1" }),
                let searchTypeParameterValue = searchTypeParameter.parameter.value else {
                    
                    completion(.failure(Payments.Error.unexpectedOperatorValue))
                    return
                }
            
            switch searchTypeParameterValue {
            case "document":
                let infoParameter = Payments.ParameterInfo(
                    .init(id: "a3_iComment_6_1", value: "Налог на имущество физических лиц, взимаемый по ставкам, применяемым к объектам налогообложения, расположенным  в границах внутригородских муниципальных образований городов федерального значения (сумма платеж...)"),
                    icon: .parameterSample,
                    title: "Основание")
                
                let fioParameter = Payments.ParameterName(
                    .init(id: "a3_Name_6_1", value: "Иванов Иван Иванович"),
                    title: "ФИО:",
                    lastName: .init(title: "Фамилия", value: "Иванов"),
                    firstName: .init(title: "Имя", value: "Иван"),
                    middleName: .init(title: "Отчество", value: "Петрович"))
                
                let productParameter = Payments.ParameterProduct()
                
                let innParameter = Payments.ParameterInput(
                    .init(id: UUID().uuidString,
                          value: "7726062105"),
                    icon: .parameterDocument,
                    title: "ИНН Получателя",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil),
                    placement: .spoiler)
                
                let oktmoParameter = Payments.ParameterInput(
                    .init(id: UUID().uuidString,
                          value: "20701000"),
                    icon: .parameterHash,
                    title: "ОКТМО (ОКАТО)",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil),
                    placement: .spoiler)
                
                let adressParameter = Payments.ParameterInfo(
                    .init(id: "a3_address_2_2", value: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 432011, Ульяновская обл, Ульяновск г, Радищева ул ,  д. 124,  кв. 28"),
                    icon: .parameterLocation,
                    title: "Адрес проживания", placement: .spoiler)
                
                let amountParameter = Payments.ParameterAmount(
                    .init(id: Payments.Parameter.Identifier.amount.rawValue, value: "1234"),
                    title: "Сумма перевода",
                    currency: .init(description: "RUB"),
                    validator: .init(minAmount: 10, maxAmount: 1000))
                
                completion(.success( parameters + [infoParameter, fioParameter, productParameter, innParameter, oktmoParameter, adressParameter, amountParameter]))
                
            case "uin", "ip":
                // make all parameters not editable
                var updatedParameters = [PaymentsParameterRepresentable]()
                for parameter in parameters {
                    
//                    updatedParameters.append(parameter.updated(isEditable: false))
                }
                
                let codeParameter = Payments.ParameterInput(
                    .init(id: Payments.Parameter.Identifier.code.rawValue, value: nil),
                    icon: .parameterSMS,
                    title: "Введите код из СМС", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
                
                //TODO: refactor
//                let finalParameter = Payments.ParameterFinal()
                
//                completion(.success(updatedParameters + [codeParameter, finalParameter]))
            
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
               
        case 3:
            guard let searchTypeParameter = parameters.first(where: { $0.parameter.id == "a3_SearchType_1_1" }),
                let searchTypeParameterValue = searchTypeParameter.parameter.value else {
                    
                    completion(.failure(Payments.Error.unexpectedOperatorValue))
                    return
                }
            
            switch searchTypeParameterValue {
            case "document":
                // make all parameters not editable
                var updatedParameters = [PaymentsParameterRepresentable]()
                for parameter in parameters {
                    
//                    updatedParameters.append(parameter.updated(isEditable: false))
                }
                
                let codeParameter = Payments.ParameterInput(
                    .init(id: Payments.Parameter.Identifier.code.rawValue, value: nil),
                    icon: .parameterSMS,
                    title: "Введите код из СМС", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
                
                //TODO: refactor
//                let finalParameter = Payments.ParameterFinal()
                
//                completion(.success(updatedParameters + [codeParameter, finalParameter]))
            
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }

        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
}
