//
//  Model+PaymentsTaxesFMSMock.swift
//  ForaBank
//
//  Created by Max Gribov on 21.03.2022.
//

import Foundation

extension Model {
    
    func parametersFMSMock(_ parameters: [PaymentsParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[PaymentsParameterRepresentable], Error>) -> Void) {
        
        switch step {
        case 0:
            
            // operator
            let operatorParameter = Payments.ParameterOperator(operatorType: .fms)
            
            // category
            let categoryParameter = Payments.ParameterSelect(
                Payments.Parameter(id: "a3_dutyCategory_1_1", value: nil),
                title: "Категория платежа",
                options: [
                    .init(id: "1", name: "Российский паспорт", icon: .parameterSample),
                    .init(id: "2", name: "Виза", icon: .parameterSample),
                    .init(id: "3", name: "Загран паспорт", icon: .parameterSample),
                    .init(id: "4", name: "Разрешения", icon: .parameterSample),
                    .init(id: "5", name: "Бюджет (поступления/возврат)", icon: .parameterSample),
                    .init(id: "6", name: "Штрафы", icon: .parameterSample)])
            
            completion(.success( parameters + [operatorParameter, categoryParameter]))
            
        case 1:
            
            if let divisionParameter = parameters.first(where: { $0.parameter.id == "a3_divisionSelect_2_1" }),
               let divisionValue = divisionParameter.parameter.value {
                
                // remove division parameters
                var updatedParameters = [PaymentsParameterRepresentable]()
                for parameter in parameters {
                    
                    switch parameter.parameter.id {
                    case "a3_INN_4_1", "a3_OKTMO_5_1", "a3_NUMBER_4_1":
                        continue
                        
                    default:
                        updatedParameters.append( parameter)
                    }
                }
                
                switch divisionValue {
                case "inn_oktmo":
                    let unnParameter = Payments.ParameterInput(
                        .init(id: "a3_INN_4_1", value: nil),
                        icon: .parameterSample,
                        title: "ИНН подразделения",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    let oktmoParameter = Payments.ParameterInput(
                        .init(id: "a3_OKTMO_5_1", value: nil),
                        icon: .parameterSample,
                        title: "ОКТМО подразделения",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    completion(.success(updatedParameters + [unnParameter, oktmoParameter]))
                    
                case "number":
                    
                    let numberParameter = Payments.ParameterInput(
                        .init(id: "a3_NUMBER_4_1", value: nil),
                        icon: .parameterSample,
                        title: "Номер подразделения",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    completion(.success(updatedParameters + [numberParameter]))
                    
                default:
                    completion(.failure(Payments.Error.unexpectedOperatorValue))
                }
                
            } else {
                
                // division
                let divisionParameter = Payments.ParameterSelectSimple(
                    Payments.Parameter(id: "a3_divisionSelect_2_1", value: "inn_oktmo"),
                    icon: .parameterSample,
                    title: "Данные о подразделении ФНС",
                    selectionTitle: "Выберете услугу",
                    options: [
                        .init(id: "inn_oktmo", name: "ИНН и ОКТМО подразделения"),
                        .init(id: "number", name: "Номер подразделения")])
                
                let unnParameter = Payments.ParameterInput(
                    .init(id: "a3_INN_4_1", value: "7878787878"),
                    icon: .parameterSample,
                    title: "ИНН подразделения",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                
                let oktmoParameter = Payments.ParameterInput(
                    .init(id: "a3_OKTMO_5_1", value: nil),
                    icon: .parameterSample,
                    title: "ОКТМО подразделения",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                
                completion(.success( parameters + [divisionParameter, unnParameter, oktmoParameter]))
            }
            
        case 2:
            
            var updatedParameters = [PaymentsParameterRepresentable]()
            for parameter in parameters {
                
                switch parameter.parameter.id {
                case "a3_INN_4_1", "a3_OKTMO_5_1", "a3_NUMBER_4_1":
                    break
//                    updatedParameters.append(parameter.updated(isEditable: false))
                    
                default:
                    updatedParameters.append( parameter)
                }
            }
            
            //  service
            let serviceParameter = Payments.ParameterSelectSimple(
                Payments.Parameter(id: "a3_categorySelect_3_1", value: nil),
                icon: .parameterSample,
                title: "Тип услуги",
                selectionTitle: "Выберете услугу",
                description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ",
                options: [
                    .init(id: "1", name: "В возрасте от 14 лет"),
                    .init(id: "2", name: "В возрасте до 14 лет"),
                    .init(id: "3", name: "В возрасте до 14 лет (новый образец)"),
                    .init(id: "4", name: "Содержащего электронный носитель информации (паспорта нового поколения)"),
                    .init(id: "4", name: "За внесение изменений в паспорт")])
            
            completion(.success( updatedParameters + [serviceParameter]))
            
        case 3:
            
            let productParameter = Payments.ParameterProduct()
            
            let amountParameter = Payments.ParameterAmount(
                .init(id: Payments.Parameter.Identifier.amount.rawValue, value: "1234"),
                title: "Сумма перевода",
                currency: .init(description: "RUB"),
                validator: .init(minAmount: 10, maxAmount: 1000))
            
            completion(.success( parameters + [productParameter, amountParameter]))
            
        case 4:
            // make all parameters not editable
            var updatedParameters = [PaymentsParameterRepresentable]()
            for parameter in parameters {
                
//                updatedParameters.append(parameter.updated(isEditable: false))
            }
            
            let codeParameter = Payments.ParameterInput(
                .init(id: Payments.Parameter.Identifier.code.rawValue, value: nil),
                icon: .parameterSMS,
                title: "Введите код из СМС", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
            
            //TODO: refactor
//            let finalParameter = Payments.ParameterFinal()
            
//            completion(.success(updatedParameters + [codeParameter, finalParameter]))
            
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
    
}
