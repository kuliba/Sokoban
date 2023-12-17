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
    
    enum SuccessTextID: Equatable {
        
        case successAmount
        case successTitle
    }
    
    enum SubscriberID: Equatable {
        
        case brandName
    }
    
    enum ID: Equatable {
        
        case successOptionButtons
        case buttonMain
    }
}
