//
//  GetSberQRDataIDs.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

import Foundation
import Tagged

/// A namespace.
public enum GetSberQRDataIDs {}

public extension GetSberQRDataIDs {
    
    enum AmountID: String, Equatable {
        
        case paymentAmount = "payment_amount"
    }
    
    enum ButtonID: String, Equatable {
        
        case buttonPay = "button_pay"
    }
    
    enum DataStringID: String, Equatable {
        
        case currency
    }
    
    enum HeaderID: String, Equatable {
        
        case title
    }
    
    enum InfoID: String, Equatable {
        
        case amount, brandName, recipientBank
    }
    
    typealias ProductSelectID = Tagged<_ProductSelectID, String>
    enum _ProductSelectID {}

}
