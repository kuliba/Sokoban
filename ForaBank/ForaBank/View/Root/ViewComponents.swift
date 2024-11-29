//
//  ViewComponents.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.11.2024.
//

import Foundation
import LoadableResourceComponent
import SwiftUI

typealias MakeProductsCategoryView = (Bool, String) -> ProductsCategoryView
typealias MakeAnywayServicePickerFlowView = (AnywayServicePickerFlowModel) -> AnywayServicePickerFlowView<AnywayFlowView<PaymentCompleteView>>
typealias MakeSegmentedPaymentProviderPickerView = (SegmentedPaymentProviderPickerFlowModel) -> ComposedSegmentedPaymentProviderPickerFlowView<AnywayFlowView<PaymentCompleteView>>
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
typealias MakeProductCarouselView = (ProductCarouselView.ViewModel, @escaping () -> NewProductButton?) -> ProductCarouselView
typealias MakeProductSelectorView = (ProductSelectorView.ViewModel) -> ProductSelectorView
typealias MakeProductsSwapView = (ProductsSwapView.ViewModel) -> ProductsSwapView
typealias MakeQRFailedView = (QRFailedViewModel) -> QRFailedView
typealias MakeQRFailedWrapperView = (QRFailedViewModelWrapper) -> QRFailedViewModelWrapperView
typealias MakeQRSearchOperatorView = (QRSearchOperatorViewModel) -> QRSearchOperatorView
typealias MakeQRView = (QRScanner) -> QRScanner_View
typealias MakeSbpPayView = (SbpPayViewModel) -> SbpPayView
typealias MakeTemplatesListFlowView = (MainViewModel.TemplatesNode) -> TemplatesListFlowView< AnywayFlowView<PaymentCompleteView>>
typealias MakeTransportPaymentsView = (LoadableResourceViewModel<MosParkingPickerData>, TransportPaymentsViewModel) -> TransportPaymentsView<MosParkingView< MosParkingStateView<Text>>>
typealias MakeOrderCardView = () -> EmptyView

struct ViewComponents {
    
    let makeAnywayFlowView: MakeAnywayFlowView
    let makeAnywayServicePickerFlowView: MakeAnywayServicePickerFlowView
    let makeSegmentedPaymentProviderPickerView: MakeSegmentedPaymentProviderPickerView
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
    let makeQRFailedWrapperView: MakeQRFailedWrapperView
    let makeQRSearchOperatorView: MakeQRSearchOperatorView
    let makeQRView: MakeQRView
    let makeTemplatesListFlowView: MakeTemplatesListFlowView
    let makeTransportPaymentsView: MakeTransportPaymentsView
    let makeOrderCardView: MakeOrderCardView
}

extension ViewComponents {
    
    static let preview: Self = .init(
        makeAnywayFlowView: { _ in fatalError() },
        makeAnywayServicePickerFlowView: { _ in fatalError() },
        makeSegmentedPaymentProviderPickerView: { _ in fatalError() },
        makeContactsView: makeContactsView,
        makeControlPanelWrapperView: makeControlPanelWrapperView,
        makeCurrencyWalletView: makeCurrencyWalletView,
        makeMainSectionCurrencyMetalView: makeMainSectionCurrencyMetalView,
        makeMainSectionProductsView: makeMainSectionProductsView,
        makeOperationDetailView: { _,_,_  in fatalError() },
        makePaymentsMeToMeView: makePaymentsMeToMeView,
        makePaymentsServicesOperatorsView: makePaymentsServicesOperatorsView,
        makePaymentsSuccessView: makePaymentsSuccessView,
        makePaymentsView: makePaymentsView,
        makeQRFailedView: makeQRFailedView,
        makeQRFailedWrapperView: makeQRFailedWrapperView,
        makeQRSearchOperatorView: makeQRSearchOperatorView,
        makeQRView: makeQRView,
        makeTemplatesListFlowView: { _ in fatalError() },
        makeTransportPaymentsView: { _,_  in fatalError() }, 
        makeOrderCardView: { EmptyView() }
    )
    
    static let makeContactsView: MakeContactsView = { .init(viewModel: $0, viewFactory: .preview) }
    static let makeControlPanelWrapperView: MakeControlPanelWrapperView = { .init(viewModel: $0, config: .default, getUImage: { _ in .checkmark }, viewFactory: .init(makePaymentsView: makePaymentsView, makePaymentsSuccessView: makePaymentsSuccessView)) }
    static let makeCurrencyWalletView: MakeCurrencyWalletView = { .init(viewModel: $0, viewFactory: .init(makeCurrencySelectorView: { .init(viewModel: $0, viewFactory: .preview)})) }
    static let makeMainSectionCurrencyMetalView: MakeMainSectionCurrencyMetalView = { .init(viewModel: $0, viewFactory: .preview) }
    static let makePaymentsView: MakePaymentsView = { .init(viewModel: $0, viewFactory: .preview) }
    static let makePaymentsSuccessView: MakePaymentsSuccessView = { .init(viewModel: $0, viewFactory: .preview)}
    static let makeMainSectionProductsView: MakeMainSectionProductsView = { .init(viewModel: $0, viewFactory: .init(makeProductCarouselView: { .init(viewModel: $0, newProductButton: $1, viewFactory: .preview) })) }
    static let makePaymentsMeToMeView: MakePaymentsMeToMeView = { .init(viewModel: $0, viewFactory: .init(makeProductsSwapView: {.init(viewModel: $0, viewFactory: .preview)})) }
    static let makePaymentsServicesOperatorsView: MakePaymentsServicesOperatorsView = { .init(viewModel: $0, viewFactory: .preview) }
    static let makeQRFailedView: MakeQRFailedView = { .init(viewModel: $0, viewFactory: .init(makeQRSearchOperatorView: { .init(viewModel: $0, viewFactory: .init(makePaymentsView: makePaymentsView))})) }
    static let makeQRFailedWrapperView: MakeQRFailedWrapperView = {
        .init(viewModel: $0, viewFactory: .init(makeQRSearchOperatorView: { .init(viewModel: $0, viewFactory: .init(makePaymentsView: makePaymentsView))}), paymentsViewFactory: .preview)
    }
    static let makeQRSearchOperatorView: MakeQRSearchOperatorView = { .init(viewModel: $0, viewFactory: .init(makePaymentsView: makePaymentsView)) }
    static let makeQRView: MakeQRView = { .init(qrScanner: $0, viewFactory: .init(makeQRFailedView: { .init(viewModel: $0, viewFactory: .init(makeQRSearchOperatorView: { .init(viewModel: $0, viewFactory: .init(makePaymentsView: makePaymentsView))}))})) }
}
