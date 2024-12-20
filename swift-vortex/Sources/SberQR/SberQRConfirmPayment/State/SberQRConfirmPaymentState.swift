//
//  SberQRConfirmPaymentState.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation

public struct SberQRConfirmPaymentState: Equatable {

    public var confirm: SberQRConfirmPaymentStateOf<GetSberQRDataResponse.Parameter.Info>
    public var isInflight: Bool
    
    public init(
        confirm: SberQRConfirmPaymentStateOf<GetSberQRDataResponse.Parameter.Info>, 
        isInflight: Bool = false
    ) {
        self.confirm = confirm
        self.isInflight = isInflight
    }
}
