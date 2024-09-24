//
//  FailedPaymentProviderPickerContentState.swift
//
//
//  Created by Igor Malyarov on 23.09.2024.
//

public struct FailedPaymentProviderPickerContentState: Equatable {
    
    public var selection: Selection?
    
    public init(selection: Selection? = nil) {
     
        self.selection = selection
    }
}

public extension FailedPaymentProviderPickerContentState {
    
    enum Selection: Equatable {
        
        case detailPay
    }
}
