//
//  RootViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import ActivateSlider
import AnywayPaymentDomain
import SberQR
import SwiftUI
import MarketShowcase

typealias MakeActivateSliderView = (ProductData.ID, ActivateSliderViewModel, SliderConfig) -> ActivateSliderStateWrapperView
typealias MakeAnywayPaymentFactory = (@escaping (AnywayPaymentEvent) -> Void) -> AnywayPaymentFactory<IconDomain.IconView>
typealias MakeHistoryButtonView = (@escaping (HistoryEvent) -> Void) -> HistoryButtonView?
typealias MakeRepeatButtonView = (@escaping () -> Void) -> RepeatButtonView?
typealias MakeIconView = IconDomain.MakeIconView
typealias MakePaymentCompleteView = (Completed, @escaping () -> Void) -> PaymentCompleteView
typealias MakePaymentsTransfersView = (PaymentsTransfersViewModel) -> PaymentsTransfersView
typealias MakeSberQRConfirmPaymentView = (SberQRConfirmPaymentViewModel) -> SberQRConfirmPaymentWrapperView
typealias MakeUserAccountView = (UserAccountViewModel) -> UserAccountView

typealias MakeMarketShowcaseContentView = (MarketShowcaseDomain.Binder) -> MarketShowcaseContentWrapperView<SpinnerRefreshView, MarketShowcaseDomain.Landing>?

typealias Completed = UtilityServicePaymentFlowState.FullScreenCover.Completed

struct RootViewFactory {
    
    let makeActivateSliderView: MakeActivateSliderView
    let makeAnywayPaymentFactory: MakeAnywayPaymentFactory
    let makeHistoryButtonView: MakeHistoryButtonView
    let makeIconView: MakeIconView
    let makeGeneralIconView: MakeIconView
    let makePaymentCompleteView: MakePaymentCompleteView
    let makePaymentsTransfersView: MakePaymentsTransfersView
    let makeReturnButtonView: MakeRepeatButtonView
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeInfoViews: MakeInfoViews
    let makeUserAccountView: MakeUserAccountView
    let makeMarketShowcaseContentView: MakeMarketShowcaseContentView
}

extension RootViewFactory {
    
    struct MakeInfoViews {
        
        let makeUpdateInfoView: MakeUpdateInfoView
        let makeDisableCorCardsInfoView: MakeDisableForCorCardsInfoView
    }
}

extension RootViewFactory {
    
    typealias MakeIconView = IconDomain.MakeIconView
}

extension RootViewFactory {
    
    var mainViewFactory: MainViewFactory {
        
        return .init(
            makeAnywayPaymentFactory: makeAnywayPaymentFactory,
            makeIconView: makeIconView,
            makeGeneralIconView: makeGeneralIconView,
            makePaymentCompleteView: makePaymentCompleteView,
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeInfoViews: makeInfoViews,
            makeUserAccountView: makeUserAccountView
        )
    }
}

extension RootViewFactory {
    
    var paymentsTransfersViewFactory: PaymentsTransfersViewFactory {
        
        return mainViewFactory
    }
}

struct ProductProfileViewFactory {
    
    let makeActivateSliderView: MakeActivateSliderView
    let makeHistoryButton: (@escaping (HistoryEvent) -> Void) -> HistoryButtonView?
    let makeRepeatButtonView: (@escaping () -> Void) -> RepeatButtonView?
}

extension RootViewFactory {
    
    var productProfileViewFactory: ProductProfileViewFactory {
        
        return .init(
            makeActivateSliderView: makeActivateSliderView,
            makeHistoryButton: makeHistoryButtonView,
            makeRepeatButtonView: makeReturnButtonView
        )
    }
}

struct RepeatButtonView: View {

    let action: () -> Void
    
    var body: some View {
    
        ButtonSimpleView(viewModel: .init(
            title: "Повторить",
            style: .red,
            action: action
        ))
    }
}

struct HistoryButtonView: View {
    
    let event: (HistoryEvent) -> Void
    
    var body: some View {
        
        HStack {
            
            Button(action: {
                event(.button(.calendar))
            }) {
                
                Text("Calendar")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                
            }
            
            Button(action: {
                event(.button(.filter))
            }) {
                
                Text("Filter")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                
            }
        }
    }
}
