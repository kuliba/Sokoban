//
//  Model+PaymentsTaxes.swift
//  ForaBank
//
//  Created by Max Gribov on 09.02.2022.
//

import Foundation

extension Model {
    
    func parametersFMS(_ parameters: [ParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[ParameterRepresentable], Error>) -> Void) {
        
        let paramOperator = Payments.Parameter.Identifier.operator.rawValue
        
        switch step {
        case 0:
            
            // operator
            let operatorParameter = Payments.ParameterOperator(operatorType: .fms)
            
            // category
            guard let fmsCategoriesList = dictionaryFMSList()  else {
                completion(.failure(Payments.Error.unableLoadFMSCategoryOptions))
                return
            }
            
            let categoryParameter = Payments.ParameterSelect(
                Parameter(id: "a3_dutyCategory_1_1", value: nil),
                title: "Категория платежа",
                options: fmsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample) }, affectsHistory: true)
            
            completion(.success( parameters + [operatorParameter, categoryParameter]))
            
        case 1:
            
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let anywayOperator = dictionaryAnywayOperator(for: operatorValue) else {
                      
                      completion(.failure(Payments.Error.missingOperatorParameter))
                      return
                  }
            
            let divisionParameterId = "a3_divisionSelect_2_1"
            if paymentsParametersContains(parameters, id: divisionParameterId) {
                
                // user did update division parameter value
                
                Task {
                    
                    // remove all division depended parameters
                    let updatedParameters = paymentsParametersRemove(parameters, filter: ["a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"])
                    
                    do {
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_dutyCategory_1_1", divisionParameterId], step: .initial)
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_INN_4_1": "5503026780", "a3_OKTMO_5_1": "52643151"])
                        
                        completion(.success(updatedParameters + nextStepParameters))
                        
                    } catch {
                        
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
                    selectionTitle: "Выберете подразделение",
                    options: divisionAnywayParameterOptions,
                    affectsHistory: true)
                
                Task {
                    
                    do {
                        
                        let stepParameters = parameters + [divisionParameter]
                        
                        let transferStepData = try await paymentsTransferAnywayStep(with: stepParameters, include: ["a3_dutyCategory_1_1", divisionParameterId], step: .initial)
                        let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_INN_4_1": "5503026780", "a3_OKTMO_5_1": "52643151"])
  
                        completion(.success(stepParameters + nextStepParameters))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
            }
            
        case 2:
            
            Task {
                
                let updatedParameters = paymentsParametersEditable(parameters, editable: false, filter: ["a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"])
                
                do {
                    
                    let transferStepData = try await paymentsTransferAnywayStep(with: updatedParameters, include: ["a3_categorySelect_3_1", "a3_INN_4_1", "a3_OKTMO_5_1", "a3_DIVISION_4_1"], step: .next)
                    
                    let clientInfo = try await paymentsTransferClientInfo()
                    let nextStepParameters = try paymentsTaxesNextStepParameters(for: transferStepData, samples: ["a3_docType_3_2": "1", "a3_docValue_4_2": clientInfo.pasportNumber ])

                    completion(.success(updatedParameters + nextStepParameters))
                    
                } catch {
                    
                    completion(.failure(error))
                }
            }
            
        case 3:
            
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
            completion(.failure(Payments.Error.unsupported))
        }
    }
}
