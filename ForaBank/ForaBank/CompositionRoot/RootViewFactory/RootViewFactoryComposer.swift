//
//  RootViewFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import ActivateSlider
import AnywayPaymentDomain
import Combine
import GenericRemoteService
import InfoComponent
import LandingUIComponent
import LoadableResourceComponent
import MarketShowcase
import PaymentComponents
import PayHubUI
import PDFKit
import SberQR
import SwiftUI
import UIPrimitives

final class RootViewFactoryComposer {
    
    private let model: Model
    private let httpClient: HTTPClient
    private let historyFeatureFlag: HistoryFilterFlag
    private let savingsAccountFlag: SavingsAccountFlag
    private let schedulers: Schedulers
    
    init(
        model: Model,
        httpClient: HTTPClient,
        historyFeatureFlag: HistoryFilterFlag,
        savingsAccountFlag: SavingsAccountFlag,
        schedulers: Schedulers
    ) {
        self.model = model
        self.httpClient = httpClient
        self.historyFeatureFlag = historyFeatureFlag
        self.savingsAccountFlag = savingsAccountFlag
        self.schedulers = schedulers
    }
}

extension RootViewFactoryComposer {
    
    func compose() -> Factory {
        
        let imageCache = model.imageCache()
        let generalImageCache = model.generalImageCache()
        
        return .init(
            isCorporate: { self.model.onlyCorporateCards },
            makeActivateSliderView: ActivateSliderStateWrapperView.init,
            makeAnywayPaymentFactory: makeAnywayPaymentFactory,
            makeHistoryButtonView: { event, isFiltered, isDateFiltered, clearAction in
                
                self.makeHistoryButtonView(
                    self.historyFeatureFlag,
                    isFiltered: isFiltered,
                    isDateFiltered: isDateFiltered,
                    clearAction: clearAction,
                    event: event
                )
            },
            makeIconView: imageCache.makeIconView(for:),
            makeGeneralIconView: generalImageCache.makeIconView(for:),
            makePaymentCompleteView: makePaymentCompleteView,
            makePaymentsTransfersView: makePaymentsTransfersView,
            makeReturnButtonView: { action in
                
                self.makeReturnButtonView(self.historyFeatureFlag, action: action)
            },
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeInfoViews: .default,
            makeUserAccountView: makeUserAccountView,
            makeMarketShowcaseView: makeMarketShowcaseView,
            components: makeViewComponents(),
            makeUpdatingUserAccountButtonLabel: makeUpdatingUserAccountButtonLabel
        )
    }
    
    func makeViewComponents() -> ViewComponents {
        .init(
            makeAnywayFlowView: makeAnywayFlowView,
            makeAnywayServicePickerFlowView: makeAnywayServicePickerFlowView,
            makeSegmentedPaymentProviderPickerView: makeComposedSegmentedPaymentProviderPickerFlowView,
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
            makeQRFailedWrapperView: makeQRFailedWrapperView,
            makeQRSearchOperatorView: makeQRSearchOperatorView,
            makeQRView: makeQRView,
            makeTemplatesListFlowView: makeTemplatesListFlowView,
            makeTransportPaymentsView: makeTransportPaymentsView,
            makeOrderCardView: makeOrderCardView
        )
    }
}

extension RootViewFactoryComposer {
    
    typealias Factory = RootViewFactory
}

private extension RootViewFactoryComposer {
    
