//
//  Model+PaymentsTaxes.swift
//  ForaBank
//
//  Created by Max Gribov on 09.02.2022.
//

import Foundation

extension Model {
    
    func paymentsStepFMS(_ operation: Payments.Operation, for stepIndex: Int) async throws -> Payments.Operation.Step {

        switch stepIndex {
        case 0:
            
            // operator
            let operatorParameter = Payments.ParameterOperator(operatorType: .fms)
            
            // header
            let anywayGroup = dictionaryAnywayOperatorGroup(for: Payments.Category.taxes.rawValue)
            
            let operatorsCodes = Payments.Category.taxes.services.compactMap{ $0.operators.first?.rawValue }
            let anywayOperators = anywayGroup?.operators.filter{ operatorsCodes.contains($0.code)}
            let taxesOperator = anywayOperators?.first(where: {$0.code == Payments.Operator.fms.rawValue})
            
            let headerParameter = Payments.ParameterHeader(title: "ФМС", icon: .image(taxesOperator?.logotypeList.first?.iconData ?? .empty))
            
            // product
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            let filter = ProductData.Filter.generalFrom
            guard let product = firstProduct(with: filter) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            let productParameter = Payments.ParameterProduct(value: String(product.id), filter: filter, isEditable: true)
            
            // category
            guard let fmsCategoriesList = dictionaryFMSList()  else {
                throw Payments.Error.missingParameter("a3_dutyCategory_1_1")
            }
            
            let categoryParameter = Payments.ParameterSelect(
                Payments.Parameter(id: "a3_dutyCategory_1_1", value: nil),
                title: "Категория платежа",
                placeholder: "Начните ввод для поиска",
                options: fmsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample) })
            
            return .init(parameters: [operatorParameter, headerParameter, productParameter, categoryParameter], front: .init(visible: [headerParameter.id, categoryParameter.id], isCompleted: false), back: .init(stage: .remote(.start), required: [categoryParameter.id], processed: nil))
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    func paymentsMockFMS() -> Payments.Mock {
        
        return .init(service: .fms,
                     parameters: [.init(id: "a3_INN_4_1", value: "4028003880"),
                                  .init(id: "a3_OKTMO_5_1", value: "29701000"),
                                  .init(id: "a3_docType_3_2", value: "2"),
                                  .init(id: "a3_docValue_4_2", value: "7723013452")])
    }
}
