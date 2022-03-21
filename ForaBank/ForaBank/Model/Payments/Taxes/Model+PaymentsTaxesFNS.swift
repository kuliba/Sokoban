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
        
        switch step {
        case 0:
            
            if let operatorParameterValue = paymentsParameterValue(parameters, id: paramOperator),
                let operatorSelected = Operator(rawValue: operatorParameterValue) {
                
                switch operatorSelected {
                case .fns:
                    
                    // category
                    guard let fnsCategoriesList = dictionaryFTSList() else {
                        completion(.failure(Payments.Error.unableLoadFTSCategoryOptions))
                        return
                    }
                    
                    let categoryParameter = Payments.ParameterSelect(
                        Parameter(id: "a3_dutyCategory_1_1", value: nil),
                        title: "Категория платежа",
                        options: fnsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample)}, affectsHistory: true)
                    
                    completion(.success( parameters + [categoryParameter]))
                    
                case .fnsUin:
                    
                    /*
                     УИН для теста 18200550200005071174

                     Если не будет работать, попробовать из нижеперечисленных:
                     18810192110276578924
                     18200550200005071174
                     18200544200017415275
                     18207603200005987087
                     18207580200009786004
                     18204437200029004095
                     18202452200028262470
                     18207536200032541235
                     18810150210809028577
                     18810123210722211917
                     18810129210809765632
                     32277058210591378005
                     18810171210871130401
                     */
                    
                    // number
                    let numberParameter = Payments.ParameterInput(
                        Parameter(id: "a3_BillNumber_1_1", value: "18810192110276578924"),
                        icon: .parameterDocument,
                        title: "УИН",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    completion(.success( parameters + [numberParameter]))
                    
                default:
                    completion(.failure(Payments.Error.unexpectedOperatorValue))
                }
                
            } else {
                
                // operator
                let operatorParameter = Payments.ParameterSelectSwitch(
                    .init(id: paramOperator, value: Operator.fns.rawValue),
                    options: [
                        .init(id: Operator.fns.rawValue, name: Operator.fns.name),
                        .init(id: Operator.fnsUin.rawValue, name: Operator.fnsUin.name)
                    ], affectsHistory: true)
                
                // category
                guard let fnsCategoriesList = dictionaryFTSList() else {
                    completion(.failure(Payments.Error.unableLoadFTSCategoryOptions))
                    return
                }
                
                let categoryParameter = Payments.ParameterSelect(
                    Parameter(id: "a3_dutyCategory_1_1", value: nil),
                    title: "Категория платежа",
                    options: fnsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample)}, affectsHistory: true)
                
                completion(.success( parameters + [operatorParameter, categoryParameter]))
            }
            
        case 1:
            guard let operatorParameterValue = paymentsParameterValue(parameters, id: paramOperator),
                let operatorSelected = Operator(rawValue: operatorParameterValue),
                let anywayOperator = dictionaryAnywayOperator(for: operatorParameterValue) else {
                    
                    completion(.failure(Payments.Error.missingOperatorParameter))
                    return
                }
            
            switch operatorSelected {
            case .fns:
                
                let divisionParameterId = "a3_divisionSelect_2_1"
                let parametersIds = parameters.map{ $0.parameter.id }
                
                if parametersIds.contains(divisionParameterId) {
                    
                    // user updated division parameter value
                    
                    Task {
                        
                        // remove all division depended parameters
                        var updatedParameters = [ParameterRepresentable]()
                        for parameter in parameters {
                            
                            switch parameter.parameter.id {
                            case "a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1":
                                continue
                                
                            default:
                                updatedParameters.append(parameter)
                            }
                        }
                        
                        do {
                            
                            let include = ["a3_dutyCategory_1_1", divisionParameterId]
                            
                            let transferData = try await paymentsTransferAnywayStep(with: updatedParameters, include: include, step: .initial)
                            
                            for parameter in transferData.parameterListForNextStep {
        
                                /*
                                 Данные для теста
                                 Земельный налог, ИНН 7723013452, октмо 45390000
                                 */
                                
                                switch parameter.id {
                                case "a3_categorySelect_3_1":
                                    guard let categoryParameterOptions = parameter.options else {
                                        completion(.failure(Payments.Error.missingParameter))
                                        return
                                    }
                                    let categoryParameter = Payments.ParameterSelectSimple(
                                        Parameter(id: parameter.id, value: categoryParameterOptions.first?.id),
                                        icon: parameter.iconData ?? .parameterSample,
                                        title: parameter.title,
                                        selectionTitle: "Выберете услугу",
                                        options: categoryParameterOptions, autoContinue: false)
                                        updatedParameters.append(categoryParameter)
                                case "a3_INN_4_1":
                                    let unnParameter = Payments.ParameterInput(
                                        .init(id: parameter.id, value: "7723013452"),
                                        icon: parameter.iconData ?? .parameterDocument,
                                        title: parameter.title,
                                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                                    updatedParameters.append(unnParameter)
                                    
                                case "a3_OKTMO_5_1":
                                    let oktmoParameter = Payments.ParameterInput(
                                        .init(id: parameter.id, value: "45390000"),
                                        icon: parameter.iconData ?? .parameterDocument,
                                        title: parameter.title,
                                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                                    updatedParameters.append(oktmoParameter)
                                    
                                case "a3_DIVISION_4_1":
                                    let numberParameter = Payments.ParameterInput(
                                        .init(id: parameter.id, value: nil),
                                        icon: parameter.iconData ?? .parameterDocument,
                                        title: parameter.title,
                                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                                    updatedParameters.append(numberParameter)
                                    
                                default:
                                    continue
                                }
                            }
                            
                            completion(.success(updatedParameters))
                            
                        } catch {
                            
                            print(error.localizedDescription)
                            completion(.failure(error))
                        }
                    }
                    
                } else {
                    
                    // initial division parameter selection
                    guard let divisionAnywayParameter = anywayOperator.parameterList.first(where: { $0.id == divisionParameterId }),
                          let divisionAnywayParameterOptions = divisionAnywayParameter.options,
                          let divisionAnywayParameterValue = divisionAnywayParameter.value else {
                              
                              completion(.failure(Payments.Error.missingParameter))
                              return
                          }
                    
                    // division
                    let divisionParameter = Payments.ParameterSelectSimple(
                        Parameter(id: divisionParameterId, value: divisionAnywayParameterValue),
                        icon: divisionAnywayParameter.iconData ?? .parameterSample,
                        title: divisionAnywayParameter.title,
                        selectionTitle: "Выберете услугу",
                        options: divisionAnywayParameterOptions,
                        affectsHistory: true)
                    
                    Task {
                        
                        do {
                            
                            var stepParameters = parameters + [divisionParameter]
                            let include = ["a3_dutyCategory_1_1", divisionParameterId]
                            
                            let transferData = try await paymentsTransferAnywayStep(with: stepParameters, include: include, step: .initial)
                            
                            print(transferData.parameterListForNextStep.map{ $0.debugDescription })
                            for parameter in transferData.parameterListForNextStep {
                                
                                /*
                                 Данные для теста
                                 Земельный налог, ИНН 7723013452, октмо 45390000
                                 */
                                
                                switch parameter.id {
                                case "a3_categorySelect_3_1":
                                    guard let categoryParameterOptions = parameter.options else {
                                        completion(.failure(Payments.Error.missingParameter))
                                        return
                                    }
                                    let categoryParameter = Payments.ParameterSelectSimple(
                                        Parameter(id: parameter.id, value: categoryParameterOptions.first?.id),
                                        icon: parameter.iconData ?? .parameterSample,
                                        title: parameter.title,
                                        selectionTitle: "Выберете услугу",
                                        options: categoryParameterOptions, autoContinue: false)
                                        stepParameters.append(categoryParameter)
                                    
                                case "a3_INN_4_1":
                                    let unnParameter = Payments.ParameterInput(
                                        .init(id: parameter.id, value: "7723013452"),
                                        icon: parameter.iconData ?? .parameterDocument,
                                        title: parameter.title,
                                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                                    stepParameters.append(unnParameter)
                                    
                                case "a3_OKTMO_5_1":
                                    let oktmoParameter = Payments.ParameterInput(
                                        .init(id: parameter.id, value: "45390000"),
                                        icon: parameter.iconData ?? .parameterDocument,
                                        title: parameter.title,
                                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                                    stepParameters.append(oktmoParameter)
                                    
                                default:
                                    continue
                                }
                            }
                            
                            completion(.success(stepParameters))
                            
                        } catch {
                            
                            print(error.localizedDescription)
                            completion(.failure(error))
                        }
                    }
                }

            case .fnsUin:
                Task {
                    
                    do {
                        let include = ["a3_BillNumber_1_1"]
                        
                        let transferData = try await paymentsTransferAnywayStep(with: parameters, include: include, step: .initial)
                        
                        //FIXME: same parameter for nex step
                        // ["id: a3_BillNumber_1_1 value: 18810192110276578924 title: УИН: data: %String type: Input"]
                        print(transferData.parameterListForNextStep.map{ $0.debugDescription })
                        for parameter in transferData.parameterListForNextStep {
   
                            switch parameter.id {
 
                            default:
                                continue
                            }
                        }
                        
                        completion(.success(parameters))
                        
                    } catch {
                        
                        print(error.localizedDescription)
                        completion(.failure(error))
                    }
                }
 
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
            
        case 2:
            guard let operatorParameterValue = paymentsParameterValue(parameters, id: paramOperator),
                let operatorSelected = Operator(rawValue: operatorParameterValue) else {
                    
                    completion(.failure(Payments.Error.missingOperatorParameter))
                    return
                }
            
            switch operatorSelected {
            case .fns:
                Task {
                    
                    var updatedParameters = [ParameterRepresentable]()
                    for parameter in parameters {
                        
                        switch parameter.parameter.id {
                        case "a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1":
                            updatedParameters.append(parameter.updated(editable: false))
                            
                        default:
                            updatedParameters.append(parameter)
                        }
                    }
                    
                    do {
 
                        let include = ["a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"]
                        
                        let transferData = try await paymentsTransferAnywayStep(with: parameters, include: include, step: .next)
                        
                        print(transferData.parameterListForNextStep.map{ $0.debugDescription })
                        for parameter in transferData.parameterListForNextStep {

                            switch parameter.id {
                            case "a3_fio_1_2":
                                let fioParameter = Payments.ParameterName(id: parameter.id, value: parameter.value, title: parameter.title)
                                updatedParameters.append(fioParameter)
                                
                            case "a3_address_2_2":
                                let adressParameter = Payments.ParameterInfo(
                                    .init(id: parameter.id, value: parameter.value),
                                    icon: parameter.iconData ?? .parameterLocation,
                                    title: "Адрес проживания")
                                updatedParameters.append(adressParameter)
                                
                            case "a3_docType_3_2":
                                let docTypeParameter = Payments.ParameterSelectSimple(
                                    Parameter(id: parameter.id, value: parameter.value),
                                    icon: parameter.iconData ?? .parameterSample,
                                    title: parameter.title,
                                    selectionTitle: "Выберете тип документа",
                                    options: parameter.options ?? [], editable: false)
                                updatedParameters.append(docTypeParameter)
                                
                            case "a3_docValue_4_2":
                                let docValueParameter = Payments.ParameterInput(
                                    .init(id: parameter.id, value: parameter.value),
                                    icon: parameter.iconData ?? .parameterDocument,
                                    title: parameter.title,
                                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                                updatedParameters.append(docValueParameter)
    
                            default:
                                continue
                            }
                        }
                        
                        let cardParameter = Payments.ParameterCard()
                        updatedParameters.append(cardParameter)
                        
                        let amountParameter = Payments.ParameterAmount(
                            .init(id: Payments.Parameter.Identifier.amount.rawValue, value: nil),
                            title: "Сумма перевода",
                            currency: .init(description: "RUB"),
                            validator: .init(minAmount: 10))
                        updatedParameters.append(amountParameter)
                        
                        completion(.success(updatedParameters))
                        
                    } catch {
                        
                        print(error.localizedDescription)
                        completion(.failure(error))
                    }
                }
                
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
            
            
        case 3:
            guard let operatorParameterValue = paymentsParameterValue(parameters, id: paramOperator),
                let operatorSelected = Operator(rawValue: operatorParameterValue) else {
                    
                    completion(.failure(Payments.Error.missingOperatorParameter))
                    return
                }
            
            switch operatorSelected {
            case .fns:
                Task {
                    
                    // make all parameters not editable
                    var updatedParameters = [ParameterRepresentable]()
                    for parameter in parameters {
                        
                        updatedParameters.append(parameter.updated(editable: false))
                    }
                    
                    do {
                        
                        let include = ["a3_fio_1_2", "a3_address_2_2", "a3_docType_3_2", "a3_docValue_4_2"]
                        let transferData = try await paymentsTransferAnywayStep(with: updatedParameters, include: include, step: .next)
                        
                        if transferData.finalStep == true {
                            
                            let codeParameter = Payments.ParameterInput(
                                .init(id: Payments.Parameter.Identifier.code.rawValue, value: nil),
                                icon: .parameterSMS,
                                title: "Введите код из СМС", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
                            
                            let finalParameter = Payments.ParameterFinal()
                            
                            completion(.success(updatedParameters + [codeParameter, finalParameter]))
                            
                        } else {
                            
                            completion(.failure(Payments.Error.anywayTransferFinalStepExpected))
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }

            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }

        default:
            completion(.failure(Payments.Error.unsupported))
        }        
    }
    
    func parametersFNSMock(_ parameters: [ParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[ParameterRepresentable], Error>) -> Void) {
        
        let paramOperator = Payments.Parameter.Identifier.operator.rawValue
     
        switch step {
        case 0:
            
            if let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
               let operatorValue = operatorParameter.parameter.value,
               let operatorSelected = Operator(rawValue: operatorValue) {
                
                switch operatorSelected {
                case .fns:
                    
                    // category
                    let categoryParameter = Payments.ParameterSelect(
                        Parameter(id: "a3_dutyCategory_1_1", value: nil),
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
                        ], affectsHistory: true)
                    
                    completion(.success( parameters + [categoryParameter]))
                    
                case .fnsUin:
                    
                    // category
                    let categoryParameter = Payments.ParameterInput(
                        Parameter(id: "a3_BillNumber_1_1", value: nil),
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
                    .init(id: paramOperator, value: Operator.fns.rawValue),
                    options: [
                        .init(id: Operator.fns.rawValue, name: Operator.fns.name),
                        .init(id: Operator.fnsUin.rawValue, name: Operator.fnsUin.name)
                    ], affectsHistory: true)
                
                // category
                let categoryParameter = Payments.ParameterSelect(
                    Parameter(id: "a3_dutyCategory_1_1", value: nil),
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
                    ], affectsHistory: true)
                
                completion(.success( parameters + [operatorParameter, categoryParameter]))
            }
            
        case 1:
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let operatorSelected = Operator(rawValue: operatorValue) else {
                      
                      completion(.failure(Payments.Error.missingOperatorParameter))
                      return
                  }
            
            switch operatorSelected {
            case .fns:
                
                if let divisionParameter = parameters.first(where: { $0.parameter.id == "a3_divisionSelect_2_1" }),
                   let divisionParameterValue = divisionParameter.parameter.value {
                    
                    var updatedParameters = [ParameterRepresentable]()
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
                                  .init(id: "number", name: "Номер подразделения")], affectsHistory: true)
                    
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
                
                var updatedParameters = [ParameterRepresentable]()
                for parameter in parameters {
                    
                    switch parameter.parameter.id {
                    case "a3_BillNumber_1_1":
                        updatedParameters.append(parameter.updated(editable: false))
                        
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
                
                let cardParameter = Payments.ParameterCard()
                
                let innParameter = Payments.ParameterInput(
                    .init(id: UUID().uuidString,
                          value: "7726062105"),
                    icon: .parameterDocument,
                    title: "ИНН Получателя",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil),
                    collapsable: true)
                
                let oktmoParameter = Payments.ParameterInput(
                    .init(id: UUID().uuidString,
                          value: "20701000"),
                    icon: .parameterHash,
                    title: "ОКТМО (ОКАТО)",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil),
                    collapsable: true)
                
                let adressParameter = Payments.ParameterInfo(
                    .init(id: "a3_address_2_2", value: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 432011, Ульяновская обл, Ульяновск г, Радищева ул ,  д. 124,  кв. 28"),
                    icon: .parameterLocation,
                    title: "Адрес проживания", collapsable: true)
                
                let amountParameter = Payments.ParameterAmount(
                    .init(id: Payments.Parameter.Identifier.amount.rawValue, value: "1234"),
                    title: "Сумма перевода",
                    currency: .init(description: "RUB"),
                    validator: .init(minAmount: 10))
                
                completion(.success( updatedParameters + [infoParameter, fioParameter, cardParameter, innParameter, oktmoParameter, adressParameter, amountParameter]))
                
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
            
        case 2:
            
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let operatorSelected = Operator(rawValue: operatorValue) else {
                      
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
                              .init(id: "3", name: "Транспортный налог с физических лиц (суммы денежных взысканий (штрафов) по соответствующему платежу согласно законодательству РФ)")], autoContinue: false)
                
                completion(.success( parameters + [serviceParameter]))
                
            case .fnsUin:
                
                // make all parameters not editable
                var updatedParameters = [ParameterRepresentable]()
                for parameter in parameters {
                    
                    updatedParameters.append(parameter.updated(editable: false))
                }
                
                let codeParameter = Payments.ParameterInput(
                    .init(id: Payments.Parameter.Identifier.code.rawValue, value: nil),
                    icon: .parameterSMS,
                    title: "Введите код из СМС", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
                
                let finalParameter = Payments.ParameterFinal()
                
                completion(.success(updatedParameters + [codeParameter, finalParameter]))
                
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
            
        case 3:
            
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let operatorSelected = Operator(rawValue: operatorValue) else {
                      
                      completion(.failure(Payments.Error.missingOperatorParameter))
                      return
                  }
            
            switch operatorSelected {
            case .fns:
                
                var updatedParameters = [ParameterRepresentable]()
                for parameter in parameters {
                    
                    switch parameter.parameter.id {
                    case "a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1":
                        updatedParameters.append(parameter.updated(editable: false))
                        
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
                
                let cardParameter = Payments.ParameterCard()
                
                // collapsable
                let division0Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientName_6_1", value: "Управление Федерального казначейства по г. Москве (Инспекция ФНС России № 23 по г.Москве)"),
                    icon: .parameterDocument,
                    title: "Получатель платежа:", collapsable: true)
                
                let division1Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientKPP_8_1", value: "772301001"),
                    icon: .parameterHash,
                    title: "КПП:", collapsable: true)
                
                let division2Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientAccount_9_1", value: "03100643000000017300"),
                    icon: .parameterHash,
                    title: "Расчетный счет:", collapsable: true)
                
                let division3Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientBankName_10_1", value: "ГУ БАНКА РОССИИ ПО ЦФО//УФК ПО Г. МОСКВЕ г. Москва"),
                    icon: .parameterSample,
                    title: "Банк получателя:", collapsable: true)
                
                let division4Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientBIC_11_1", value: "004525988"),
                    icon: .parameterDocument,
                    title: "БИК:", collapsable: true)
                
                let division5Parameter = Payments.ParameterInfo(
                    .init(id: "a3_iRecipientKBK_13_1", value: "18210606041031000110"),
                    icon: .parameterDocument,
                    title: "КБК:", collapsable: true)
                
                let amountParameter = Payments.ParameterAmount(
                    .init(id: Payments.Parameter.Identifier.amount.rawValue, value: "1234"),
                    title: "Сумма перевода",
                    currency: .init(description: "RUB"),
                    validator: .init(minAmount: 10))
                
                completion(.success( parameters + [fioParameter, adressParameter, docParameter, numDocParameter, cardParameter, division0Parameter, division1Parameter, division2Parameter, division3Parameter, division4Parameter, division5Parameter, amountParameter]))
                
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
            
        case 4:
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let operatorSelected = Operator(rawValue: operatorValue) else {
                      
                      completion(.failure(Payments.Error.missingOperatorParameter))
                      return
                  }
            
            switch operatorSelected {
            case .fns:
                // make all parameters not editable
                var updatedParameters = [ParameterRepresentable]()
                for parameter in parameters {
                    
                    updatedParameters.append(parameter.updated(editable: false))
                }
                
                let codeParameter = Payments.ParameterInput(
                    .init(id: Payments.Parameter.Identifier.code.rawValue, value: nil),
                    icon: .parameterSMS,
                    title: "Введите код из СМС", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
                
                let finalParameter = Payments.ParameterFinal()
                
                completion(.success(updatedParameters + [codeParameter, finalParameter]))
                
                
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
            
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
    
}