    func makePaymentsTransfersView(
        viewModel: PaymentsTransfersViewModel
    ) -> PaymentsTransfersView {
        
        let imageCache = model.imageCache()
        let generalImageCache = model.generalImageCache()
        
        let getUImage = { self.model.images.value[$0]?.uiImage }
        
        return .init(
            viewModel: viewModel,
            viewFactory: .init(
                makeAnywayPaymentFactory: makeAnywayPaymentFactory,
                makeIconView: imageCache.makeIconView(for:),
                makeGeneralIconView: generalImageCache.makeIconView(for:),
                makePaymentCompleteView: makePaymentCompleteView,
                makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
                makeInfoViews: .default,
                makeUserAccountView: makeUserAccountView,
                components: makeViewComponents()
            ),
            productProfileViewFactory: .init(
                makeActivateSliderView: ActivateSliderStateWrapperView.init,
                makeHistoryButton: {
                    self.makeHistoryButtonView(
                        self.historyFeatureFlag,
                        isFiltered: $1,
                        isDateFiltered: $2,
                        clearAction: $3,
                        event: $0
                    )
                },
                makeRepeatButtonView: { action in self.makeReturnButtonView(self.historyFeatureFlag, action: action) }
            ),
            getUImage: getUImage
        )
    }
    
    func makeSberQRConfirmPaymentView(
        viewModel: SberQRConfirmPaymentViewModel
    ) -> SberQRConfirmPaymentWrapperView {
        
        let imageCache = model.imageCache()
        
        return .init(
            viewModel: viewModel,
            map: { info in
                
                return  .init(
                    id: info.infoID,
                    value: info.value,
                    title: info.title,
                    image: imageCache.imagePublisher(for: info.icon),
                    style: .expanded
                )
            },
            config: .iFora
        )
    }
    
    func makeOptionSelectorViewFactory() -> OptionSelectorViewFactory {
        .init(makeOptionButtonView: makeOptionButtonView)
    }
    
    func makeOptionButtonView(
        viewModel: OptionSelectorView.ViewModel.OptionViewModel,
        isSelected: Bool
    ) -> OptionSelectorView.OptionButtonView {
        .init(viewModel: viewModel, isSelected: isSelected, viewFactory: makeOptionButtonViewFactory())
    }
    
    func makeOptionButtonViewFactory() -> OptionSelectorView.OptionButtonViewFactory {
        .init(makeProductsCategoryView: makeCategoryView(savingsAccountFlag: savingsAccountFlag.isActive))
    }
    
    func makeUserAccountView(
        viewModel: UserAccountViewModel
    ) -> UserAccountView {
        
        return .init(
            viewModel: viewModel,
            config: .iFora,
            viewFactory: makeUserAccountViewFactory()
        )
    }
    
    func makeUserAccountViewFactory() -> UserAccountViewFactory {
        .init(
            makePaymentsSuccessView: makePaymentsSuccessView,
            makeSbpPayView: makeSbpPayView)
    }
    
    func makeSbpPayView(
        viewModel: SbpPayViewModel
    ) -> SbpPayView {
        .init(viewModel: viewModel, viewFactory: makeSbpPayViewFactory())
    }
    
    func makeSbpPayViewFactory() -> SbpPayViewFactory {
        .init(makeProductSelectorView: makeProductSelectorView)
    }
    
    func makeAnywayPaymentFactory(
        event: @escaping (AnywayPaymentEvent) -> ()
    ) -> AnywayPaymentFactory<IconView> {
        let composer = AnywayPaymentFactoryComposer(
            currencyOfProduct: currencyOfProduct,
            makeIconView: makeIconView
        )
        
        return composer.compose(event: event)
    }
    
    func makeCategoryView(
        savingsAccountFlag: Bool
    ) -> MakeProductsCategoryView  {
        return {
            .init(newImplementation: savingsAccountFlag, isSelected: $0, title: $1)
        }
    }
    
    func makeMainSectionProductsView(
        viewModel: MainSectionProductsView.ViewModel
    ) -> MainSectionProductsView {
        .init(
            viewModel: viewModel,
            viewFactory: .init(makeProductCarouselView: makeProductCarouselView)
        )
    }
    
    func makeOperationDetailView(
        viewModel: OperationDetailViewModel,
        makeRepeatButtonView: @escaping MakeRepeatButtonView,
        payment: @escaping () -> Void
    ) -> OperationDetailView {
        .init(
            viewModel: viewModel,
            makeRepeatButtonView: makeRepeatButtonView,
            payment: payment,
            viewFactory: makeOperationDetailViewFactory())
    }
    
