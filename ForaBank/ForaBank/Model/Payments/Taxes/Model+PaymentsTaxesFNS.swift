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
            
            // operator
            let operatorParameterValue = Payments.Operator.fns.rawValue
            let operatorParameter = Payments.ParameterSelectSwitch(
                .init(id: operatorParameterId, value: operatorParameterValue),
                options: [
                    .init(id: Payments.Operator.fns.rawValue, name: Payments.Operator.fns.name),
                    .init(id: Payments.Operator.fnsUin.rawValue, name: Payments.Operator.fnsUin.name)
                ], placement: .top)
            
            return .init(parameters: [productParameter, operatorParameter], front: .init(visible: [operatorParameterId], isCompleted: true), back: .init(stage: .local, required: [operatorParameterId], processed: [.init(id: operatorParameterId, value: operatorParameterValue)]))
            
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
                
                return .init(parameters: [categoryParameter, divisionParameter], front: .init(visible: [categoryParameterId, divisionParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [categoryParameterId, divisionParameterId], processed: nil))
                
            case .fnsUin:
                let numberParameterId = "a3_BillNumber_1_1"
                let numberParameter = Payments.ParameterInput(
                    Payments.Parameter(id: numberParameterId, value: nil),
                    icon: .parameterDocument,
                    title: "УИН",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                
                return .init(parameters: [numberParameter], front: .init(visible: [numberParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [numberParameterId], processed: nil))
                
            default:
                throw Payments.Error.unsupported
            }
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    func paymentsMockFNS() -> Payments.Mock {
        
        return .init(service: .fns,
                     parameters: [.init(id: "a3_BillNumber_1_1", value: "18204437200029004095"),
                                  .init(id: "a3_INN_4_1", value: "7723013452"),
                                  .init(id: "a3_OKTMO_5_1", value: "45390000"),
                                  .init(id: "a3_docValue_4_2", value: "7723013452")])
    }
}
