//
//  ViewComponents.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.11.2024.
//

import Foundation
import LoadableResourceComponent
import SwiftUI

/// A namespace.
enum ViewComponents {}

//extension ViewComponents {
    
    typealias MakeProductsCategoryView = (Bool, String) -> ProductsCategoryView
    typealias MakeAnywayServicePickerFlowView = (AnywayServicePickerFlowModel) -> AnywayServicePickerFlowView<AnywayFlowView<PaymentCompleteView>>
    typealias MakeComposedSegmentedPaymentProviderPickerFlowView = (SegmentedPaymentProviderPickerFlowModel) -> ComposedSegmentedPaymentProviderPickerFlowView<AnywayFlowView<PaymentCompleteView>>
    typealias MakeContactsBanksSectionView = (ContactsBanksSectionViewModel) -> ContactsBanksSectionView
    typealias MakeContactsView = (ContactsViewModel) -> ContactsView
    typealias MakeControlPanelWrapperView = (ControlPanelViewModel) -> ControlPanelWrapperView
    typealias MakeCurrencyWalletListView = (CurrencyWalletListViewModel) -> CurrencyWalletListView
    typealias MakeCurrencyWalletSelectorView = (CurrencyWalletSelectorView.ViewModel) -> CurrencyWalletSelectorView
    typealias MakeCurrencyWalletView = (CurrencyWalletViewModel) -> CurrencyWalletView
    typealias MakeMainSectionCurrencyMetalView = (MainSectionCurrencyMetallView.ViewModel) -> MainSectionCurrencyMetallView
    typealias MakeMainSectionProductsView = (MainSectionProductsView.ViewModel) -> MainSectionProductsView
    typealias MakeOperationDetailView = (OperationDetailViewModel, @escaping MakeRepeatButtonView, @escaping MakePayment) -> OperationDetailView
    typealias MakeOptionButtonView = (OptionSelectorView.ViewModel.OptionViewModel, Bool) -> OptionSelectorView.OptionButtonView
    typealias MakeOptionSelectorView = (OptionSelectorView.ViewModel) -> OptionSelectorView
    typealias MakePayment = () -> Void
    typealias MakePaymentGroupView = (PaymentsGroupViewModel) -> PaymentGroupView
    typealias MakePaymentsMeToMeView = (PaymentsMeToMeViewModel) -> PaymentsMeToMeView
    typealias MakePaymentsOperationView = (PaymentsOperationViewModel) -> PaymentsOperationView
    typealias MakePaymentsServicesOperatorsView = (PaymentsServicesViewModel) -> PaymentsServicesOperatorsView
    typealias MakePaymentsServiceView = (PaymentsServiceViewModel) -> PaymentsServiceView
    typealias MakePaymentsSuccessView = (PaymentsSuccessViewModel) -> PaymentsSuccessView
    typealias MakePaymentsView = (PaymentsViewModel) -> PaymentsView
    typealias MakeProductCarouselView = (ProductCarouselView.ViewModel, @escaping () -> ButtonNewProduct?) -> ProductCarouselView
    typealias MakeProductSelectorView = (ProductSelectorView.ViewModel) -> ProductSelectorView
    typealias MakeProductsSwapView = (ProductsSwapView.ViewModel) -> ProductsSwapView
    typealias MakeQRFailedView = (QRFailedViewModel) -> QRFailedView
    typealias MakeQRSearchOperatorView = (QRSearchOperatorViewModel) -> QRSearchOperatorView
    typealias MakeQRView = (QRViewModel) -> QRView
    typealias MakeSbpPayView = (SbpPayViewModel) -> SbpPayView
    typealias MakeTemplatesListFlowView = (MainViewModel.TemplatesNode) -> TemplatesListFlowView< AnywayFlowView<PaymentCompleteView>>
    typealias MakeTransportPaymentsView = (LoadableResourceViewModel<MosParkingPickerData>, TransportPaymentsViewModel) -> TransportPaymentsView<MosParkingView< MosParkingStateView<Text>>>
//}