    func makeOperationDetailViewFactory() -> OperationDetailViewFactory {
        .init(makePaymentsView: makePaymentsView)
    }
    
    func makeProductCarouselView(
        viewModel: ProductCarouselView.ViewModel,
        newProductButton: @escaping () -> NewProductButton?
    ) -> ProductCarouselView {
        .init(
            viewModel: viewModel,
            newProductButton: newProductButton,
            viewFactory: makeProductCarouselViewFactory()
        )
    }
    
    func makeProductCarouselViewFactory() -> ProductCarouselViewFactory {
        .init(makeOptionSelectorView: makeOptionSelectorView)
    }
    
    func makeMainSectionCurrencyMetalView(
        viewModel: MainSectionCurrencyMetallView.ViewModel
    ) -> MainSectionCurrencyMetallView {
        .init(
            viewModel: viewModel,
            viewFactory: makeMainSectionCurrencyMetalViewFactory()
        )
    }
    
    func makeMainSectionCurrencyMetalViewFactory() -> MainSectionCurrencyMetalViewFactory {
        .init(makeOptionSelectorView: makeOptionSelectorView)
    }
    
    func makeTemplatesListFlowView(
        node: MainViewModel.TemplatesNode
    ) -> TemplatesListFlowView<AnywayFlowView<PaymentCompleteView>> {
        .init(
            model: node.model,
            makeAnywayFlowView: makeAnywayFlowView,
            makeIconView: { self.makeIconView($0.map { .svg($0) }) },
            viewFactory: makeTemplatesListFlowViewFactory()
        )
    }
    
    func makeTemplatesListFlowViewFactory() -> TemplatesListFlowViewFactory {
        .init(
            makePaymentsView: makePaymentsView,
            makeTemplatesListView: makeTemplatesListView)
    }
    
    func makeTemplatesListView(
        viewModel: TemplatesListViewModel
    ) -> TemplatesListView {
        .init(viewModel: viewModel, viewFactory: makeTemplatesListViewFactory())
    }
    
    func makeTemplatesListViewFactory() -> TemplatesListViewFactory {
        .init(
            makeOptionSelectorView: makeOptionSelectorView,
            makePaymentsMeToMeView: makePaymentsMeToMeView,
            makePaymentsSuccessView: makePaymentsSuccessView,
            makePaymentsView: makePaymentsView)
    }
    
    func makeOptionSelectorView(
        viewModel: OptionSelectorView.ViewModel
    ) -> OptionSelectorView {
        .init(viewModel: viewModel, viewFactory: makeOptionSelectorViewFactory())
    }
    
    func makeTransportPaymentsView(
        transportPaymentsViewModel: TransportPaymentsViewModel
    ) -> TransportPaymentsView<MosParkingView< MosParkingStateView<Text>>> {
        
        return .init(
            viewModel: transportPaymentsViewModel,
            mosParkingView: {
                MosParkingView(
                    viewModel: .init(
                        operation: self.model.getMosParkingPickerData
                    ),
                    stateView: { state in
                        
                        MosParkingStateView(
                            state: state,
                            mapper: DefaultMosParkingPickerDataMapper(select: transportPaymentsViewModel.selectMosParkingID(id:)),
                            errorView: {
                                Text($0.localizedDescription).foregroundColor(.red)
                            }
                        )
                    }
                )
                // TODO: fix navigation bar
                // .navigationBar(
                //     with: .init(
                //         title: "Московский паркинг",
                //         rightItems: [
                //             NavigationBarView.ViewModel.IconItemViewModel(
                //                 icon: .init("ic40Transport"),
                //                 style: .large
                //             )
                //         ]
                //     )
                // )
            },
            viewFactory: makeTransportPaymentsViewFactory()
        )
    }
    
