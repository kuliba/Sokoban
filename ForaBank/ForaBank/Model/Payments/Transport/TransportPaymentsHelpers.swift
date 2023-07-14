//
//  TransportPaymentsHelpers.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.06.2023.
//

extension Model {
    
    func transportHeader(
        forPuref puref: String,
        title: String
    ) -> Payments.ParameterHeader {
        
        let logo = operatorLogo(forPuref: puref)
        
        return .init(
            title: title,
            subtitle: nil,
            icon: logo.map(Payments.ParameterHeader.Icon.image)
        )
    }
    
    func transportProduct() throws -> Payments.ParameterProduct {
        
        let filter = ProductData.Filter.generalFrom
        let product = try firstProductToPayFrom(filter: filter)
        
        return .init(
            value: String(product.id),
            filter: filter,
            isEditable: true
        )
    }
}
