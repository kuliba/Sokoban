//
//  Model+PaymentsTaxesFNS.swift
//  ForaBank
//
//  Created by Mikhail on 22.02.2022.
//

import Foundation

extension Model {
    
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
                // TODO: Из бека для поля minLength может придти nil
                let unnParameter = Payments.ParameterInput(
                    .init(id: "a3_INN_4_1",
                          value: nil),
                    icon: .parameterSample,
                    title: "ИНН подразделения",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil),
                    collapsable: true)
                
                let oktmoParameter = Payments.ParameterInput(
                    .init(id: "a3_OKTMO_5_1",
                          value: nil),
                    icon: .parameterSample,
                    title: "ОКТМО подразделения",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil),
                    collapsable: true)
                
                completion(.success( parameters + [unnParameter, oktmoParameter]))
                
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
                
                //TODO: Нужна модель для ввода карт
//                let cardParameter = Payments.Parameter
                
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
            
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let operatorSelected = Operator(rawValue: operatorValue) else { return }
            
            switch operatorSelected {
            case .fns:
                
                // "additionalList"
                
                // из предыдущего шага приходят такие же поля ОКТМО и ИНН но уже как Info не понятно как их выпиливать и вставлять новые
                
                // предположение что во всем массиве parameters нужно удалить Payments.ParameterInput
                
                // из бэка для Info приходят 4 поля id, Value, Title и svgImage?
                
                let division0Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientName_6_1", value: "inn_oktmo"),
                    icon: .parameterSample,
                    title: "Получатель платежа:",
                    content: "Управление Федерального казначейства по г. Москве (Инспекция ФНС России № 23 по г.Москве)")
                
                let division1Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientKPP_8_1", value: "inn_oktmo"),
                    icon: .parameterSample,
                    title: "КПП:",
                    content: "772301001")
                
                let division2Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientAccount_9_1", value: "inn_oktmo"),
                    icon: .parameterSample,
                    title: "Расчетный счет:",
                    content: "03100643000000017300")
                
                let division3Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientBankName_10_1", value: "inn_oktmo"),
                    icon: .parameterSample,
                    title: "Банк получателя:",
                    content: "ГУ БАНКА РОССИИ ПО ЦФО//УФК ПО Г. МОСКВЕ г. Москва")
                
                let division4Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientBIC_11_1", value: "inn_oktmo"),
                    icon: .parameterSample,
                    title: "БИК:",
                    content: "004525988")
                
                let division5Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientKBK_13_1", value: "inn_oktmo"),
                    icon: .parameterSample,
                    title: "КБК:",
                    content: "18210606041031000110")
                
                // parameterListForNextStep
                
                // ParameterName =  "inputFieldType": "NAME"
                let fioParameter = Payments.ParameterName(
                    .init(id: "fio", value: "fio"),
                    title: "ФИО:",
                    lastName: .init(title: "Фамилия", value: "Иванов"),
                    firstName: .init(title: "Имя", value: "Иван"),
                    middleName: .init(title: "Отчество", value: "Петрович"))
                
                // "inputFieldType": "ADDRESS"
                let adressParameter = Payments.ParameterInput(
                    .init(id: "a3_address_2_2",
                          value: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 432011, Ульяновская обл, Ульяновск г, Радищева ул ,  д. 124,  кв. 28"),
                    icon: .parameterSample,
                    title: "Адрес:",
                    validator: .init(minLength: 0, maxLength: nil, regEx: nil),
                    collapsable: true)
                
                let docParameter = Payments.ParameterSelectSimple(
                    .init(id: "a3_docType_3_2", value: "2"),
                    icon: .parameterSample,
                    title: "Тип документа:",
                    selectionTitle: "Тип документа:",
                    description: nil,
                    options: [ .init(id: "2", name: "ИНН") ])
                
                let numDocParameter = Payments.ParameterInput(
                    .init(id: "a3_docValue_4_2",
                          value: nil),
                    icon: .parameterSample,
                    title: "Номер документа:",
                    validator: .init(minLength: 0, maxLength: nil, regEx: nil),
                    collapsable: true)
                
                completion(.success( parameters + [division0Parameter, division1Parameter, division2Parameter, division3Parameter, division4Parameter, division5Parameter, fioParameter, adressParameter, docParameter, numDocParameter]))
                
            case .fnsUin:
                
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
                
            default:
                break
            }
            
            
        case 3:
             
            
            //TODO: добавить в список параметер final
            
            
            break
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
    
}