    func makeOrderCardView() -> EmptyView {
        EmptyView()
    }
    
    func makeTransportPaymentsViewFactory() -> TransportPaymentsViewFactory {
        .init(makePaymentsView: makePaymentsView)
    }
    
    func makeCurrencyWalletView(
        viewModel: CurrencyWalletViewModel
    ) -> CurrencyWalletView {
        .init(
            viewModel: viewModel,
            viewFactory: .init(makeCurrencySelectorView: makeCurrencySelectorView)
        )
    }
    
    func makeCurrencySelectorView(
        viewModel: CurrencySelectorView.ViewModel
    ) -> CurrencySelectorView {
        .init(viewModel: viewModel, viewFactory: makeCurrencySelectorViewFactory()
        )
    }
    
    func makeCurrencySelectorViewFactory() -> CurrencySelectorViewFactory {
        .init(makeCurrencyWalletSelectorView: makeCurrencyWalletSelectorView)
    }
    
    func makeCurrencyWalletSelectorView(
        viewModel: CurrencyWalletSelectorViewModel
    ) -> CurrencyWalletSelectorView {
        .init(viewModel: viewModel, viewFactory: makeCurrencyWalletSelectorViewFactory())
    }
    
    func makeCurrencyWalletSelectorViewFactory() -> CurrencyWalletSelectorViewFactory {
        .init(makeCurrencyWalletListView: makeCurrencyWalletListView)
    }
    
    func makeCurrencyWalletListView(
        viewModel: CurrencyWalletListViewModel
    ) -> CurrencyWalletListView {
        .init(viewModel: viewModel, viewFactory: makeCurrencyWalletListViewFactory())
    }
    
    func makeCurrencyWalletListViewFactory() -> CurrencyWalletListViewFactory {
        .init(makeOptionSelectorView: makeOptionSelectorView)
    }
    
    func makeQRFailedView(
        viewModel: QRFailedViewModel
    ) -> QRFailedView {
        .init(viewModel: viewModel, viewFactory: makeQRFailedViewFactory())
    }
    
    func makeQRFailedWrapperView(
        viewModel: QRFailedViewModelWrapper
    ) -> QRFailedViewModelWrapperView {
        
        return .init(
            viewModel: viewModel,
            viewFactory: makeQRFailedViewFactory(),
            paymentsViewFactory: makePaymentsViewFactory()
        )
    }
    
    func makeQRFailedViewFactory() -> QRFailedViewFactory {
        .init(makeQRSearchOperatorView: makeQRSearchOperatorView)
    }
    
    func makeQRSearchOperatorView(
        viewModel: QRSearchOperatorViewModel
    ) -> QRSearchOperatorView {
        .init(
            viewModel: viewModel,
            viewFactory: makeQRSearchOperatorViewFactory()
        )
    }
    
    func makeQRSearchOperatorViewFactory() -> QRSearchOperatorViewFactory {
        .init(makePaymentsView: makePaymentsView)
    }
    
    func makePaymentsMeToMeView(
        viewModel: PaymentsMeToMeViewModel
    ) -> PaymentsMeToMeView {
        .init(
            viewModel: viewModel,
            viewFactory: makePaymentsMeToMeViewFactory()
        )
    }
    
    func makePaymentsMeToMeViewFactory() -> PaymentsMeToMeViewFactory {
        .init(makeProductsSwapView: makeProductsSwapView)
    }
    
    func makeProductsSwapView(
        viewModel: ProductsSwapView.ViewModel
    ) -> ProductsSwapView {
        .init(
            viewModel: viewModel,
            viewFactory: makeProductsSwapViewFactory()
        )
    }
    
    func makeProductsSwapViewFactory() -> ProductsSwapViewFactory {
        .init(makeProductSelectorView: makeProductSelectorView)
    }
    
    func makePaymentsView(
        viewModel: PaymentsViewModel
    ) -> PaymentsView {
        .init(
            viewModel: viewModel,
            viewFactory: makePaymentsViewFactory()
        )
    }
    
