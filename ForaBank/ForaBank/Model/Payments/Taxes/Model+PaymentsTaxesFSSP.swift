//
//  Model+PaymentsTaxesFSSP.swift
//  ForaBank
//
//  Created by Max Gribov on 15.03.2022.
//

import Foundation

extension Model {
    
    func paymentsStepFSSP(_ operation: Payments.Operation, for stepIndex: Int) async throws -> Payments.Operation.Step {
        
        let searchTypeParameterId = "a3_SearchType_1_1"
        
        switch stepIndex {
        case 0:
            
            // operator
            let operatorParameter = Payments.ParameterOperator(operatorType: .fssp)
            
            // product
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            let filter = ProductData.Filter.generalFrom
            guard let product = firstProduct(with: filter) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            let productParameter = Payments.ParameterProduct(value: String(product.id), filter: filter, isEditable: true)

            // search type
            let searchTypeParameter = Payments.ParameterSelectSwitch(
                .init(id: searchTypeParameterId, value: "20"),
                options: [
                    .init(id: "20", name: "Документ"),
                    .init(id: "30", name: "УИН"),
                    .init(id: "40", name: "ИП")
                    
                ], placement: .top)
            
            return .init(parameters: [operatorParameter, productParameter, searchTypeParameter], front: .init(visible: [searchTypeParameter.id], isCompleted: true), back: .init(stage: .local, required: [searchTypeParameter.id], processed: [.init(id: searchTypeParameter.id, value: "20")] ))
            
        case 1:
            guard let searchTypeParameterValue = paymentsParameterValue(operation.parameters, id: searchTypeParameterId) else {
                throw Payments.Error.missingParameter(searchTypeParameterId)
            }
            
            switch searchTypeParameterValue {
            case "20":
                guard let fsspDocumentList = dictionaryFSSPDocumentList() else {
                    throw Payments.Error.missingParameter("a3_docName_1_2")
                }
                
                let documentParameter = Payments.ParameterSelect(
                    Payments.Parameter(id: "a3_docName_1_2", value: nil),
                    title: "Тип документа",
                    options: fsspDocumentList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample) })
                
                return .init(parameters: [documentParameter], front: .init(visible: [documentParameter.id], isCompleted: false), back: .init(stage: .remote(.start), required: [documentParameter.id], processed: nil))
                
            case "30", "40":
                return  .init(parameters: [], front: .init(visible: [], isCompleted: true), back: .init(stage: .remote(.start), required: [searchTypeParameterId], processed: nil ))

            default:
                throw Payments.Error.unsupported
            }

