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
import LoadableResourceComponent

typealias MakeActivateSliderView = (ProductData.ID, ActivateSliderViewModel, SliderConfig) -> ActivateSliderStateWrapperView
typealias MakeAnywayPaymentFactory = (@escaping (AnywayPaymentEvent) -> Void) -> AnywayPaymentFactory<IconDomain.IconView>
typealias MakeHistoryButtonView = (@escaping (ProductProfileFlowEvent.ButtonEvent) -> Void, @escaping () -> Bool, @escaping () -> Bool,  @escaping () -> Void) -> HistoryButtonView?
typealias MakeRepeatButtonView = (@escaping () -> Void) -> RepeatButtonView?
typealias MakeIconView = IconDomain.MakeIconView
typealias MakePaymentCompleteView = (Completed, @escaping () -> Void) -> PaymentCompleteView
typealias MakeAnywayFlowView = (AnywayFlowModel) -> AnywayFlowView<PaymentCompleteView>
typealias MakePaymentsTransfersView = (PaymentsTransfersViewModel) -> PaymentsTransfersView
typealias MakeSberQRConfirmPaymentView = (SberQRConfirmPaymentViewModel) -> SberQRConfirmPaymentWrapperView
typealias MakeUserAccountView = (UserAccountViewModel, UserAccountConfig) -> UserAccountView

typealias MakeMarketShowcaseView = (MarketShowcaseDomain.Binder, @escaping MakeOrderCard, @escaping MakePaymentByType) -> MarketShowcaseWrapperView?
typealias MakeOrderCard = () -> Void
typealias MakePaymentByType = (String) -> Void

typealias MakeCategoryView = (Bool, String) -> CategoryView