    func makePaymentsViewFactory() -> PaymentsViewFactory {
        .init(
            makePaymentsOperationView: makePaymentsOperationView,
            makePaymentsServiceView: makePaymentsServiceView,
            makePaymentsSuccessView: makePaymentsSuccessView)
    }
    
    func makePaymentsServiceView(
        viewModel: PaymentsServiceViewModel
    ) -> PaymentsServiceView {
        .init(viewModel: viewModel, viewFactory: makePaymentsServiceViewFactory())
    }
    
    func makePaymentsServiceViewFactory() -> PaymentsServiceViewFactory {
        .init(makePaymentsOperationView: makePaymentsOperationView)
    }
    
    func makePaymentsOperationView(
        viewModel: PaymentsOperationViewModel
    ) -> PaymentsOperationView {
        .init(
            viewModel: viewModel,
            viewFactory: makePaymentsOperationViewFactory())
    }
    
    func makePaymentsOperationViewFactory() -> PaymentsOperationViewFactory {
        .init(
            makeContactsView: makeContactsView,
            makePaymentsSuccessView: makePaymentsSuccessView,
            makeProductSelectorView: makeProductSelectorView)
    }
    
    func makeProductSelectorView(
        viewModel: ProductSelectorView.ViewModel
    ) -> ProductSelectorView {
        .init(viewModel: viewModel, viewFactory: makeProductSelectorViewFactory())
    }
    
    func makeProductSelectorViewFactory() -> ProductSelectorViewFactory {
        .init(makeProductCarouselView: makeProductCarouselView)
    }
    
    func makePaymentsServicesOperatorsView(
        viewModel: PaymentsServicesViewModel
    ) -> PaymentsServicesOperatorsView {
        .init(
            viewModel: viewModel,
            viewFactory: makePaymentsServicesOperatorsViewFactory()
        )
    }
    
    func makePaymentsServicesOperatorsViewFactory() -> PaymentsServicesOperatorsViewFactory {
        .init(makePaymentsView: makePaymentsView)
    }
    
    func makeContactsView(
        viewModel: ContactsViewModel
    ) -> ContactsView {
        .init(
            viewModel: viewModel,
            viewFactory: makeContactsViewFactory()
        )
    }
    
    func makeContactsViewFactory() -> ContactsViewFactory {
        .init(makeContactsBanksSectionView: makeContactsBanksSectionView)
    }
    
    func makeContactsBanksSectionView(
        viewModel: ContactsBanksSectionViewModel
    ) -> ContactsBanksSectionView {
        .init(viewModel: viewModel, viewFactory: makeContactsBanksSectionViewFactory())
    }
    
    func makeContactsBanksSectionViewFactory() -> ContactsBanksSectionViewFactory {
        .init(makeOptionSelectorView: makeOptionSelectorView)
    }
    
    func makeControlPanelWrapperView(
        viewModel: ControlPanelViewModel
    ) -> ControlPanelWrapperView {
        .init(
            viewModel: viewModel,
            config: .default,
            getUImage: { self.model.images.value[$0]?.uiImage },
            viewFactory: makeControlPanelWrapperViewFactory())
    }
    
    func makeControlPanelWrapperViewFactory() -> ControlPanelWrapperViewFactory {
        .init(
            makePaymentsView: makePaymentsView,
            makePaymentsSuccessView: makePaymentsSuccessView)
    }
    
    func makeQRView(
        viewModel: QRScanner
    ) -> QRScanner_View {
        
        return .init(
            qrScanner: viewModel,
            viewFactory: .init(makeQRFailedView: makeQRFailedView)
        )
    }
    
    func makePaymentsSuccessView(
        viewModel: PaymentsSuccessViewModel
    ) -> PaymentsSuccessView {
        .init(
            viewModel: viewModel,
            viewFactory: makePaymentsSuccessViewFactory()
        )
    }
    
