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
    let makeIconView: MakeIconView
    let makeActivateSliderView: MakeActivateSliderView
    let makeUpdateInfoView: MakeUpdateInfoView
    let makeAnywayPaymentFactory: MakeAnywayPaymentFactory
    let makePaymentCompleteView: MakePaymentCompleteView
    let makeHistoryButtonView: () -> any View
}

extension RootViewFactory {
    
    typealias MakeIconView = IconDomain.MakeIconView
    typealias MakeAnywayPaymentFactory = PaymentsTransfersViewFactory.MakeAnywayPaymentFactory
    typealias MakePaymentCompleteView = PaymentsTransfersViewFactory.MakePaymentCompleteView
}

extension RootViewFactory {
    
    var mainViewFactory: MainViewFactory {
        
        return .init(
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeUserAccountView: makeUserAccountView,
            makeUpdateInfoView: makeUpdateInfoView
        )
    }
}

extension RootViewFactory {
    
    var paymentsTransfersViewFactory: PaymentsTransfersViewFactory {
        
        return .init(
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeUserAccountView: makeUserAccountView,
            makeIconView: makeIconView,
            makeUpdateInfoView: makeUpdateInfoView,
            makeAnywayPaymentFactory: makeAnywayPaymentFactory,
            makePaymentCompleteView: makePaymentCompleteView
        )
    }
}

struct ProductProfileViewFactory {
    
    let makeHistoryButton: (@escaping (HistoryEvent) -> Void) -> HistoryButtonView
    let makeActivateSliderView: MakeActivateSliderView
}

extension RootViewFactory {
    
    var productProfileViewFactory: ProductProfileViewFactory {
 
        .init(
            makeHistoryButton: { event in
                HistoryButtonView(active: true, event: event)
            },
            makeActivateSliderView: makeActivateSliderView
        )
    }
}

struct HistoryButtonView: View {
    
    let active: Bool
    let event: (HistoryEvent) -> Void
    
    var body: some View {
        
        if active {
            Text("2")
        } else {
            EmptyView()
        }
    }
}
