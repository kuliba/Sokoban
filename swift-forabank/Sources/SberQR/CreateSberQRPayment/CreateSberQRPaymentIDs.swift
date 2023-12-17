//
//  CreateSberQRPaymentIDs.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

/// A namespace.
public enum CreateSberQRPaymentIDs {}

public extension CreateSberQRPaymentIDs {
    
    enum DataLongID: Equatable {
        
        case paymentOperationDetailId
    }
    
    enum ID: Equatable {
        
        case printFormType
        case successStatus
        case successTitle
        case successAmount
        case brandName
        case successOptionButtons
        case buttonMain
    }
}