    func makePaymentsSuccessViewFactory() -> PaymentsSuccessViewFactory {
        .init(
            makePaymentsSuccessView: makePaymentsSuccessView,
            makePaymentsView: makePaymentsView,
            makeProductSelectorView: makeProductSelectorView)
    }
    
    func makeComposedSegmentedPaymentProviderPickerFlowView(
        flowModel: SegmentedPaymentProviderPickerFlowModel
    ) -> ComposedSegmentedPaymentProviderPickerFlowView<AnywayFlowView<PaymentCompleteView>> {
        .init(
            flowModel: flowModel,
            iconView: model.imageCache().makeIconView(for:),
            viewFactory: makeComposedSegmentedPaymentProviderPickerFlowViewFactory()
        )
    }
    
    func makeComposedSegmentedPaymentProviderPickerFlowViewFactory() -> ComposedSegmentedPaymentProviderPickerFlowViewFactory {
        .init(
            makePaymentsView: makePaymentsView,
            makeAnywayServicePickerFlowView: makeAnywayServicePickerFlowView)
    }
    
    func makeAnywayServicePickerFlowView(
        flowModel: AnywayServicePickerFlowModel
    ) -> AnywayServicePickerFlowView<AnywayFlowView<PaymentCompleteView>> {
        .init(
            flowModel: flowModel,
            factory: .init(
                makeAnywayFlowView: makeAnywayFlowView,
                makeIconView: model.imageCache().makeIconView(for:),
                makePaymentsView: makePaymentsView
            )
        )
    }
    
    @ViewBuilder
    func makeAnywayFlowView(
        flowModel: AnywayFlowModel
    ) -> AnywayFlowView<PaymentCompleteView> {
        
        let anywayPaymentFactory = makeAnywayPaymentFactory {
            
            flowModel.state.content.event(.payment($0))
        }
        
        AnywayFlowView(
            flowModel: flowModel,
            factory: .init(
                makeElementView: anywayPaymentFactory.makeElementView,
                makeFooterView: anywayPaymentFactory.makeFooterView
            ),
            makePaymentCompleteView: {
                
                self.makePaymentCompleteView(
                    result: .init(
                        formattedAmount: $0.formattedAmount,
                        merchantIcon: $0.merchantIcon,
                        result: $0.result.mapError {
                            
                            return .init(hasExpired: $0.hasExpired)
                        }
                    ),
                    goToMain: { flowModel.event(.goTo(.main)) })
            }
        )
    }
    
    
    private func currencyOfProduct(
        product: ProductSelect.Product
    ) -> String {
        
        model.currencyOf(product: product) ?? ""
    }
    
    typealias IconView = UIPrimitives.AsyncImage
    
    private func makeIconView(
        _  icon: AnywayElement.UIComponent.Icon?
    ) -> IconView {
        
        switch icon {
        case .none:
            return makeIconView("placeholder")
            
        case let .md5Hash(md5Hash):
            return makeIconView(md5Hash)
            
        case let .svg(svg):
            return .init(
                image: .init(svg: svg) ?? .init("placeholder"),
                publisher: Empty().eraseToAnyPublisher()
            )
            
        case let .withFallback(md5Hash: md5Hash, svg: _):
            return makeIconView(md5Hash)
        }
    }
    
    private func makeIconView(
        _ icon: String
    ) -> IconView {
        
        return model.imageCache().makeIconView(for: .md5Hash(.init(icon)))
    }
    
    func makePaymentCompleteView(
        result: Completed,
        goToMain: @escaping () -> Void
    ) -> PaymentCompleteView {
        
        return PaymentCompleteView(
            state: map(result),
            goToMain: goToMain,
            repeat: {},
            factory: .init(
                makeDetailButton: TransactionDetailButton.init,
                makeDocumentButton: makeDocumentButton,
                makeTemplateButton: makeTemplateButtonView(with: result)
            ),
            makeIconView: {
                
                self.makeIconView($0.map { .md5Hash(.init($0)) })
            },
            config: .iFora
        )
    }
    
