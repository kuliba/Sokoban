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
    
    enum DataStringID: Equatable {
        
        case printFormType
    }
    
    enum SuccessStatusID: Equatable {
        
        case successStatus
    }
    
    enum ID: Equatable {
        
        case successTitle
        case successAmount
        case brandName
        case successOptionButtons
        case buttonMain
    }
}
