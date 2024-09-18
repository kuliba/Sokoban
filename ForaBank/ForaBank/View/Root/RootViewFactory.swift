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
typealias MakeHistoryButtonView = (@escaping (ProductProfileFlowEvent.ButtonEvent) -> Void, @escaping () -> Bool, @escaping () -> Bool,  @escaping () -> Void) -> HistoryButtonView?
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
    let makeHistoryButton: (@escaping (ProductProfileFlowEvent.ButtonEvent) -> Void, @escaping () -> Bool, @escaping () -> Bool, @escaping () -> Void) -> HistoryButtonView?
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
