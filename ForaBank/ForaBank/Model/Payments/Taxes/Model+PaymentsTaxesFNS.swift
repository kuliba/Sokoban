//
//  Model+PaymentsTaxesFNS.swift
//  ForaBank
//
//  Created by Mikhail on 22.02.2022.
//

import Foundation

extension Model {
    
    func paymentsStepFNS(_ operation: Payments.Operation, for stepIndex: Int) async throws -> Payments.Operation.Step {
        
        let operatorParameterId = Payments.Parameter.Identifier.operator.rawValue
        
        switch stepIndex {
        case 0:
            
            // product
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            guard let productId = firstProductId(of: .card, currency: .rub) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            let productParameter = Payments.ParameterProduct(value: String(productId), isEditable: true)
            
            // amount
            let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
            let amountParameter = Payments.ParameterAmount(.init(id: amountParameterId, value: "0"), title: "Сумма", currency: .rub, validator: .init(minAmount: 0, maxAmount: 100000))
            
            // operator
            let operatorParameterValue = Payments.Operator.fns.rawValue
            let operatorParameter = Payments.ParameterSelectSwitch(
                .init(id: operatorParameterId, value: operatorParameterValue),
                options: [
                    .init(id: Payments.Operator.fns.rawValue, name: Payments.Operator.fns.name),
                    .init(id: Payments.Operator.fnsUin.rawValue, name: Payments.Operator.fnsUin.name)
                ], placement: .top)
            
            return .init(parameters: [productParameter, amountParameter, operatorParameter], front: .init(visible: [operatorParameterId], isCompleted: true), back: .init(stage: .local, terms: [.init(parameterId: operatorParameterId, impact: .rollback)], processed: [.init(id: operatorParameterId, value: operatorParameterValue)]))
            
        case 1:
            guard let operatorParameterValue = paymentsParameterValue(operation.parameters, id: operatorParameterId),
                  let operatorSelected = Payments.Operator(rawValue: operatorParameterValue) else {
                throw Payments.Error.missingParameter(operatorParameterId)
            }
            
            switch operatorSelected {
            case .fns:
                let categoryParameterId = "a3_dutyCategory_1_1"
                guard let fnsCategoriesList = dictionaryFTSList() else {
                    throw Payments.Error.unableCreateRepresentable(categoryParameterId)
                }

                let categoryParameter = Payments.ParameterSelect(
                    Payments.Parameter(id: categoryParameterId, value: nil),
                    title: "Категория платежа",
                    options: fnsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample)})
                
                
                let divisionParameterId = "a3_divisionSelect_2_1"
                guard let anywayOperator = dictionaryAnywayOperator(for: operatorParameterValue),
                      let divisionAnywayParameter = anywayOperator.parameterList.first(where: { $0.id == divisionParameterId }),
                      let divisionAnywayParameterOptions = divisionAnywayParameter.options,
                      let divisionAnywayParameterValue = divisionAnywayParameter.value else {
                    
                    throw Payments.Error.unableCreateRepresentable(divisionParameterId)
                }
                
                // division
                let divisionParameter = Payments.ParameterSelectSimple(
                    Payments.Parameter(id: divisionParameterId, value: divisionAnywayParameterValue),
                    icon: divisionAnywayParameter.iconData ?? .parameterSample,
                    title: divisionAnywayParameter.title,
                    selectionTitle: "Выберете услугу",
                    options: divisionAnywayParameterOptions)
                
                return .init(parameters: [categoryParameter, divisionParameter], front: .init(visible: [categoryParameterId, divisionParameterId], isCompleted: false), back: .init(stage: .remote(.start), terms: [.init(parameterId: categoryParameterId, impact: .rollback), .init(parameterId: divisionParameterId, impact: .rollback)], processed: nil))
                
                
            case .fnsUin:
                let numberParameterId = "a3_BillNumber_1_1"
                let numberParameter = Payments.ParameterInput(
                    Payments.Parameter(id: numberParameterId, value: nil),
                    icon: .parameterDocument,
                    title: "УИН",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                
                return .init(parameters: [numberParameter], front: .init(visible: [numberParameterId], isCompleted: false), back: .init(stage: .remote(.start), terms: [.init(parameterId: numberParameterId, impact: .rollback)], processed: nil))
                
            default:
                throw Payments.Error.unsupported
            }
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    /*
    func parametersFNS(_ parameters: [PaymentsParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[PaymentsParameterRepresentable], Error>) -> Void) {
        
        let paramOperator = Payments.Parameter.Identifier.operator.rawValue
        
        switch step {
        case 0:
            
            /*
            if let operatorParameterValue = paymentsParameterValue(parameters, id: paramOperator),
                let operatorSelected = Operator(rawValue: operatorParameterValue) {
                
                // remove all search type depended parameters
                let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_dutyCategory_1_1", "a3_BillNumber_1_1"])
                
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
                        options: fnsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample)})
                    
                    completion(.success(updatedParameters + [categoryParameter]))
                    
                case .fnsUin:
                    
                    #if DEBUG
                    let numberParameter = Payments.ParameterInput(
                        Parameter(id: "a3_BillNumber_1_1", value: "18204437200029004095"),
                        icon: .parameterDocument,
                        title: "УИН",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    #else
                    let numberParameter = Payments.ParameterInput(
                        Parameter(id: "a3_BillNumber_1_1", value: nil),
                        icon: .parameterDocument,
                        title: "УИН",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    #endif
  
                    completion(.success(updatedParameters + [numberParameter]))
                    
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
                    ])
                
                // category
                guard let fnsCategoriesList = dictionaryFTSList() else {
                    completion(.failure(Payments.Error.unableLoadFTSCategoryOptions))
                    return
                }
                
                let categoryParameter = Payments.ParameterSelect(
                    Parameter(id: "a3_dutyCategory_1_1", value: nil),
                    title: "Категория платежа",
                    options: fnsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample)})
                
                completion(.success( parameters + [operatorParameter, categoryParameter]))
            }
             */
            break
            
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
                    
                    //TODO: refactor
                    /*
                    Task {
                        
                        // remove all division depended parameters
                        let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"])
                 
                        do {
                            
                            let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_dutyCategory_1_1", divisionParameterId], step: .initial)
                            #if DEBUG
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_INN_4_1": "7723013452", "a3_OKTMO_5_1": "45390000"])
                            #else
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                            #endif
                            
                            let additionalParameters = paymentsAdditionalParameters(for: transferStepData)

                            completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
                     */
                    
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
                        options: divisionAnywayParameterOptions)
                    
