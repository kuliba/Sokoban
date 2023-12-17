//
//  CreateSberQRPaymentIDs.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

/// A namespace.
public enum CreateSberQRPaymentIDs {}

public extension CreateSberQRPaymentIDs {
    
    enum ID: Equatable {
        
        case paymentOperationDetailId
        case printFormType
        case successStatus
        case successTitle
        case successAmount
        case brandName
        case successOptionButtons
        case buttonMain
    }
}
