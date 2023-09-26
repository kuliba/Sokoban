//
//  PaymentTemplateData+Stubs.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 01.06.2023.
//

import Foundation
@testable import ForaBank

extension PaymentTemplateData {
    
    static func getTemplate(
        groupName: String,
        name: String,
        parameterList: [TransferData],
        paymentTemplateId: Int,
        productTemplate: ProductTemplateData? = nil,
        sort: Int,
        svgImage: SVGImageData,
        type: Kind
    ) -> PaymentTemplateData {
            
            return PaymentTemplateData(
                groupName: groupName,
                name: name,
                parameterList: parameterList,
                paymentTemplateId: paymentTemplateId,
                productTemplate: productTemplate,
                sort: sort,
                svgImage: svgImage,
                type: type)
        }
    
    static func templateStub(
        paymentTemplateId: Int = 2513,
        type: Kind,
        name: String = "name",
        parameterList: [TransferData] = TransferGeneralData.generalStub()
    ) -> PaymentTemplateData {
        
        let template = getTemplate(
            groupName: "groupName",
            name: name,
            parameterList: parameterList,
            paymentTemplateId: paymentTemplateId,
            sort: 0,
            svgImage: .init(description: ""),
            type: type)
        
        return .init(
            groupName: template.groupName,
            name: template.name,
            parameterList: parameterList,
            paymentTemplateId: template.id,
            productTemplate: template.productTemplate,
            sort: template.sort,
            svgImage: template.svgImage,
            type: type)
    }
}
