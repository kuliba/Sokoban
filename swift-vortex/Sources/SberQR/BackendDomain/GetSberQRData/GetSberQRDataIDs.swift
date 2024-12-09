//
//  GetSberQRDataIDs.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

import Tagged

/// A namespace.
public enum GetSberQRDataIDs {}

public extension GetSberQRDataIDs {
    
    enum AmountID: Equatable {
        
        case paymentAmount
    }
    
    enum ButtonID: Equatable {
        
        case buttonPay
    }
    
    enum DataStringID: Equatable {
        
        case currency
    }
    
    enum HeaderID: Equatable {
        
        case title
    }
    
    enum InfoID: Equatable {
        
        case amount, brandName, recipientBank
    }
    
    enum ProductSelectID: Equatable {
        
        case debit_account
    }
}