typealias MakeAnywayServicePickerFlowView = (AnywayServicePickerFlowModel) -> AnywayServicePickerFlowView<AnywayFlowView<PaymentCompleteView>>
typealias MakeComposedSegmentedPaymentProviderPickerFlowView = (SegmentedPaymentProviderPickerFlowModel) -> ComposedSegmentedPaymentProviderPickerFlowView<AnywayFlowView<PaymentCompleteView>>
typealias MakeContactsView = (ContactsViewModel) -> ContactsView
typealias MakeControlPanelWrapperView = (ControlPanelViewModel) -> ControlPanelWrapperView
typealias MakeCurrencyWalletView = (CurrencyWalletViewModel) -> CurrencyWalletView
typealias MakeMainSectionCurrencyMetalView = (MainSectionCurrencyMetallView.ViewModel) -> MainSectionCurrencyMetallView
typealias MakeMainSectionProductsView = (MainSectionProductsView.ViewModel) -> MainSectionProductsView
typealias MakePayment = () -> Void
typealias MakeOperationDetailView = (OperationDetailViewModel, @escaping MakeRepeatButtonView, @escaping MakePayment) -> OperationDetailView
typealias MakeOptionSelectorView = (OptionSelectorView.ViewModel) -> OptionSelectorView
typealias MakePaymentsMeToMeView = (PaymentsMeToMeViewModel) -> PaymentsMeToMeView
typealias MakePaymentsServicesOperatorsView = (PaymentsServicesViewModel) -> PaymentsServicesOperatorsView
typealias MakePaymentsSuccessView = (PaymentsSuccessViewModel) -> PaymentsSuccessView
typealias MakePaymentsView = (PaymentsViewModel) -> PaymentsView
typealias MakeQRFailedView = (QRFailedViewModel) -> QRFailedView
typealias MakeQRSearchOperatorView = (QRSearchOperatorViewModel) -> QRSearchOperatorView
typealias MakeQRView = (QRViewModel) -> QRView
typealias MakeTemplatesListFlowView = (MainViewModel.TemplatesNode) -> TemplatesListFlowView< AnywayFlowView<PaymentCompleteView>>
typealias MakeTransportPaymentsView = (LoadableResourceViewModel<MosParkingPickerData>, TransportPaymentsViewModel) -> TransportPaymentsView<MosParkingView< MosParkingStateView<Text>>>
typealias MakeProductsSwapView = (ProductsSwapView.ViewModel) -> ProductsSwapView
typealias MakeProductSelectorView = (ProductSelectorView.ViewModel) -> ProductSelectorView
typealias MakePaymentGroupView = (PaymentsGroupViewModel) -> PaymentGroupView
typealias MakePaymentsOperationView = (PaymentsOperationViewModel) -> PaymentsOperationView
typealias MakePaymentsServiceView = (PaymentsServiceViewModel) -> PaymentsServiceView
typealias MakeSbpPayView = (SbpPayViewModel) -> SbpPayView
typealias MakeContactsBanksSectionView = (ContactsBanksSectionViewModel) -> ContactsBanksSectionView
typealias MakeCurrencyWalletSelectorView = (CurrencyWalletSelectorView.ViewModel) -> CurrencyWalletSelectorView
typealias MakeProductCarouselView = (ProductCarouselView.ViewModel, @escaping () -> ButtonNewProduct?) -> ProductCarouselView
typealias MakeCurrencyWalletListView = (CurrencyWalletListViewModel) -> CurrencyWalletListView
typealias MakeOptionButtonView = (OptionSelectorView.ViewModel.OptionViewModel, Bool) -> OptionSelectorView.OptionButtonView

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
    let makeAnywayFlowView: MakeAnywayFlowView
    let makeAnywayServicePickerFlowView: MakeAnywayServicePickerFlowView
    let makeComposedSegmentedPaymentProviderPickerFlowView: MakeComposedSegmentedPaymentProviderPickerFlowView
    let makeContactsView: MakeContactsView
    let makeControlPanelWrapperView: MakeControlPanelWrapperView
    let makeCurrencyWalletView: MakeCurrencyWalletView
    let makeMainSectionCurrencyMetalView: MakeMainSectionCurrencyMetalView
    let makeMainSectionProductsView: MakeMainSectionProductsView
    let makeOperationDetailView: MakeOperationDetailView
    let makePaymentsMeToMeView: MakePaymentsMeToMeView
    let makePaymentsServicesOperatorsView: MakePaymentsServicesOperatorsView
    let makePaymentsSuccessView: MakePaymentsSuccessView
    let makePaymentsView: MakePaymentsView
    let makeQRFailedView: MakeQRFailedView
    let makeQRSearchOperatorView: MakeQRSearchOperatorView
    let makeQRView: MakeQRView
    let makeTemplatesListFlowView: MakeTemplatesListFlowView
    let makeTransportPaymentsView: MakeTransportPaymentsView
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
            makeUserAccountView: makeUserAccountView, 
            makeAnywayFlowView: makeAnywayFlowView,
            makeAnywayServicePickerFlowView: makeAnywayServicePickerFlowView,
            makeComposedSegmentedPaymentProviderPickerFlowView: makeComposedSegmentedPaymentProviderPickerFlowView,
            makeContactsView: makeContactsView, 
            makeControlPanelWrapperView: makeControlPanelWrapperView,
            makeCurrencyWalletView: makeCurrencyWalletView,
            makeMainSectionCurrencyMetalView: makeMainSectionCurrencyMetalView,
            makeMainSectionProductsView: makeMainSectionProductsView,
            makeOperationDetailView: makeOperationDetailView,
            makePaymentsMeToMeView: makePaymentsMeToMeView,
            makePaymentsServicesOperatorsView: makePaymentsServicesOperatorsView,
            makePaymentsSuccessView: makePaymentsSuccessView,
            makePaymentsView: makePaymentsView,
            makeQRFailedView: makeQRFailedView,
            makeQRSearchOperatorView: makeQRSearchOperatorView,
            makeQRView: makeQRView,
            makeTemplatesListFlowView: makeTemplatesListFlowView,
            makeTransportPaymentsView: makeTransportPaymentsView
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
