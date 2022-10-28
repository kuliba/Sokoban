//
//  Model+PaymentsTaxesFNSMock.swift
//  ForaBank
//
//  Created by Max Gribov on 21.03.2022.
//

import Foundation

extension Model {
    
    func parametersFNSMock(_ parameters: [PaymentsParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[PaymentsParameterRepresentable], Error>) -> Void) {
        
        let paramOperator = Payments.Parameter.Identifier.operator.rawValue
     
        switch step {
        case 0:
            
            if let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
               let operatorValue = operatorParameter.parameter.value,
               let operatorSelected = Payments.Operator(rawValue: operatorValue) {
                
                switch operatorSelected {
                case .fns:
                    
                    // category
                    let categoryParameter = Payments.ParameterSelect(
                        Payments.Parameter(id: "a3_dutyCategory_1_1", value: nil),
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
                        Payments.Parameter(id: "a3_BillNumber_1_1", value: nil),
                        icon: .parameterDocument,
                        title: "УИН",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    completion(.success( parameters + [categoryParameter]))
                    
                default:
                    completion(.failure(Payments.Error.unexpectedOperatorValue))
                }
                
            } else {
                
                // operator
                let operatorParameter = Payments.ParameterSelectSwitch(
                    .init(id: paramOperator, value: Payments.Operator.fns.rawValue),
                    options: [
                        .init(id: Payments.Operator.fns.rawValue, name: Payments.Operator.fns.name),
                        .init(id: Payments.Operator.fnsUin.rawValue, name: Payments.Operator.fnsUin.name)
                    ])
                
                // category
                let categoryParameter = Payments.ParameterSelect(
                    Payments.Parameter(id: "a3_dutyCategory_1_1", value: nil),
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
                  let operatorSelected = Payments.Operator(rawValue: operatorValue) else {
                      
                      completion(.failure(Payments.Error.missingOperatorParameter))
                      return
                  }
            
            switch operatorSelected {
            case .fns:
                
                if let divisionParameter = parameters.first(where: { $0.parameter.id == "a3_divisionSelect_2_1" }),
                   let divisionParameterValue = divisionParameter.parameter.value {
                    
                    var updatedParameters = [PaymentsParameterRepresentable]()
                    for parameter in parameters {
                        
                        switch parameter.parameter.id {
                        case "a3_INN_4_1", "a3_OKTMO_5_1", "a3_NUMBER_4_1":
                            continue
                            
                        default:
                            updatedParameters.append( parameter)
                        }
                    }
                    
                    switch divisionParameterValue {
                    case "inn_oktmo":
                        let unnParameter = Payments.ParameterInput(
                            .init(id: "a3_INN_4_1", value: "7723013452"),
                            icon: .parameterDocument,
                            title: "ИНН подразделения",
                            validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                        
                        let oktmoParameter = Payments.ParameterInput(
                            .init(id: "a3_OKTMO_5_1", value: nil),
                            icon: .parameterDocument,
                            title: "ОКТМО подразделения",
                            validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                        
                        completion(.success(updatedParameters + [unnParameter, oktmoParameter]))
                        
                    case "number":
                        let numberParameter = Payments.ParameterInput(
                            .init(id: "a3_NUMBER_4_1", value: nil),
                            icon: .parameterDocument,
                            title: "Номер подразделения",
                            validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                        
                        completion(.success(updatedParameters + [numberParameter]))
                        
                    default:
                        completion(.failure(Payments.Error.unexpectedOperatorValue))
                        
                    }
                    
                } else {
                    
                    // division
                    let divisionParameter = Payments.ParameterSelectSimple(
                        .init(id: "a3_divisionSelect_2_1", value: "inn_oktmo"),
                        icon: .parameterSample, title: "Данные о подразделении ФНС",
                        selectionTitle: "Выберете подразделение",
                        description: nil,
                        options: [.init(id: "inn_oktmo", name: "ИНН и ОКТМО подразделения"),
                                  .init(id: "number", name: "Номер подразделения")])
                    
                    let unnParameter = Payments.ParameterInput(
                        .init(id: "a3_INN_4_1", value: "7723013452"),
                        icon: .parameterDocument,
                        title: "ИНН подразделения",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    let oktmoParameter = Payments.ParameterInput(
                        .init(id: "a3_OKTMO_5_1", value: nil),
                        icon: .parameterDocument,
                        title: "ОКТМО подразделения",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    completion(.success( parameters + [divisionParameter, unnParameter, oktmoParameter]))
                    
                }

            case .fnsUin:
                
                var updatedParameters = [PaymentsParameterRepresentable]()
                for parameter in parameters {
                    
                    switch parameter.parameter.id {
                    case "a3_BillNumber_1_1":
//                        updatedParameters.append(parameter.updated(isEditable: false))
                        break
                        
                    default:
                        updatedParameters.append( parameter)
                    }
                }
                
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
                
                completion(.success( updatedParameters + [infoParameter, fioParameter, productParameter, innParameter, oktmoParameter, adressParameter, amountParameter]))
                
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
            
        case 2:
            
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let operatorSelected = Payments.Operator(rawValue: operatorValue) else {
                      
                      completion(.failure(Payments.Error.missingOperatorParameter))
                      return
                  }
            
            switch operatorSelected {
            case .fns:
                
                let serviceParameter = Payments.ParameterSelectSimple(
                    .init(id: "a3_categorySelect_3_1", value: nil),
                    icon: .parameterSample, title: "Тип услуги",
                    selectionTitle: "Выберете услугу",
                    description: nil,
                    options: [.init(id: "0", name: "Транспортный налог с физических лиц (сумма платежа перерасчеты недоимка и задолженность по соответствующему платежу том числе по отмененному)"),
                              .init(id: "1", name: "Транспортный налог с физических лиц (пени по соответствующему платежу)"),
                              .init(id: "2", name: "Транспортный налог с физических лиц (проценты по соответствующему платежу)"),
                              .init(id: "3", name: "Транспортный налог с физических лиц (суммы денежных взысканий (штрафов) по соответствующему платежу согласно законодательству РФ)")])
                
                completion(.success( parameters + [serviceParameter]))
                
            case .fnsUin:
                
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
            
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let operatorSelected = Payments.Operator(rawValue: operatorValue) else {
                      
                      completion(.failure(Payments.Error.missingOperatorParameter))
                      return
                  }
            
            switch operatorSelected {
            case .fns:
                
                var updatedParameters = [PaymentsParameterRepresentable]()
                for parameter in parameters {
                    
                    switch parameter.parameter.id {
                    case "a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1":
//                        updatedParameters.append(parameter.updated(isEditable: false))
                        break
                        
                    default:
                        updatedParameters.append( parameter)
                    }
                }
                
                let adressParameter = Payments.ParameterInput(
                    .init(id: "a3_address_2_2",
                          value: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 432011, Ульяновская обл, Ульяновск г, Радищева ул ,  д. 124,  кв. 28"),
                    icon: .parameterLocation,
                    title: "Адрес:",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                
                let fioParameter = Payments.ParameterName(
                    .init(id: "fio", value: "fio"),
                    title: "ФИО:",
                    lastName: .init(title: "Фамилия", value: "Иванов"),
                    firstName: .init(title: "Имя", value: "Иван"),
                    middleName: .init(title: "Отчество", value: "Петрович"))
                
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
                    icon: .parameterDocument,
                    title: "Номер документа:",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                
                let productParameter = Payments.ParameterProduct()
                
                // collapsable
                let division0Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientName_6_1", value: "Управление Федерального казначейства по г. Москве (Инспекция ФНС России № 23 по г.Москве)"),
                    icon: .parameterDocument,
                    title: "Получатель платежа:", placement: .spoiler)
                
                let division1Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientKPP_8_1", value: "772301001"),
                    icon: .parameterHash,
                    title: "КПП:", placement: .spoiler)
                
                let division2Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientAccount_9_1", value: "03100643000000017300"),
                    icon: .parameterHash,
                    title: "Расчетный счет:", placement: .spoiler)
                
                let division3Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientBankName_10_1", value: "ГУ БАНКА РОССИИ ПО ЦФО//УФК ПО Г. МОСКВЕ г. Москва"),
                    icon: .parameterSample,
                    title: "Банк получателя:", placement: .spoiler)
                
                let division4Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientBIC_11_1", value: "004525988"),
                    icon: .parameterDocument,
                    title: "БИК:", placement: .spoiler)
                
                let division5Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientKBK_13_1", value: "18210606041031000110"),
                    icon: .parameterDocument,
                    title: "КБК:", placement: .spoiler)
                
                let amountParameter = Payments.ParameterAmount(
                    .init(id: Payments.Parameter.Identifier.amount.rawValue, value: "1234"),
                    title: "Сумма перевода",
                    currency: .init(description: "RUB"),
                    validator: .init(minAmount: 10, maxAmount: 1000))
                
                completion(.success( parameters + [fioParameter, adressParameter, docParameter, numDocParameter, productParameter, division0Parameter, division1Parameter, division2Parameter, division3Parameter, division4Parameter, division5Parameter, amountParameter]))
                
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
            
        case 4:
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let operatorSelected = Payments.Operator(rawValue: operatorValue) else {
                      
                      completion(.failure(Payments.Error.missingOperatorParameter))
                      return
                  }
            
            switch operatorSelected {
            case .fns:
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
