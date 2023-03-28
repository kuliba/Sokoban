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
            let filter = ProductData.Filter.generalFrom
            guard let product = firstProduct(with: filter) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            let productParameter = Payments.ParameterProduct(value: String(product.id), filter: filter, isEditable: true)
            
            // header
            let anywayGroup = dictionaryAnywayOperatorGroup(for: Payments.Category.taxes.rawValue)
            
            let operatorsCodes = Payments.Category.taxes.services.compactMap{ $0.operators.first?.rawValue }
            let anywayOperators = anywayGroup?.operators.filter{ operatorsCodes.contains($0.code)}
            let taxesOperator = anywayOperators?.first(where: {$0.code == Payments.Operator.fns.rawValue})
            
            let headerParameter = Payments.ParameterHeader(title: "ФНС", icon: .image(taxesOperator?.logotypeList.first?.iconData ?? .empty))
            
            // operator
            let operatorParameterValue = Payments.Operator.fns.rawValue
            let operatorParameter = Payments.ParameterSelectDropDownList(
                .init(id: operatorParameterId, value: operatorParameterValue),
                title: "Перевести",
                options: [
                    .init(id: Payments.Operator.fns.rawValue, name: Payments.Operator.fns.name, icon: .init(named: "ic24Emblem")),
                    .init(id: Payments.Operator.fnsUin.rawValue, name: Payments.Operator.fnsUin.name, icon: .init(named: "ic24FileHash"))
                ], placement: .top)
            
            return .init(parameters: [productParameter, headerParameter, operatorParameter], front: .init(visible: [headerParameter.id, operatorParameterId], isCompleted: true), back: .init(stage: .local, required: [operatorParameterId], processed: [.init(id: operatorParameterId, value: operatorParameterValue)]))
            
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
                    placeholder: "Начните ввод для поиска",
                    options: fnsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample)})
                
                let divisionParameterId = "a3_divisionSelect_2_1"
                guard let anywayOperator = dictionaryAnywayOperator(for: operatorParameterValue),
                      let divisionAnywayParameter = anywayOperator.parameterList.first(where: { $0.id == divisionParameterId }),
                      let divisionAnywayParameterOptions = divisionAnywayParameter.options(style: .general),
                      let divisionAnywayParameterValue = divisionAnywayParameter.value else {
                    
                    throw Payments.Error.unableCreateRepresentable(divisionParameterId)
                }
                
                // division
                let divisionParameter = Payments.ParameterSelect(
                    .init(id: divisionParameterId, value: divisionAnywayParameterValue),
                    icon: divisionAnywayParameter.iconData,
                    title: divisionAnywayParameter.title,
                    placeholder: "Начните ввод для поиска",
                    options: divisionAnywayParameterOptions.map({ .init(id: $0.id, name: $0.name, icon: nil)}))
                
                return .init(parameters: [categoryParameter, divisionParameter], front: .init(visible: [categoryParameterId, divisionParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [categoryParameterId, divisionParameterId], processed: nil))
                
            case .fnsUin:
                let numberParameterId = "a3_BillNumber_1_1"
                
                let numberParameterValidator = Payments.Validation.RulesSystem(rules: [
                    Payments.Validation.LengthLimitsRule(lengthLimits: [20, 25], actions: [.post: .warning("Должен состоять из 20 или 25 цифр")])
                ])
                
                let numberParameter = Payments.ParameterInput(
                    Payments.Parameter(id: numberParameterId, value: nil),
                    icon: .parameterDocument,
                    title: "УИН",
                    validator: numberParameterValidator,
                    inputType: .number)
                
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
