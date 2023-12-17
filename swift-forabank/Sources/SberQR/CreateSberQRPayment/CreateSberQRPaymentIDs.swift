//
//  CreateSberQRPaymentIDs.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

/// A namespace.
public enum CreateSberQRPaymentIDs {}

public extension CreateSberQRPaymentIDs {
    
    enum ButtonID: Equatable {
        
        case buttonMain
    }
    
    enum DataLongID: Equatable {
        
        case paymentOperationDetailId
    }
    
    enum DataStringID: Equatable {
        
        case printFormType
    }
    
    enum SubscriberID: Equatable {
        
        case brandName
    }
    
    enum SuccessOptionButtonsID: Equatable {
        
        case successOptionButtons
    }
    
    enum SuccessStatusID: Equatable {
        
        case successStatus
    }
    
    enum SuccessTextID: Equatable {
        
        case successAmount
        case successTitle
    }
}