    func makeReturnButtonView(
        _ historyFeatureFlag: HistoryFilterFlag,
        action: @escaping () -> Void
    ) -> RepeatButtonView? {
        
        return RepeatButtonView(action: action)
    }
    
    func makeHistoryButtonView(
        _ historyFeatureFlag: HistoryFilterFlag,
        isFiltered: @escaping () -> Bool,
        isDateFiltered: @escaping () -> Bool,
        clearAction: @escaping () -> Void,
        event: @escaping (ProductProfileFlowEvent.ButtonEvent) -> Void
    ) -> HistoryButtonView? {
        
        return HistoryButtonView(
            event: event,
            isFiltered: isFiltered,
            isDateFiltered: isDateFiltered,
            clearOptions: clearAction
        )
    }
    
    typealias Completed = AnywayCompleted
    
    private func map(
        _ completed: Completed
    ) -> PaymentCompleteView.State {
        
        return .init(
            formattedAmount: completed.formattedAmount,
            merchantIcon: completed.merchantIcon,
            result: completed.result
                .map {
                    
                    return .init(
                        detailID: $0.detailID,
                        details: model.makeTransactionDetailButtonDetail(with: $0.info),
                        status: $0.status
                    )
                }
                .mapError {
                    
                    return .init(hasExpired: $0.hasExpired)
                }
        )
    }
    
    private func makeDocumentButton(
        documentID: DocumentID
    ) -> TransactionDocumentButton {
        
        return .init(getDocument: getDocument(forID: documentID))
    }
    
    private func getDocument(
        forID documentID: DocumentID
    ) -> TransactionDocumentButton.GetDocument {
        
        let getDetailService = RemoteService(
            createRequest: RequestFactory.createGetPrintFormRequest(printFormType: .service),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapGetPrintFormResponse
        )
        
        return { completion in
            
            getDetailService.fetch(documentID) { result in
                
                completion(try? result.map(PDFDocument.init(data:)).get())
                _ = getDetailService
            }
        }
    }
    
    private func makeTemplateButtonView(
        with completed: Completed
    ) -> () -> TemplateButtonStateWrapperView? {
        
        return {
            
            guard let report = try? completed.result.get(),
                  let operationDetail = report.info.operationDetail
            else { return nil }
            
            let viewModel = TemplateButtonStateWrapperView.ViewModel(
                model: self.model,
                operation: nil,
                operationDetail: operationDetail
            )
            
            return .init(viewModel: viewModel)
        }
    }
    
    func makeLandingView(
        _ contentEvent: @escaping (MarketShowcaseDomain.ContentEvent) -> Void,
        _ flowEvent: @escaping (MarketShowcaseDomain.FlowEvent) -> Void,
        _ landing: MarketShowcaseDomain.Landing,
        _ orderCard: @escaping () -> Void,
        _ payment: @escaping (String) -> Void
    ) -> LandingWrapperView {
        
        if landing.errorMessage != nil {
            
            contentEvent(.failure(.alert("Попробуйте позже.")))
        }
        
        let landingViewModel = model.landingViewModelFactory(
            result: landing,
            config: .default,
            landingActions: {
                
                // TODO: add case
                switch $0 {
                    
                case let .card(action):
                    switch action {
                        
                    case .goToMain:
                        flowEvent(.select(.goToMain))
                    case let .openUrl(url):
                        flowEvent(.select(.openURL(url)))
                    default:
                        break
                    }
                case let .sticker(action):
                    switch action {
                    case .goToMain:
                        flowEvent(.select(.goToMain))
                    default:
                        break
                    }
                default:break
                }
            },
            outsideAction: { flowEvent(.select(.landing($0))) },
            orderCard: orderCard,
            payment: payment,
            scheduler: schedulers.main
        )
        
        return LandingWrapperView(viewModel: landingViewModel)
    }
    
