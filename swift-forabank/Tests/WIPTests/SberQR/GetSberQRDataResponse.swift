//
//  GetSberQRDataResponse.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation

struct GetSberQRDataResponse: Equatable {
    
    let qrcID: String
    let parameters: [Parameter]
    let required: [Required]
}

extension GetSberQRDataResponse {
    
    enum Parameter: Equatable {
        
        case amount(Amount)
        case button(Button)
        case dataString(DataString)
        case header(Header)
        case info(Info)
        case productSelect(ProductSelect)
    }
}

extension GetSberQRDataResponse {
    
    enum Required: Equatable {
        
        case debitAccount
        case paymentAmount
        case currency
    }
}
