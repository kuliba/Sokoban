//
//  GetSberQRDataResponse.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation

public struct GetSberQRDataResponse: Equatable {
    
    let qrcID: String
    let parameters: [Parameter]
    let required: [Required]
    
    public init(
        qrcID: String, 
        parameters: [Parameter],
        required: [Required]
    ) {
        self.qrcID = qrcID
        self.parameters = parameters
        self.required = required
    }
}

public extension GetSberQRDataResponse {
    
    enum Parameter: Equatable {
        
        case amount(Amount)
        case button(Button)
        case dataString(DataString)
        case header(Header)
        case info(Info)
        case productSelect(ProductSelect)
    }
}

public extension GetSberQRDataResponse {
    
    enum Required: Equatable {
        
        case debitAccount
        case paymentAmount
        case currency
    }
}

public extension GetSberQRDataResponse {
    
    var filterProductTypes: [GetSberQRDataResponse.Parameter.ProductSelect.Filter.ProductType] {
        
        parameters
            .flatMap {
                switch $0 {
                case let .productSelect(productSelect):
                    return productSelect.filter.productTypes
                    
                default:
                    return []
                }
            }
    }
}