    func makeMarketShowcaseView(
        viewModel: MarketShowcaseDomain.Binder,
        orderCard: @escaping () -> Void,
        payment: @escaping (String) -> Void
    ) -> MarketShowcaseWrapperView {
        
        .init(
            model: viewModel.flow,
            makeContentView: { flowState, flowEvent in
                MarketShowcaseFlowView(
                    state: flowState,
                    event: flowEvent) {
                        MarketShowcaseContentWrapperView(
                            model: viewModel.content,
                            makeContentView: { contentState, contentEvent in
                                MarketShowcaseContentView(
                                    state: contentState,
                                    event: contentEvent,
                                    config: .iFora,
                                    factory: .init(
                                        makeRefreshView: { SpinnerRefreshView(icon: .init("Logo Fora Bank")) },
                                        makeLandingView: {
                                            self.makeLandingView(contentEvent, flowEvent, $0, orderCard, payment)
                                        }
                                    )
                                )
                            })
                    }
            })
    }
}

extension RootViewFactoryComposer {
    
    func makeUpdatingUserAccountButtonLabel(
    ) -> UpdatingUserAccountButtonLabel {
        
        return  .init(
            label: .init(avatar: nil, name: ""),
            publisher: model.userLabelPublisher,
            config: .prod
        )
    }
}

private extension Model {
    
    var userLabelPublisher: AnyPublisher<UserLabel, Never> {
        
        Publishers.CombineLatest3(
            clientPhoto.map(\.?.photo.image),
            clientName.map(\.?.name),
            clientInfo.compactMap(\.?.firstName)
        )
        .map { image, name, firstName in
            
            return .init(avatar: image, name: name ?? firstName)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

private extension AnywayTransactionReport {
    
    var detailID: Int {
        
        switch self.info {
        case let .detailID(detailID): return detailID
        case let .details(details):   return details.id
        }
    }
}

private extension GetSberQRDataResponse.Parameter.Info {
    
    var infoID: InfoComponent.PublishingInfo.ID {
        
        switch id {
        case .amount:        return .amount
        case .brandName:     return .brandName
        case .recipientBank: return .recipientBank
        }
    }
}

extension ImageCache {
    
    func imagePublisher(
        for icon: GetSberQRDataResponse.Parameter.Info.Icon
    ) -> ImageSubject {
        
        switch icon.type {
        case .local:
            return .init(.init(icon.value))
            
        case .remote:
            return image(forKey: .init(icon.value))
        }
    }
    
    func makeIconView(
        for icon: IconDomain.Icon?
    ) -> UIPrimitives.AsyncImage {
        
        switch icon {
        case let .svg(svg):
            return makeSVGIconView(for: svg)
            
        case let .md5Hash(md5Hash) where !md5Hash.rawValue.isEmpty:
            return makeIconView(for: md5Hash.rawValue)
            
        case let .image(imageLink) where !imageLink.isEmpty:
            return makeIconView(for: imageLink)
            
        default:
            return makeIconView(for: "placeholder")
        }
    }
    
    func makeSVGIconView(
        for svg: String
    ) -> UIPrimitives.AsyncImage {
        
        guard let image = Image(svg: svg)
        else { return makeIconView(for: "placeholder") }
        
        return .init(
            image: image,
            publisher: Just(image).eraseToAnyPublisher()
        )
    }
    
    func makeIconView(
        for rawValue: String
    ) -> UIPrimitives.AsyncImage {
        
        let imageSubject = image(forKey: .init(rawValue))
        
        return .init(
            image: imageSubject.value,
            publisher: imageSubject.eraseToAnyPublisher()
        )
    }
}

extension RootViewFactory.MakeInfoViews {
    
    static let `default`: Self = .init(
        makeUpdateInfoView: UpdateInfoView.init(text:),
        makeDisableCorCardsInfoView: DisableCorCardsView.init(text:)
    )
}
