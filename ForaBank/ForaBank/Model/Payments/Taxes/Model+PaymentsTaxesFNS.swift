//
//  Model+PaymentsTaxesFNS.swift
//  ForaBank
//
//  Created by Mikhail on 22.02.2022.
//

import Foundation

extension Model {
    
    func asdafssa(amount: String, code: String?, asfsadf: String?) {
        switch(amount, code, asfsadf) {
            
        case (_, let code , let asdsa):
            print(code)
            
        case (let amount, let code , _):
            print(amount)

//        default:
//            break
        }
    }
    
    
    func parametersFNS(_ parameters: [ParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[ParameterRepresentable], Error>) -> Void) {
        
        let paramOperator = Payments.Parameter.Identifier.operator.rawValue
        let paramCategory = "a3_dutyCategory_1_1"
        let paramDivision = "a3_divisionSelect_2_1"
        let paramService = "a3_categorySelect_3_1"
        let paramDivisionINN = "a3_INN_4_1"
        let paramDivisionOKTMO = "a3_OKTMO_5_1"
        
        switch step {
        case 0:
   
            if let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
               let operatorValue = operatorParameter.parameter.value,
                let operatorSelected = Operator(rawValue: operatorValue) {
                
                switch operatorSelected {
                case .fns:
                    
                    // category
                    let categoryParameter = Payments.ParameterSelect(
                        Parameter(id: paramCategory, value: nil),
                        title: "Категория платежа",
                        options: [
                            .init(id: "1", name: "Имущественный налог", icon: .parameterSample),
                            .init(id: "2", name: "Транспортный налог", icon: .parameterSample),
                            .init(id: "3", name: "Земельный налог", icon: .parameterSample),
                            .init(id: "4", name: "Водный налог", icon: .parameterSample),
                            .init(id: "5", name: "Сбор за пользования объекта животного мира", icon: .parameterSample),
                            .init(id: "6", name: "Сбор за пользование объектами водными биологическими ресурсами", icon: .parameterSample),
                            .init(id: "7", name: "Государственная пошлина", icon: .parameterSample),
                            .init(id: "8", name: "Плата за предоставление информации содержащейся в ЕГРН", icon: .parameterSample),
                            .init(id: "9", name: "Страховые взносы на обязательное пенсионное страхование", icon: .parameterSample),
                            .init(id: "10", name: "Утилизационный сбор", icon: .parameterSample),
                            .init(id: "11", name: "Денежные взыскания (штрафы)", icon: .parameterSample),
                            .init(id: "12", name: "Прочие поступления от денежных взысканий (штрафов) и иных сумм в возмещение ущерба", icon: .parameterSample),
                            .init(id: "13", name: "Налог на доходы физических лиц (НДФЛ)", icon: .parameterSample),
                            .init(id: "14", name: "ЕНВД", icon: .parameterSample),
                            .init(id: "15", name: "НДС", icon: .parameterSample),
                            .init(id: "16", name: "УСН", icon: .parameterSample),
                            .init(id: "17", name: "Страховые взносы", icon: .parameterSample),
                            .init(id: "18", name: "Патенты", icon: .parameterSample)
                        ])
                    completion(.success( parameters + [categoryParameter]))
                    
                case .fnsUin:
                    
                    // category
                    let categoryParameter = Payments.ParameterInput(
                        Parameter(id: paramCategory, value: nil),
                        icon: .parameterSample,
                        title: "УИН",
                        validator: .init(minLength: 2, maxLength: 5, regEx: "[0-9]*"))
                    
                    completion(.success( parameters + [categoryParameter]))
                    
                default:
                    break
                }
                
            } else {
                
                // operator
                let operatorParameter = Payments.ParameterSelectSwitch(
                    .init(id: paramOperator, value: Operator.fns.rawValue),
                    options: [
                        .init(id: Operator.fns.rawValue, name: Operator.fns.name),
                        .init(id: Operator.fnsUin.rawValue, name: Operator.fnsUin.name)
                    ])
                
                // category
                let categoryParameter = Payments.ParameterSelect(
                    Parameter(id: paramCategory, value: nil),
                    title: "Категория платежа",
                    options: [
                        .init(id: "1", name: "Имущественный налог", icon: .parameterSample),
                        .init(id: "2", name: "Транспортный налог", icon: .parameterSample),
                        .init(id: "3", name: "Земельный налог", icon: .parameterSample),
                        .init(id: "4", name: "Водный налог", icon: .parameterSample),
                        .init(id: "5", name: "Сбор за пользования объекта животного мира", icon: .parameterSample),
                        .init(id: "6", name: "Сбор за пользование объектами водными биологическими ресурсами", icon: .parameterSample),
                        .init(id: "7", name: "Государственная пошлина", icon: .parameterSample),
                        .init(id: "8", name: "Плата за предоставление информации содержащейся в ЕГРН", icon: .parameterSample),
                        .init(id: "9", name: "Страховые взносы на обязательное пенсионное страхование", icon: .parameterSample),
                        .init(id: "10", name: "Утилизационный сбор", icon: .parameterSample),
                        .init(id: "11", name: "Денежные взыскания (штрафы)", icon: .parameterSample),
                        .init(id: "12", name: "Прочие поступления от денежных взысканий (штрафов) и иных сумм в возмещение ущерба", icon: .parameterSample),
                        .init(id: "13", name: "Налог на доходы физических лиц (НДФЛ)", icon: .parameterSample),
                        .init(id: "14", name: "ЕНВД", icon: .parameterSample),
                        .init(id: "15", name: "НДС", icon: .parameterSample),
                        .init(id: "16", name: "УСН", icon: .parameterSample),
                        .init(id: "17", name: "Страховые взносы", icon: .parameterSample),
                        .init(id: "18", name: "Патенты", icon: .parameterSample)
                    ])
                
                completion(.success( parameters + [operatorParameter, categoryParameter]))
            }
            
        case 1:
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let operatorSelected = Operator(rawValue: operatorValue) else { return }
            
            switch operatorSelected {
            case .fns:
                
                // division
                let divisionParameter = Payments.ParameterInfo(
                    .init(id: paramDivision, value: "inn_oktmo"),
                    icon: .parameterSample,
                    title: "Адрес получателя",
                    content: "г. Москва, ул. Профсоюзная fns 124")
                
                completion(.success( parameters + [divisionParameter]))
                
            case .fnsUin:
                
                let divisionParameter = Payments.ParameterInfo(
                    .init(id: paramDivision, value: "inn_oktmo"),
                    icon: .parameterSample,
                    title: "Адрес получателя",
                    content: "г. Москва, ул. Профсоюзная fnsUin 124")
                
                let fioParameter = Payments.ParameterName(
                    .init(id: "fio", value: "fio"),
                    title: "ФИО",
                    lastName: .init(title: "Фамилия", value: "Иванов"),
                    firstName: .init(title: "Имя", value: "Иван"),
                    middleName: .init(title: "Отчество", value: "Петрович"))
                
                let unnParameter = Payments.ParameterInput(
                    .init(id: "unn",
                          value: "123456789"),
                    icon: .parameterSample,
                    title: "УНН",
                    validator: .init(minLength: 2, maxLength: 5, regEx: nil),
                    collapsable: true)
                
//                let cardParemertet = Payments.Parameter
                
                let amountParameter = Payments.ParameterAmount(
                    .init(id: "amount", value: "100"),
                    title: "Сумма перевода",
                    currency: .init(description: "RUB"),
                    validator: .init(minAmount: 10))
                
                completion(.success( parameters + [divisionParameter, fioParameter, unnParameter, amountParameter]))
                
            default:
                break
            }
            
        case 2:
            
            //  service
            let serviceParameter = Payments.ParameterSelectSimple(
                .init(id: paramService, value: nil),
                icon: .parameterSample,
                title: "Тип услуги",
                selectionTitle: "Выберете услугу",
                description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ",
                options: [
                    .init(id: "1", name: "В возрасте от 14 лет"),
                    .init(id: "2", name: "В возрасте до 14 лет"),
                    .init(id: "3", name: "В возрасте до 14 лет (новый образец)")])
            
            completion(.success( parameters + [serviceParameter]))
            
        case 3:
                      
            // division INN
            let divisionInnParameter = Payments.ParameterInput(
                .init(id: paramDivisionINN, value: nil),
                icon: .parameterSample,
                title: "ИНН подразделения",
                validator: .init(minLength: 8, maxLength: 8, regEx: nil))
            
            // division OKTMO
            let divisionOktmoParameter = Payments.ParameterInput(
                .init(id: paramDivisionOKTMO, value: nil),
                icon: .parameterSample,
                title: "ОКТМО подзаделения",
                validator: .init(minLength: 6, maxLength: 6, regEx: nil))
            
            completion(.success( parameters + [divisionInnParameter, divisionOktmoParameter]))
            
            
        case 4:
            
            //TODO: добавить в список параметер final
            
            
            break
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
    
}
