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
            
            // header
            let anywayGroup = dictionaryAnywayOperatorGroup(for: Payments.Category.taxes.rawValue)
            
            let operatorsCodes = Payments.Category.taxes.services.compactMap{ $0.operators.first?.rawValue }
            let anywayOperators = anywayGroup?.operators.filter{ operatorsCodes.contains($0.code)}
            let taxesOperator = anywayOperators?.first(where: {$0.code == Payments.Operator.fssp.rawValue})
            
            let headerParameter = Payments.ParameterHeader(title: "ФССП", icon: .image(taxesOperator?.logotypeList.first?.iconData ?? .empty))
            
            // product
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            let filter = ProductData.Filter.generalFrom
            guard let product = firstProduct(with: filter) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            let productParameter = Payments.ParameterProduct(value: String(product.id), filter: filter, isEditable: true)

            // search type
            let searchTypeParameter = Payments.ParameterSelectDropDownList(
                .init(id: searchTypeParameterId, value: "20"),
                title: "Выберете тип",
                options: [
                    .init(id: "20", name: "Документ", icon: nil),
                    .init(id: "30", name: "УИН", icon: nil),
                    .init(id: "40", name: "ИП", icon: nil)
                ], placement: .top)
            
            return .init(parameters: [operatorParameter, headerParameter, productParameter, searchTypeParameter], front: .init(visible: [headerParameter.id, searchTypeParameter.id], isCompleted: true), back: .init(stage: .local, required: [searchTypeParameter.id], processed: [.init(id: searchTypeParameter.id, value: "20")] ))
            
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
                    placeholder: "Начните ввод для поиска",
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
    
    func paymentsProcessDependencyReducerFSSP(service: Payments.Service, parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
        
        switch parameterId {
        case "a3_docNumber_2_2":
            guard let docTypeParameterValue = parameters.first(where: { $0.id == "a3_docName_1_2" })?.value,
                  let docParameter = parameters.first(where: { $0.id == "a3_docNumber_2_2" }) as? Payments.ParameterInput else {
                return nil
            }
            
            switch docTypeParameterValue {
            case "20", "50", "60":
                return docParameter.updated(validator: Payments.Validation.RulesSystem(rules: [
                    Payments.Validation.LengthLimitsRule(lengthLimits: [10], actions: [.post: .warning("Должен состоять из 10 цифр")])
                ]), inputType: .number)
                
            case "30":
                return docParameter.updated(validator: Payments.Validation.RulesSystem(rules: [
                    Payments.Validation.LengthLimitsRule(lengthLimits: [10, 12], actions: [.post: .warning("Должен состоять из 10 или 12 цифр")])
                ]), inputType: .number)
                
            case "40":
                return docParameter.updated(validator: Payments.Validation.RulesSystem(rules: [
                    Payments.Validation.LengthLimitsRule(lengthLimits: [11], actions: [.post: .warning("Должен состоять из 11 цифр")])
                ]), inputType: .number)
                
            default:
                return nil
            }

        default:
            return nil
        }
    }
    
    func paymentsMockFSSP() -> Payments.Mock {
        
        return .init(service: .fssp,
                     parameters: [.init(id: "a3_BillNumber_1_1", value: "32227009220006631003"),
                                  .init(id: "a3_IPnumber_1_1", value: "6631/22/27009-ИП"),
                                  .init(id: "a3_docNumber_2_2", value: "13420742521")])
                                    //.init(id: "a3_docNumber_2_2", value: "7816218222")
                                    //.init(id: "a3_docNumber_2_2", value: "13420742521")
    }
}