        default:
            throw Payments.Error.unsupported
        }
    }
    
    func paymentsMockFSSP() -> Payments.Mock {
        
        return .init(service: .fssp,
                     parameters: [.init(id: "a3_BillNumber_1_1", value: "32227009220006631003"),
                                  .init(id: "a3_IPnumber_1_1", value: "6631/22/27009-ИП"),
                                  .init(id: "a3_docNumber_2_2", value: "7816218222")])
                                    //.init(id: "a3_docNumber_2_2", value: "7816218222")
                                    //.init(id: "a3_docNumber_2_2", value: "13420742521")
    }
    
    /*
    func parametersFSSP(_ parameters: [PaymentsParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[PaymentsParameterRepresentable], Error>) -> Void) {
        
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
                        options: fsspDocumentList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample) })
                    
                    completion(.success(updatedParameters + [documentParameter]))
                    
                case "30":
                    Task {
                        
                        // remove all search type depended parameters
                        let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_docName_1_2", "a3_BillNumber_1_1", "a3_IPnumber_1_1"])
                        
                        /*
                         Данные для теста
                         УИН 32227009220006631003
                         */
                        
                        //TODO: refactor
                        /*
                        do {
                            
                            let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_SearchType_1_1"], step: .initial)
                            //["id: a3_BillNumber_1_1 value: empty title: Индекс документа (УИН) data: %String type: Input"]
                            #if DEBUG
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_BillNumber_1_1": "32227009220006631003"])
                            #else
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                            #endif
                            
                            let additionalParameters = paymentsAdditionalParameters(for: transferStepData)
 
                            completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                         */
                    }
                    
                case "40":
                    Task {
                        
                        // remove all search type depended parameters
                        let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_docName_1_2", "a3_BillNumber_1_1", "a3_IPnumber_1_1"])
                        
                        /*
                         Данные для теста
                         ИП 6631/22/27009-ИП
                         */
                        
                        //TODO: refactor
                        /*
                        do {
                            
                            let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_SearchType_1_1"], step: .initial)
                            #if DEBUG
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_IPnumber_1_1": "6631/22/27009-ИП"])
                            #else
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                            #endif
                            
                            let additionalParameters = paymentsAdditionalParameters(for: transferStepData)
 
                            completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                         */
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
                    ])
                
                // documents
                guard let fsspDocumentList = dictionaryFSSPDocumentList() else {
                    completion(.failure(Payments.Error.unableLoadFTSCategoryOptions))
                    return
                }
                
                let documentParameter = Payments.ParameterSelect(
                    Parameter(id: "a3_docName_1_2", value: nil),
                    title: "Тип документа",
                    options: fsspDocumentList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample) })
                
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
                    
                    //TODO: refactor
                    /*
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_SearchType_1_1"], step: .next)
                        
                        //["id: a3_docName_1_2 value: 20 title: Тип документа: data: =,20=Паспорт РФ (серия номер),30=ИНН,40=СНИЛС,50=Водительское удостоверение,60=Свидетельство о регистрации ТС (СТС) type: Select", "id: a3_docNumber_2_2 value: empty title: Номер документа: data: %String type: Input"]
                        #if DEBUG
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_docNumber_2_2": "13420742521"])
                        #else
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        #endif
                        
                        let additionalParameters = paymentsAdditionalParameters(for: transferStepData)
                        
                        completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                     */
                }
                
            case "30":
                
                Task {
                    
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_BillNumber_1_1"])
                    
                    //TODO: refactor
                    /*
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_BillNumber_1_1"], step: .next)
                        //["id: a3_lastName_1_3 value: Чаликян title: Фамилия: data: %String type: Input", "id: a3_firstName_2_3 value: Геворг title: Имя: data: %String type: Input", "id: a3_middleName_3_3 value: Акопович title: Отчество: data: %String type: Input", "id: a3_address_4_3 value: РОССИЙСКАЯ ФЕДЕРАЦИЯ, Липецкая обл, Грязинский р-н, Сошки с, Фролова ул ,  д. 4 title: Адрес: data: %String type: Input"]
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        let additionalParameters = paymentsAdditionalParameters(for: transferStepData)
                        
                        completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                     */
                }
                
            case "40":
                Task {
                    
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_IPnumber_1_1"])
                    
                    //TODO: refactor
                    /*
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_IPnumber_1_1"], step: .next)
                        // a3_lastName_1_2, a3_firstName_2_2, a3_middleName_3_2, a3_address_4_2
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        let additionalParameters = paymentsAdditionalParameters(for: transferStepData)

                        completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                     */
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
                    
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_docName_1_2", "a3_docNumber_2_2"])
                    
                    //TODO: refactor
                    /*
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_docName_1_2", "a3_docNumber_2_2"], step: .next)
                        
                        //["id: a3_lastName_1_2 value: Грибов title: Фамилия: data: %String type: Input", "id: a3_firstName_2_2 value: Максим title: Имя: data: %String type: Input", "id: a3_middleName_3_2 value: Валентинович title: Отчество: data: %String type: Input", "id: a3_address_4_2 value: РОССИЙСКАЯ ФЕДЕРАЦИЯ, 117465, Москва г, Тёплый Стан ул ,  д. 1,  кв. 38 title: Адрес: data: %String type: Input"]
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        let additionalParameters = paymentsAdditionalParameters(for: transferStepData)

                        completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                     */
                }
                
            case "30":
                
                //TODO: refactor
                /*
                Task {
                    
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_lastName_1_3", "a3_firstName_2_3", "a3_middleName_3_3", "a3_address_4_3"])
                    
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_lastName_1_3", "a3_firstName_2_3", "a3_middleName_3_3", "a3_address_4_3"], step: .next)
                        //a3_docName_1_2, a3_docNumber_2_2
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        let additionalParameters = paymentsAdditionalParameters(for: transferStepData)
                        
                        completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                 */
                break
                
            case "40":
                //TODO: refactor
                /*
                Task {
                    // a3_lastName_1_2, a3_firstName_2_2, a3_middleName_3_2, a3_address_4_2
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_lastName_1_2", "a3_firstName_2_2", "a3_middleName_3_2", "a3_address_4_2"])
                    
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_lastName_1_2", "a3_firstName_2_2", "a3_middleName_3_2", "a3_address_4_2"], step: .next)
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        let additionalParameters = paymentsAdditionalParameters(for: transferStepData)
                        
                        completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                 */
                break
                
                
            default:
                completion(.failure(Payments.Error.unsupported))
                
            }
            
        case 3:
            
            guard let searchTypeParameter = paymentsParameterValue(parameters, id: "a3_SearchType_1_1") else {
                
                completion(.failure(Payments.Error.missingParameter))
                return
            }
            
            switch searchTypeParameter {
            case "20":
                //TODO: refactor
                /*
                Task {
     
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_lastName_1_2", "a3_firstName_2_2", "a3_middleName_3_2", "a3_address_4_2"])
                    
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_lastName_1_2", "a3_firstName_2_2", "a3_middleName_3_2", "a3_address_4_2"], step: .next)
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        let additionalParameters = paymentsAdditionalParameters(for: transferStepData)
                        
                        completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                 */
                return
                
            default:
                completion(.failure(Payments.Error.unsupported))
                
            }
            
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
     */
}
