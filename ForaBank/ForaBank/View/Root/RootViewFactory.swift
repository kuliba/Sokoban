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
typealias MakeHistoryButtonView = (@escaping (ProductProfileFlowEvent.ButtonEvent) -> Void, @escaping () -> Bool, @escaping () -> Bool,  @escaping () -> Void) -> HistoryButtonView?
typealias MakeRepeatButtonView = (@escaping () -> Void) -> RepeatButtonView?
typealias MakeIconView = IconDomain.MakeIconView
typealias MakePaymentCompleteView = (Completed, @escaping () -> Void) -> PaymentCompleteView
typealias MakePaymentsTransfersView = (PaymentsTransfersViewModel) -> PaymentsTransfersView
typealias MakeSberQRConfirmPaymentView = (SberQRConfirmPaymentViewModel) -> SberQRConfirmPaymentWrapperView
typealias MakeUserAccountView = (UserAccountViewModel, UserAccountConfig) -> UserAccountView

typealias MakeMarketShowcaseView = (MarketShowcaseDomain.Binder, @escaping () -> Void) -> MarketShowcaseWrapperView?

typealias MakeNavigationOperationView = (@escaping() -> Void) -> any View

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
    let makeMarketShowcaseView: MakeMarketShowcaseView
    let makeNavigationOperationView: MakeNavigationOperationView
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
    let makeHistoryButton: (@escaping (ProductProfileFlowEvent.ButtonEvent) -> Void, @escaping () -> Bool, @escaping () -> Bool, @escaping () -> Void) -> HistoryButtonView?
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
    
    let event: (ProductProfileFlowEvent.ButtonEvent) -> Void
    let isFiltered: () -> Bool
    let isDateFiltered: () -> Bool
    let clearOptions: () -> Void
    
    var body: some View {
        
        HStack {
            
            Button { event(.calendar) } label: {
                
                ZStack {
                    
                    Color.buttonSecondary
                        .frame(width: 32, height: 32, alignment: .center)
                        .cornerRadius(90)
                    
                    Image.ic16Calendar
                    
                    if isDateFiltered() {
                        
                        ZStack{
                            
                            Circle()
                                .foregroundColor(.iconWhite)
                                .frame(width: 15, height: 15)
                            
                            
                            Circle()
                                .foregroundColor(.mainColorsRed)
                                .frame(width: 7, height: 7, alignment: .center)
                        }
                        .offset(x: 16, y: -12)
                    }
                }
            }
            
            Button { event(.filter) } label: {
                
                ZStack {
                    
                    Color.buttonSecondary
                        .frame(width: 32, height: 32, alignment: .center)
                        .cornerRadius(90)
                    
                    Image.ic16Filter
                    
                    if isFiltered() {
                        
                        ZStack{
                            
                            Circle()
                                .foregroundColor(.iconWhite)
                                .frame(width: 15, height: 15)
                            
                            
                            Circle()
                                .foregroundColor(.mainColorsRed)
                                .frame(width: 7, height: 7, alignment: .center)
                        }
                        .offset(x: 16, y: -12)
                    }
                }
            }
            
            if isFiltered() || isDateFiltered() {
                
                Button(action: clearOptions) {
                    
                    ZStack {
                        
                        Color.buttonSecondary
                            .frame(width: 32, height: 32, alignment: .center)
                            .cornerRadius(90)
                        
                        Image.ic24Close
                    }
                }
                
            }
        }
    }
}
