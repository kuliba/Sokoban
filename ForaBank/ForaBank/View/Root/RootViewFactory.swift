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
typealias MakeHistoryButtonView = (@escaping (HistoryEvent) -> Void) -> HistoryButtonView?
typealias MakeRepeatButtonView = (@escaping () -> Void) -> RepeatButtonView?

struct RootViewFactory {
    
    let makePaymentsTransfersView: MakePaymentsTransfersView
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeUserAccountView: MakeUserAccountView
    let makeIconView: MakeIconView
    let makeActivateSliderView: MakeActivateSliderView
    let makeUpdateInfoView: MakeUpdateInfoView
    let makeAnywayPaymentFactory: MakeAnywayPaymentFactory
    let makePaymentCompleteView: MakePaymentCompleteView
    let makeHistoryButtonView: MakeHistoryButtonView
    let makeReturnButtonView: MakeRepeatButtonView
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
    
    let makeActivateSliderView: MakeActivateSliderView
    let makeHistoryButton: (@escaping (HistoryEvent) -> Void) -> HistoryButtonView?
    let makeRepeatButtonView: (@escaping () -> Void) -> RepeatButtonView?
}

extension RootViewFactory {
    
    var productProfileViewFactory: ProductProfileViewFactory {
 
        .init(
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
