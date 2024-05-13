//
//  RootViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SberQR
import ActivateSlider
import SwiftUI

typealias MakeSberQRConfirmPaymentView = (SberQRConfirmPaymentViewModel) -> SberQRConfirmPaymentWrapperView
typealias MakePaymentsTransfersView = (PaymentsTransfersViewModel) -> PaymentsTransfersView
typealias MakeUserAccountView = (UserAccountViewModel) -> UserAccountView
typealias MakeActivateSliderView = (ProductData.ID, ActivateSliderViewModel, SliderConfig) -> ActivateSliderStateWrapperView

struct RootViewFactory {
    
    let makePaymentsTransfersView: MakePaymentsTransfersView
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeUserAccountView: MakeUserAccountView
    let makeActivateSliderView: MakeActivateSliderView
}

struct MainViewFactory {
    
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeUserAccountView: MakeUserAccountView
}

extension RootViewFactory {
    
    var mainViewFactory: MainViewFactory {
        
        .init(
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeUserAccountView: makeUserAccountView
        )
    }
}

struct PaymentsTransfersViewFactory {
    
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeUserAccountView: MakeUserAccountView
}

extension RootViewFactory {
    
    var paymentsTransfersViewFactory: PaymentsTransfersViewFactory {
 
        .init(
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeUserAccountView: makeUserAccountView
        )
    }
}

struct ProductProfileViewFactory {
    
    let makeActivateSliderView: MakeActivateSliderView
}

extension RootViewFactory {
    
    var productProfileViewFactory: ProductProfileViewFactory {
 
        .init(
            makeActivateSliderView: makeActivateSliderView
        )
    }
}
