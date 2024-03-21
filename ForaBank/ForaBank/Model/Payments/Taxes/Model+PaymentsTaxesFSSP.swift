//
//  Model+PaymentsTaxesFSSP.swift
//  ForaBank
//
//  Created by Max Gribov on 15.03.2022.
//

import Foundation

extension Model {
    
    func paymentsStepFSSP(_ operation: Payments.Operation, for stepIndex: Int) throws -> Payments.Operation.Step {
        
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
               
            let headerParameter: Payments.ParameterHeader = parameterHeader(
                source: operation.source,
                header: .init(
                    title: "ФССП",
                    icon: .image(taxesOperator?.logotypeList.first?.iconData ?? .empty))
            )
            
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
                title: "Выберите тип",
                options: [
                    .init(id: "20", name: "Документ", icon: .image(ImageData(named: "ic24FileHash") ?? .empty)),
                    .init(id: "30", name: "УИН", icon: .image(ImageData(named: "ic24Hash") ?? .empty)),
                    .init(id: "40", name: "ИП", icon: .image(ImageData(named: "ic24Hammer") ?? .empty))
                ], placement: .top)
            
            return .init(parameters: [operatorParameter, headerParameter, productParameter, searchTypeParameter], front: .init(visible: [headerParameter.id, searchTypeParameter.id], isCompleted: true), back: .init(stage: .remote(.start), required: [searchTypeParameter.id], processed: nil))
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    func paymentsParameterRepresentableTaxesFSSP(operation: Payments.Operation, parameterData: ParameterData) throws -> PaymentsParameterRepresentable? {
        
        switch parameterData.id {
        case "a3_docName_1_2":
            guard let fsspDocumentList = dictionaryFSSPDocumentList() else {
                throw Payments.Error.missingParameter(parameterData.id)
            }
            
            return Payments.ParameterSelect(
                Payments.Parameter(id: parameterData.id, value: parameterData.value),
                title: "Тип документа",
                placeholder: "Начните ввод для поиска",
                options: fsspDocumentList.map{ .init(id: $0.value, name: $0.text, icon: .image(ImageData(with: $0.svgImage) ?? .parameterSample)) })
            
        default:
            switch parameterData.view {
            case .input:
                let limitator = Payments.Limitation(limit: 30)
                switch parameterData.id {
                case "a3_lastName_1_4", "a3_lastName_1_3", "a3_lastName_1_2":
                    return Payments.ParameterInput(
                        .init(id: parameterData.id, value: parameterData.value),
                        icon: parameterData.iconData ?? .parameterDocument,
                        title: parameterData.title,
                        validator: .baseName,
                        limitator: limitator,
                        group: .init(id: "fio", type: .contact))
                    
                case "a3_firstName_2_4", "a3_firstName_2_3", "a3_firstName_2_2":
                    return Payments.ParameterInput(
                        .init(id: parameterData.id, value: parameterData.value),
                        icon: nil,
                        title: parameterData.title,
                        validator: .baseName,
                        limitator: limitator,
                        group: .init(id: "fio", type: .contact))
                    
                case "a3_middleName_3_4", "a3_middleName_3_3", "a3_middleName_3_2":
                    //TODO: replace validator with OptionalRegExpRule
                    return Payments.ParameterInput(
                        .init(id: parameterData.id, value: parameterData.value),
                        icon: nil,
                        title: parameterData.title,
                        validator: parameterData.validator,
                        limitator: limitator,
                        group: .init(id: "fio", type: .contact))
                    
                default:
                    return try paymentsParameterRepresentable(parameterData: parameterData)
                }
                
            default:
                return try paymentsParameterRepresentable(parameterData: parameterData)
            }
        }
    }
    
    func paymentsProcessDependencyReducerFSSP(parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
        
        switch parameterId {
        case "a3_docNumber_2_2":
            
            guard let searchType = try? parameters.value(forId: "a3_SearchType_1_1"),
                  let documentParameter = try? parameters.parameter(forId: "a3_docNumber_2_2", as: Payments.ParameterInput.self) else {
                return nil
            }
            
            switch searchType {
            case "20": // document
                guard let documentType = try? parameters.value(forId: "a3_docName_1_2") else {
                    return nil
                }
                
                switch documentType {
                case "20", "50", "60":
                    return documentParameter.updated(validator: Payments.Validation.RulesSystem(rules: [
                        Payments.Validation.LengthLimitsRule(lengthLimits: [10], actions: [.post: .warning("Должен состоять из 10 цифр")])
                    ]), inputType: .number)
                    
                case "30":
                    return documentParameter.updated(validator: Payments.Validation.RulesSystem(rules: [
                        Payments.Validation.LengthLimitsRule(lengthLimits: [10, 12], actions: [.post: .warning("Должен состоять из 10 или 12 цифр")])
                    ]), inputType: .number)
                    
                case "40":
                    return documentParameter.updated(validator: Payments.Validation.RulesSystem(rules: [
                        Payments.Validation.LengthLimitsRule(lengthLimits: [11], actions: [.post: .warning("Должен состоять из 11 цифр")])
                    ]), inputType: .number)
                    
                default:
                    return nil
                }
                
            case "30": //UIN
                return documentParameter.updated(validator: Payments.Validation.RulesSystem(rules: [
                    Payments.Validation.LengthLimitsRule(lengthLimits: [20, 25], actions: [.post: .warning("Должен состоять из 20 или 25 цифр")]),
                    Payments.Validation.RegExpRule(regExp: "^([0-9]{20}|[0-9]{25})$", actions: [.post: .warning("Должен состоять из 20 или 25 цифр")])
                ]), inputType: .number)
                
            case "40": //IP
                return documentParameter.updated(validator: Payments.Validation.RulesSystem(rules: [
                    Payments.Validation.RegExpRule(regExp: "^[0-9]{1,7}[/][0-9]{2}[/][0-9]{2}[/][0-9]{2}$|^[0-9]{1,7}[/][0-9]{2}[/][0-9]{5}-ИП$", actions: [.post: .warning("Пример: 1108/10/41/33 или 107460/09/21014-И")])
                ]), inputType: .number)
                
            default:
                return nil
            }

        default:
            return nil
        }
    }
    
    //MARK: - resets visible items and order
    
    func paymentsProcessOperationResetVisibleTaxesFSSP(_ operation: Payments.Operation) async throws -> [Payments.Parameter.ID]? {
        
        // check if current step stage is confirm
        guard case .remote(let remote) = operation.steps.last?.back.stage,
              remote == .confirm else {
            return nil
        }
        
        return operation.parametersIds.filter { $0 != Payments.Parameter.Identifier.amount.rawValue }
    }
    
    func paymentsMockFSSP() -> Payments.Mock {
        
        return .init(service: .fssp,
                     parameters: [.init(id: "a3_BillNumber_1_1", value: "32227009220006631003"),
                                  .init(id: "a3_IPnumber_1_1", value: "6631/22/27009-ИП"),
                                  .init(id: "a3_docNumber_2_2", value: "12345678901")])
//                                    .init(id: "a3_docNumber_2_2", value: "7816218222")])
                                    //.init(id: "a3_docNumber_2_2", value: "13420742521")
    }
}
