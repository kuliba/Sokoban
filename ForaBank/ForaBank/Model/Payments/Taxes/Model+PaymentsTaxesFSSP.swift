//
//  Model+PaymentsTaxesFSSP.swift
//  ForaBank
//
//  Created by Max Gribov on 15.03.2022.
//

import Foundation

extension Model {
    
    func parametersFSSP(_ parameters: [ParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[ParameterRepresentable], Error>) -> Void) {
        
        switch step {
        case 0:
            
            if let searchTypeParameterValue = paymentsParameterValue(parameters, id: "a3_SearchType_1_1") {
                
                switch searchTypeParameterValue {
                case "20":
                    
                    // remove all search type depended parameters
                    let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_docName_1_2", "a3_BillNumber_1_1", "a3_IPnumber_1_1"])
                    
                    // documents
                    guard let fsspDocumentList = dictionaryFSSPDocumentList() else {
                        completion(.failure(Payments.Error.unableLoadFTSCategoryOptions))
                        return
                    }
                    
                    let documentParameter = Payments.ParameterSelect(
                        Parameter(id: "a3_docName_1_2", value: nil),
                        title: "Тип документа",
                        options: fsspDocumentList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample) }, affectsHistory: true)
                    
                    completion(.success(updatedParameters + [documentParameter]))
                    
                case "30":
                    Task {
                        
                        // remove all search type depended parameters
                        let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_docName_1_2", "a3_BillNumber_1_1", "a3_IPnumber_1_1"])
                        
                        /*
                         Данные для теста
                         УИН 32227009220006631003
                         */
                        
                        do {
                            
                            let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_SearchType_1_1"], step: .initial)
                            let nextStepParameters = paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_BillNumber_1_1": "32227009220006631003"])
 
                            completion(.success(updatedParameters + nextStepParameters))
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
                    
                case "40":
                    Task {
                        
                        // remove all search type depended parameters
                        let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_docName_1_2", "a3_BillNumber_1_1", "a3_IPnumber_1_1"])
                        
                        /*
                         Данные для теста
                         ИП 6631/22/27009-ИП
                         */
                        
                        do {
                            
                            let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_SearchType_1_1"], step: .initial)
                            let nextStepParameters = paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_IPnumber_1_1": "6631/22/27009-ИП"])
 
                            completion(.success(updatedParameters + nextStepParameters))
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
     
                default:
                    completion(.failure(Payments.Error.unsupported))
                }

            } else {
                                
                // operator
                let operatorParameter = Payments.ParameterOperator(operatorType: .fssp)
                
                // search type
                let searchTypeParameter = Payments.ParameterSelectSwitch(
                    .init(id: "a3_SearchType_1_1", value: "20"),
                    options: [
                        .init(id: "20", name: "Документ"),
                        .init(id: "30", name: "УИН"),
                        .init(id: "40", name: "ИП")
                    ], affectsHistory: true)
                
                // documents
                guard let fsspDocumentList = dictionaryFSSPDocumentList() else {
                    completion(.failure(Payments.Error.unableLoadFTSCategoryOptions))
                    return
                }
                
                let documentParameter = Payments.ParameterSelect(
                    Parameter(id: "a3_docName_1_2", value: nil),
                    title: "Тип документа",
                    options: fsspDocumentList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample) }, affectsHistory: true)
                
                completion(.success([operatorParameter, searchTypeParameter, documentParameter]))
            }

            
        case 1:
            guard let searchTypeParameter = paymentsParameterValue(parameters, id: "a3_SearchType_1_1") else {
                
                completion(.failure(Payments.Error.missingParameter))
                return
            }
            
            switch searchTypeParameter {
            case "20":
                Task {
                    
                    // remove all search type depended parameters
                    let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_docNumber_2_2"])
                    
                    /*
                     тестовые данные
                     a3_docNumber_2_2 7816218222
                     */
                    
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_SearchType_1_1"], step: .initial)
                        //a3_docNumber_2_2
                        let nextStepParameters = paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_docNumber_2_2": "7816218222"])
                        
                        completion(.success(updatedParameters + nextStepParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
            case "30":
                
                Task {
                    
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_BillNumber_1_1"])
                    
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_BillNumber_1_1"], step: .next)
                        print(transferStepData.parameterListForNextStep.map{ $0.debugDescription})
                        //a3_docName_1_2, a3_docNumber_2_2
                        let nextStepParameters = paymentsTaxesNextStepParameters(for: transferStepData)
                        
                        completion(.success(updatedParameters + nextStepParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
            case "40":
                Task {
                    
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_IPnumber_1_1"])
                    
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_IPnumber_1_1"], step: .next)
                        print(transferStepData.parameterListForNextStep.map{ $0.debugDescription})
                        //FIXME: debug
//                        let nextStepParameters = paymentsTaxesNextStepParameters(for: transferStepData)
                        
                        completion(.failure(Payments.Error.unsupported))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                
            default:
                completion(.failure(Payments.Error.unsupported))
                
            }
            
        case 2:
            
            guard let searchTypeParameter = paymentsParameterValue(parameters, id: "a3_SearchType_1_1") else {
                
                completion(.failure(Payments.Error.missingParameter))
                return
            }
            
            switch searchTypeParameter {
            case "20":
                Task {
                    
                    // remove all search type depended parameters
    //                    let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_docNumber_2_2"])
                    
                    
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_docName_1_2", "a3_docNumber_2_2"], step: .initial)
    //                        let nextStepParameters = paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_docNumber_2_2": "7816218222"])
                        
                        print(transferStepData.parameterListForNextStep.map{ $0.debugDescription})
                        completion(.failure(Payments.Error.unsupported))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
            case "30":
                
                Task {
                    
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_docName_1_2", "a3_docNumber_2_2"])
                    
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_docName_1_2", "a3_docNumber_2_2"], step: .next)
                        print(transferStepData.parameterListForNextStep.map{ $0.debugDescription})
                        //a3_docName_1_2, a3_docNumber_2_2
                        let nextStepParameters = paymentsTaxesNextStepParameters(for: transferStepData)
                        
                        completion(.success(updatedParameters + nextStepParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
            case "40":
                Task {
                    
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_IPnumber_1_1"])
                    
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_IPnumber_1_1"], step: .next)
                        print(transferStepData.parameterListForNextStep.map{ $0.debugDescription})
                        //FIXME: debug
                        let nextStepParameters = paymentsTaxesNextStepParameters(for: transferStepData)
                        
                        completion(.success(updatedParameters + nextStepParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                
            default:
                completion(.failure(Payments.Error.unsupported))
                
            }
            
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
    
    func parametersFSSPMock(_ parameters: [ParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[ParameterRepresentable], Error>) -> Void) {
        
        switch step {
        case 0:
            
            if let searchTypeParameter = parameters.first(where: { $0.parameter.id == "a3_SearchType_1_1" }),
                let searchTypeParameterValue = searchTypeParameter.parameter.value  {
                
                var updatedParameters = [ParameterRepresentable]()
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
                        Parameter(id: "a3_dutyCategory_1_1_document", value: nil),
                        title: "Тип документа",
                        options: [
                            .init(id: "1", name: "Паспорт РФ", icon: .parameterSample),
                            .init(id: "2", name: "ИНН", icon: .parameterSample),
                            .init(id: "3", name: "СНИЛС", icon: .parameterSample),
                            .init(id: "4", name: "Водительское удостоверение", icon: .parameterSample),
                            .init(id: "5", name: "Свидетельство о регистрации ТС (СТС)", icon: .parameterSample)], affectsHistory: true)
                    
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
                    ], affectsHistory: true)
                
                let documentParameter = Payments.ParameterSelect(
                    Parameter(id: "a3_dutyCategory_1_1_document", value: nil),
                    title: "Тип документа",
                    options: [
                        .init(id: "1", name: "Паспорт РФ", icon: .parameterSample),
                        .init(id: "2", name: "ИНН", icon: .parameterSample),
                        .init(id: "3", name: "СНИЛС", icon: .parameterSample),
                        .init(id: "4", name: "Водительское удостоверение", icon: .parameterSample),
                        .init(id: "5", name: "Свидетельство о регистрации ТС (СТС)", icon: .parameterSample)], affectsHistory: true)
                
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
                
                completion(.success( parameters + [infoParameter, fioParameter, cardParameter, innParameter, oktmoParameter, adressParameter, amountParameter]))
            
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
                
                completion(.success( parameters + [infoParameter, fioParameter, cardParameter, innParameter, oktmoParameter, adressParameter, amountParameter]))
                
            case "uin", "ip":
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
            guard let searchTypeParameter = parameters.first(where: { $0.parameter.id == "a3_SearchType_1_1" }),
                let searchTypeParameterValue = searchTypeParameter.parameter.value else {
                    
                    completion(.failure(Payments.Error.unexpectedOperatorValue))
                    return
                }
            
            switch searchTypeParameterValue {
            case "document":
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
