//
//  RootViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SberQR
import SwiftUI

typealias MakeSberQRConfirmPaymentView = (SberQRConfirmPaymentViewModel) -> SberQRConfirmPaymentWrapperView

struct RootViewFactory {
    
    typealias MakePaymentsTransfersView = (PaymentsTransfersViewModel) -> PaymentsTransfersView
    
    let makePaymentsTransfersView: MakePaymentsTransfersView
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
}

struct MainViewFactory {
    
    typealias MakeUserAccountView = (UserAccountViewModel) -> UserAccountView
    
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeUserAccountView: MakeUserAccountView
}