                    //TODO: refactor
                    /*
                    Task {
                        
                        do {
                            
                            let stepParameters = parameters + [divisionParameter]

                            let transferStepData = try await paymentsTransferAnywayStep(with: stepParameters, include: ["a3_dutyCategory_1_1", divisionParameterId], step: .initial)
                            #if DEBUG
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_INN_4_1": "7723013452", "a3_OKTMO_5_1": "45390000"])
                            #else
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                            #endif
                            
                            let additionalParameters = paymentsAdditionalParameters(for: transferStepData)
                            
                            completion(.success(stepParameters + nextStepParameters + additionalParameters))
                            
                        } catch {
     
                            completion(.failure(error))
                        }
                    }
                     */
                }

            case .fnsUin:
                
                //TODO: refactor
                /*
                Task {
                    
                    do {

                        let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_BillNumber_1_1"], step: .initial)
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        let additionalParameters = paymentsAdditionalParameters(for: transferStepData)
                        
                        completion(.success(parameters + nextStepParameters + additionalParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                 */
                break
 
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
            
        case 2:
            guard let operatorParameterValue = paymentsParameterValue(parameters, id: paramOperator),
                let operatorSelected = Operator(rawValue: operatorParameterValue) else {
                    
                    completion(.failure(Payments.Error.missingOperatorParameter))
                    return
                }
            //TODO: refactor
            /*
            switch operatorSelected {
            case .fns:
                
                //TODO: refactor
                /*
                Task {
                    
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"])
                    
                    do {
 
                        let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"], step: .next)
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        let additionalParameters = paymentsAdditionalParameters(for: transferStepData)

                        completion(.success(updatedParameters + nextStepParameters + additionalParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                 */
                
            case .fnsUin:
                //TODO: refactor
                /*
                Task {
                    
                    do {

                        let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_fio_4_1", "a3_address_10_1"], step: .next)
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
   
                        completion(.success(parameters + nextStepParameters ))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                 */
                
            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }
             */
            
            
        case 3:
            guard let operatorParameterValue = paymentsParameterValue(parameters, id: paramOperator),
                let operatorSelected = Operator(rawValue: operatorParameterValue) else {
                    
                    completion(.failure(Payments.Error.missingOperatorParameter))
                    return
                }
            
            switch operatorSelected {
            case .fns:
                
                //TODO: refactor
                /*
                if paymentsParametersContains(parameters, id: Payments.Parameter.Identifier.final.rawValue) {

                    // repeat all transfer steps from the begining
                    
                    Task {
                        
                        do {

                            try await paymentsTransferAnywayStep(with: parameters, include: ["a3_dutyCategory_1_1", "a3_divisionSelect_2_1"], step: .initial)
        
                            try await paymentsTransferAnywayStep(with: parameters, include: ["a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"], step: .next)
                            
                            try await paymentsTransferAnywayStep(with: parameters, include: ["a3_fio_1_2", "a3_address_2_2", "a3_docType_3_2", "a3_docValue_4_2"], step: .next)
           
                            completion(.success(parameters))
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
      
                } else {
                   
                    Task {
                        
                        // make all parameters not editable
                        let updatedParameters = paymentsParametersEditable(parameters, editable: false)
                        
                        do {
                            
                            let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_fio_1_2", "a3_address_2_2", "a3_docType_3_2", "a3_docValue_4_2"], step: .next)
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                            
                            completion(.success(updatedParameters + nextStepParameters))
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
                }
                 */
                break
                

            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }

        default:
            completion(.failure(Payments.Error.unsupported))
        }        
    }
     */
}
