//
//  RootViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SberQR

typealias MakeSberQRConfirmPaymentWrapperView = (SberQRConfirmPaymentViewModel) -> SberQRConfirmPaymentWrapperView

struct RootViewFactory {
    
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentWrapperView
}
