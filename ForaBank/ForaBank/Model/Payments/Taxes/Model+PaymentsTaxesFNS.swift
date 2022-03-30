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
                        options: fnsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample)}, affectsHistory: true)
                    
                    completion(.success(updatedParameters + [categoryParameter]))
                    
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
                        Parameter(id: "a3_BillNumber_1_1", value: "18204437200029004095"),
                        icon: .parameterDocument,
                        title: "УИН",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
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
                        let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"])
                 
                        do {
                            
                            let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_dutyCategory_1_1", divisionParameterId], step: .initial)
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_INN_4_1": "7723013452", "a3_OKTMO_5_1": "45390000"])

                            completion(.success(updatedParameters + nextStepParameters))
                            
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
                            
                            let stepParameters = parameters + [divisionParameter]

                            let transferStepData = try await paymentsTransferAnywayStep(with: stepParameters, include: ["a3_dutyCategory_1_1", divisionParameterId], step: .initial)
                            let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_INN_4_1": "7723013452", "a3_OKTMO_5_1": "45390000"])

                            completion(.success(stepParameters + nextStepParameters))
                            
                        } catch {
     
                            completion(.failure(error))
                        }
                    }
                }

            case .fnsUin:
                Task {
                    
                    do {

                        let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_BillNumber_1_1"], step: .initial)
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        
                        completion(.success(parameters + nextStepParameters))
                        
                    } catch {
                        
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
                    
                    let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"])
                    
                    do {
 
                        let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"], step: .next)
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)

                        completion(.success(updatedParameters + nextStepParameters))
                        
                    } catch {
                        
                        print(error.localizedDescription)
                        completion(.failure(error))
                    }
                }
                
            case .fnsUin:
                Task {
                    
                    do {

                        let transferStepData = try await paymentsTransferAnywayStep(with: parameters, include: ["a3_fio_4_1", "a3_address_10_1"], step: .next)
                        print(transferStepData.parameterListForNextStep.map{ $0.debugDescription })
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData)
                        
                        completion(.success(parameters + nextStepParameters))
                        
                    } catch {
                        
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
                

            default:
                completion(.failure(Payments.Error.unexpectedOperatorValue))
            }

        default:
            completion(.failure(Payments.Error.unsupported))
        }        
    }
}
