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
            
            // product
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            guard let productId = firstProductId(of: .card, currency: .rub) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            let productParameter = Payments.ParameterProduct(value: String(productId), isEditable: true)
            
            // category
            guard let fmsCategoriesList = dictionaryFMSList()  else {
                throw Payments.Error.missingParameter("a3_dutyCategory_1_1")
            }
            
            let categoryParameter = Payments.ParameterSelect(
                Payments.Parameter(id: "a3_dutyCategory_1_1", value: nil),
                title: "Категория платежа",
                options: fmsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample) })
            
            return .init(parameters: [operatorParameter, productParameter, categoryParameter], front: .init(visible: [categoryParameter.id], isCompleted: false), back: .init(stage: .remote(.start), required: [categoryParameter.id], processed: nil))
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    func paymentsMockFMS() -> Payments.Mock {
        
        return .init(service: .fms,
                     parameters: [.init(id: "a3_INN_4_1", value: "5503026780"),
                                  .init(id: "a3_OKTMO_5_1", value: "52643151"),
                                  .init(id: "a3_docType_3_2", value: "2"),
                                  .init(id: "a3_docValue_4_2", value: "7723013452")])
    }
}
