//
//  GetSberQRDataResponse+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2023.
//

import SberQR

extension GetSberQRDataResponse {
    
    var productTypes: [ProductType] {
        
        filterProductTypes.map(\.productType)
    }
}

private extension GetSberQRDataResponse.Parameter.ProductSelect.Filter.ProductType {
    
    var productType: ProductType {
        
        switch self {
        case .account: return .account
        case .card:    return .card
        }
    }
}

extension GetSberQRDataResponse {
    
    var currencies: [String] {
        
        filterCurrencies.map(\.currency)
    }
}

private extension GetSberQRDataResponse.Parameter.ProductSelect.Filter.Currency {
    
    var currency: String {
        
        switch self {
        case .rub: return "RUB"
        }
    }
}
