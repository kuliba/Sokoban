//
//  RootView.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import ActivateSlider
import InfoComponent
import FooterComponent
import PaymentSticker
import PayHubUI
import RxViewModel
import SberQR
import SwiftUI
import MarketShowcase
import UIPrimitives
import UtilityServicePrepaymentUI
import LandingUIComponent
import LoadableResourceComponent

struct RootView: View {
    
    @ObservedObject var viewModel: RootViewModel
    
    let rootViewFactory: RootViewFactory
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            GeometryReader { geo in
                
                TabView(selection: $viewModel.selected) {
                    
                    mainViewTab(viewModel.tabsViewModel.mainViewModel)
                    paymentsViewTab(viewModel.tabsViewModel.paymentsModel)
                    marketShowcaseViewTab(viewModel.tabsViewModel.marketShowcaseBinder)
                    chatViewTab(viewModel.tabsViewModel.chatViewModel)
                }
                .accentColor(.black)
                .tabBar(isHidden: .init(
                    get: { viewModel.isTabBarHidden },
                    set: { if !$0 { viewModel.reset() }}
                ))
                .accessibilityIdentifier("tabBar")
                .environment(\.mainViewSize, geo.size)
            }
            
            //FIXME: this is completely wrong implementation. There is no chance that in will work like NavigationView stack. Refactoring required.
            viewModel.link.map(destinationView(link:))
        }
        .alert(
            item: $viewModel.alert,
            content: Alert.init(with:)
        )
    }
    
    private func mainViewTab(
        _ mainViewModel: MainViewModel
    ) -> some View {
        
        NavigationView {
            
            MainView(
                viewModel: mainViewModel,
                navigationOperationView: viewModel.stickerViewFactory.makeNavigationOperationView(
                    dismissAll: viewModel.rootActions.dismissAll
                ),
                viewFactory: rootViewFactory.mainViewFactory,
                paymentsTransfersViewFactory: rootViewFactory.paymentsTransfersViewFactory,
                productProfileViewFactory: rootViewFactory.productProfileViewFactory,
                getUImage: { viewModel.model.images.value[$0]?.uiImage }
            )
        }
        .taggedTabItem(.main, selected: viewModel.selected)
        .navigationViewStyle(StackNavigationViewStyle())
        .accessibilityIdentifier("tabBarMainButton")
    }
    
    private func paymentsViewTab(
        _ paymentsModel: RootViewModel.PaymentsModel
    ) -> some View {
        
        NavigationView {
            
            switch paymentsModel {
            case let .legacy(paymentsViewModel):
                rootViewFactory.makePaymentsTransfersView(paymentsViewModel)
                
            case let .v1(switcher as PaymentsTransfersSwitcher):
                paymentsTransfersSwitcherView(switcher)

            default:
                EmptyView()
            }
        }
        .taggedTabItem(.payments, selected: viewModel.selected)
        .navigationViewStyle(StackNavigationViewStyle())
        .accessibilityIdentifier("tabBarTransferButton")
    }
    
    private func chatViewTab(
        _ chatViewModel: ChatViewModel
    ) -> some View {
        
        ChatView(viewModel: chatViewModel)
            .taggedTabItem(.chat, selected: viewModel.selected)
            .accessibilityIdentifier("tabBarChatButton")
    }
    
    private func marketShowcaseViewTab(
        _ marketShowcaseBinder: MarketShowcaseDomain.Binder
    ) -> some View {
        
        rootViewFactory.makeMarketShowcaseView(marketShowcaseBinder, viewModel.openCard, viewModel.openPayment).map {
            $0
            .taggedTabItem(.market, selected: viewModel.selected)
        }
        .onAppear { marketShowcaseBinder.content.event(.load) }
        .navigationViewStyle(StackNavigationViewStyle())
        .accessibilityIdentifier("tabBarMarketButton")
    }
    
    @ViewBuilder
    private func destinationView(
        link: RootViewModel.Link
    ) -> some View {
        
        switch link {
        case .messages(let messagesHistoryViewModel):
            //FIXME: looks like NavigationView required
            MessagesHistoryView(viewModel: messagesHistoryViewModel)
            //FIXME: looks like zIndex not needed
                .zIndex(.greatestFiniteMagnitude)
            
        case .me2me(let requestMeToMeModel):
            //FIXME: looks like NavigationView required
            MeToMeRequestView(viewModel: requestMeToMeModel)
                .ignoresSafeArea()
            //FIXME: looks like zIndex not needed
                .zIndex(.greatestFiniteMagnitude)
            
        case .userAccount(let viewModel):
            NavigationView {
                rootViewFactory.makeUserAccountView(viewModel, .iFora)
            }
            
        case let .payments(paymentsViewModel):
            NavigationView {
                rootViewFactory.components.makePaymentsView(paymentsViewModel)
            }
            
        case let .landing(viewModel, needIgnoringSafeArea):
            NavigationView {
                LandingWrapperView(viewModel: viewModel)
                    .modifier(IgnoringSafeArea(needIgnoringSafeArea, .bottom))
            }
            .accentColor(.textSecondary)
                        
        case let .openCard(viewModel):
            NavigationView {
                AuthProductsView(viewModel: viewModel)
            }
            
        case .paymentSticker:
            
            NavigationView {
                
                viewModel.stickerViewFactory.makeNavigationOperationView(
                    dismissAll: viewModel.rootActions.dismissAll
                )()
                    .navigationBarTitle("Оформление заявки", displayMode: .inline)
                    .edgesIgnoringSafeArea(.bottom)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: Button(action: viewModel.resetLink) { Image("ic24ChevronLeft") })
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - PaymentsTransfers v1

extension PaymentsTransfersSwitcher: Refreshable {
    
    func refresh() {
        
        switch state {
        case .none:
            break
            
        case let .corporate(corporate):
            corporate.refresh()
            
        case let .personal(personal):
            personal.refresh()
        }
    }
}

extension PaymentsTransfersCorporate {
    
    func refresh() {
        
        self.content.reload()
    }
}

extension PaymentsTransfersPersonal {
    
    func refresh() {
        
        self.content.reload()
    }
}

private extension RootView {
    
    func paymentsTransfersSwitcherView(
        _ switcher: PaymentsTransfersSwitcher
    ) -> some View {
        
        RefreshableScrollView(
            action: switcher.refresh,
            showsIndicators: false,
            refreshCompletionDelay: 2.0
        ) {
            ComposedProfileSwitcherView(
                model: switcher,
                corporateView: paymentsTransfersCorporateView,
                personalView: paymentsTransfersPersonalView,
                undefinedView: { SpinnerView(viewModel: .init()) }
            )
        }
    }
    
    func paymentsTransfersCorporateView(
        _ corporate: PaymentsTransfersCorporate
    ) -> some View {
        
        ComposedPaymentsTransfersCorporateView(
            corporate: corporate,
            factory: .init(
                makeContentView: {
                    PaymentsTransfersCorporateContentView(
                        content: corporate.content,
                        factory: .init(
                            makeBannerSectionView: makeBannerSectionView,
                            makeRestrictionNoticeView: makeRestrictionNoticeView,
                            makeToolbarView: makePaymentsTransfersCorporateToolbarView,
                            makeTransfersSectionView: makeTransfersSectionView
                        ),
                        config: .iFora
                    )
                }
            )
        )
    }
    
    func makeRestrictionNoticeView() -> some View {
        
        DisableCorCardsView(text: .disableForCorCards)
    }
    
    func makePaymentsTransfersCorporateToolbarView() -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            
            HStack {
                
                Image(systemName: "person")
                Text("TBD: Profile without QR")
            }
        }
    }
    
    func makeTransfersSectionView() -> some View {
        
        ZStack {
            
            Color.green.opacity(0.5)
            
            Text("Transfers")
                .foregroundColor(.white)
                .font(.title3.bold())
        }
    }
    
    func paymentsTransfersPersonalView(
        _ personal: PaymentsTransfersPersonal
    ) -> some View {
        
        ComposedPaymentsTransfersPersonalView(
            personal: personal,
            factory: .init(
                makeContentView: {
                    
                    PaymentsTransfersPersonalContentView(
                        content: personal.content,
                        factory: .init(
                            makeCategoryPickerView: makeCategoryPickerSectionView,
                            makeOperationPickerView: makeOperationPickerView,
                            makeToolbarView: makePaymentsTransfersToolbarView,
                            makeTransfersView: makePaymentsTransfersTransfersView
                        ),
                        config: .iFora
                    )
                }
            )
        )
    }
    
    @ViewBuilder
    func makeCategoryPickerSectionView(
        categoryPicker: PayHubUI.CategoryPicker
    ) -> some View {
        
        if let binder = categoryPicker.sectionBinder {
            
            makeCategoryPickerSectionView(binder: binder)
            
        } else {
            
            Text("Unexpected categoryPicker type \(String(describing: categoryPicker))")
                .foregroundColor(.red)
        }
    }
    
    func makeCategoryPickerSectionView(
        binder: CategoryPickerSectionDomain.Binder
    ) -> some View {
        
        ComposedCategoryPickerSectionView(
            binder: binder,
            factory: .init(
                makeAlert: makeCategoryPickerSectionAlert(binder: binder),
                makeContentView: {
                    
                    ComposedCategoryPickerSectionContentView(
                        content: binder.content,
                        makeContentView: { state, event in
                            
                            CategoryPickerSectionContentView(
                                state: state,
                                event: event,
                                config: .iFora,
                                itemLabel: itemLabel
                            )
                        }
                    )
                },
                makeDestinationView: makeCategoryPickerSectionDestinationView,
                makeFullScreenCoverView: makeCategoryPickerSectionFullScreenCoverView
            )
        )
        .padding(.top, 20)
    }
    
    func makeCategoryPickerSectionAlert(
        binder: CategoryPickerSectionDomain.Binder
    ) -> (SelectedCategoryFailure) -> Alert {
        
        return { failure in
            
            return .init(
                with: .error(message: failure.message, event: .dismiss),
                event: { binder.flow.event($0) }
            )
        }
    }
    
    @ViewBuilder
    func makeCategoryPickerSectionDestinationView(
        destination: CategoryPickerSectionNavigation.Destination
    ) -> some View {
        
        switch destination {
        case let .paymentFlow(paymentFlow):
            switch paymentFlow {
            case let .mobile(mobile):
                rootViewFactory.components.makePaymentsView(mobile.paymentsViewModel)
                
            case let .standard(standard):
                switch standard {
                case let .failure(failedPaymentProviderPicker):
                    Text("TBD: \(String(describing: failedPaymentProviderPicker))")
                    
                case let .success(binder):
                    paymentProviderPicker(binder)
                }
                
            case let .taxAndStateServices(wrapper):
                rootViewFactory.components.makePaymentsView( wrapper.paymentsViewModel)
                
            case let .transport(transport):
                transportPaymentsView(transport)
            }
            
        case let .qrDestination(qrDestination):
            qrDestinationView(qrDestination)
        }
    }
    
    @ViewBuilder
    func makeCategoryPickerSectionFullScreenCoverView(
        cover: CategoryPickerSectionNavigation.FullScreenCover
    ) -> some View {
        
        NavigationView {
            
            rootViewFactory.components.makeQRView(cover.qr.qrScanner)
        }
        .navigationViewStyle(.stack)
    }
    
    func paymentProviderPicker(
        _ binder: PaymentProviderPicker.Binder
    ) -> some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: { state, event in
                
                PaymentProviderPickerFlowView(
                    state: state,
                    event: event,
                    contentView: {
                        
                        paymentProviderPickerContentView(binder)
                    },
                    destinationView: {
                        
                        paymentProviderPickerDestinationView($0)
                    }
                )
            }
        )
    }
    
    func paymentProviderPickerContentView(
        _ binder: PaymentProviderPicker.Binder
    ) -> some View {
        
        PaymentProviderPickerContentView(
            content: binder.content,
            factory: .init(
                makeOperationPickerView: { _ in EmptyView() },
                makeProviderList: {
                    
                    paymentProviderListView(providerList: $0, binder: binder)
                },
                makeSearchView: { _ in EmptyView() }
            )
        )
    }
    
    func paymentProviderListView(
        providerList: PaymentProviderPicker.ProviderList,
        binder: PaymentProviderPicker.Binder
    ) -> some View {
        
        RxWrapperView(
            model: providerList,
            makeContentView: { state, event in
                
                PrepaymentPickerSuccessView(
                    state: state,
                    event: event,
                    factory: .init(
                        makeFooterView: {
                            
                            FooterView(
                                state: $0 ? .failure(.iFora) : .footer(.iFora),
                                event: binder.flow.handleFooterEvent(_:),
                                config: .iFora
                            )
                        },
                        makeLastPaymentView: {
                            
                            makeLatestPaymentView(latest: $0, event: binder.flow.selectLatest(_:))
                        },
                        makeOperatorView: {
                            
                            makeOperatorView(provider: $0, event: binder.flow.selectProvider(_:))
                        },
                        makeSearchView: {
                            
                            paymentProviderPickerSearchView(binder.content.search)
                        }
                    )
                )
            }
        )
    }
    
    func makeLatestPaymentView(
        latest: Latest,
        event: @escaping (Latest) -> Void
    ) -> some View {
        
        Button(
            action: { event(latest) },
            label: {
                
                LastPaymentLabel(
                    amount: latest.amount.map { "\($0) ₽" } ?? "",
                    title: latest.name,
                    config: .iFora,
                    iconView: makeIconView(md5Hash: latest.md5Hash)
                )
                .contentShape(Rectangle())
            }
        )
    }
    
    func makeOperatorView(
        provider: PaymentProviderPicker.Provider,
        event: @escaping (PaymentProviderPicker.Provider) -> Void
    ) -> some View {
        
        Button(
            action: { event(provider) },
            label: {
                
                OperatorLabel(
                    title: provider.name,
                    subtitle: provider.inn,
                    config: .iFora,
                    iconView: makeIconView(md5Hash: provider.md5Hash)
                )
                .contentShape(Rectangle())
            }
        )
    }
        
    @ViewBuilder
    func transportPaymentsView(
        _ transport: TransportPaymentsViewModel
    ) -> some View {
        
        let mosParkingPickerData: LoadableResourceViewModel<MosParkingPickerData> =  .init(
            operation: viewModel.model.getMosParkingPickerData
        )
        
        rootViewFactory.components.makeTransportPaymentsView(mosParkingPickerData, transport)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBar(
                with: .with(
                    title: "Транспорт",
                    navLeadingAction: {},//viewModel.dismiss,
                    navTrailingAction: {}//viewModel.openScanner
                )
            )
    }
    
    @ViewBuilder
    func qrDestinationView(
        _ qrDestination: QRNavigation.Destination
    ) -> some View {
        
        switch qrDestination {
        case let .qrFailedViewModel(qrFailedViewModel):
            rootViewFactory.components.makeQRFailedView(qrFailedViewModel)
            
        case let .internetTV(viewModel):
            InternetTVDetailsView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .operatorSearch(viewModel):
            rootViewFactory.components.makeQRSearchOperatorView(viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            
        case let .payments(wrapper):
            rootViewFactory.components.makePaymentsView(wrapper.paymentsViewModel)
            
        case let .paymentComplete(paymentComplete):
            rootViewFactory.components.makePaymentsSuccessView(paymentComplete)
            
        case let .providerPicker(providerPicker):
            paymentProviderPicker(providerPicker)
            
        case let .sberQR(sberQR):
            rootViewFactory.makeSberQRConfirmPaymentView(sberQR)
            
        case let .servicePicker(servicePicker):
            servicePickerView(servicePicker)
        }
    }
    
    func paymentProviderPicker(
        _ flowModel: SegmentedPaymentProviderPickerFlowModel
    ) -> some View {
        
        rootViewFactory.components.makeComposedSegmentedPaymentProviderPickerFlowView(flowModel)
        //    .navigationBarWithBack(
        //        title: PaymentsTransfersSectionType.payments.name,
        //        dismiss: viewModel.dismissPaymentProviderPicker,
        //        rightItem: .barcodeScanner(
        //            action: viewModel.dismissPaymentProviderPicker
        //        )
        //    )
    }
    
    @ViewBuilder
    func servicePickerView(
        _ flowModel: AnywayServicePickerFlowModel
    ) -> some View {
        
        let provider = flowModel.state.content.state.payload.provider
        
        rootViewFactory.components.makeAnywayServicePickerFlowView(flowModel)
//        .navigationBarWithAsyncIcon(
//            title: provider.origin.title,
//            subtitle: provider.origin.inn,
//            dismiss: viewModel.dismissProviderServicePicker,
//            icon: viewFactory.iconView(provider.origin.icon),
//            style: .normal
//        )
    }
    
    func makeIconView(
        md5Hash: String?
    ) -> some View {
        
        rootViewFactory.makeIconView(md5Hash.map { .md5Hash(.init($0)) })
    }
    
    @ViewBuilder
    func paymentProviderPickerSearchView(
        _ search: PaymentProviderPicker.Search?
    ) -> some View {
        
        search.map { search in
            
            DefaultCancellableSearchBarView(
                viewModel: search,
                textFieldConfig: .black16,
                cancel: {
                    
                    UIApplication.shared.endEditing()
                    search.setText(to: nil)
                }
            )
        }
    }
    
    @ViewBuilder
    func paymentProviderPickerDestinationView(
        _ destination: PaymentProviderPicker.Destination
    ) -> some View {
        
        switch destination {
        case let .backendFailure(backendFailure):
            Text("TBD: destination view \(String(describing: backendFailure))")
            
        case let .detailPayment(wrapper):
            rootViewFactory.components.makePaymentsView(wrapper.paymentsViewModel)
            
        case let .payment(payment):
            Text("TBD: destination view \(String(describing: payment))")
            
        case let .servicePicker(servicePicker):
            Text("TBD: destination view \(String(describing: servicePicker))")
            
        case let .servicesFailure(servicesFailure):
            Text("TBD: destination view \(String(describing: servicesFailure))")
        }
    }
    
    @ViewBuilder
    func makeOperationPickerView(
        operationPicker: PayHubUI.OperationPicker
    ) -> some View {
        
        if let binder = operationPicker.operationBinder {
            
            makeOperationPickerView(binder: binder)
            
        } else {
            
            Text("Unexpected operationPicker type \(String(describing: operationPicker))")
                            .foregroundColor(.red)
        }
    }
    
    func makeOperationPickerView(
        binder: OperationPickerBinder
    ) -> some View {
        
        ComposedOperationPickerFlowView(
            binder: binder,
            factory: .init(
                makeDestinationView: makeOperationPickerDestinationView,
                makeItemLabel: itemLabel
            )
        )
    }
    
    @ViewBuilder
    func makeOperationPickerDestinationView(
        destination: OperationPickerNavigation
    ) -> some View {
        
        switch destination {
        case let .exchange(currencyWalletViewModel):
            rootViewFactory.components.makeCurrencyWalletView(currencyWalletViewModel)
            
        case let .latest(latest):
            Text("TBD: destination " + String(describing: latest))
            
        case let .status(operationPickerFlowStatus):
            EmptyView()
            
        case let .templates(templates):
            Text("TBD: destination " + String(describing: templates))
        }
    }
    
    @ViewBuilder
    func makePaymentsTransfersToolbarView(
        toolbar: PayHubUI.PaymentsTransfersPersonalToolbar
    ) -> some View {
        
        if let binder = toolbar.toolbarBinder {
            
            makePaymentsTransfersToolbarView(binder: binder)
            
        } else {
            
            Text("Unexpected toolbar type \(String(describing: toolbar))")
                .foregroundColor(.red)
        }
    }
    
    func makePaymentsTransfersToolbarView(
        binder: PaymentsTransfersPersonalToolbarBinder
    ) -> some View {
        
        ComposedPaymentsTransfersPersonalToolbarView(
            binder: binder,
            factory: .init(
                makeDestinationView: {
                    
                    switch $0 {
                    case let .profile(profileModel):
                        Text(String(describing: profileModel))
                    }
                },
                makeFullScreenView: {
                    
                    switch $0 {
                    case let .qr(qrModel):
                        VStack(spacing: 32) {
                            
                            Text(String(describing: qrModel))
                        }
                    }
                },
                makeProfileLabel: {
                    
                    HStack {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                },
                makeQRLabel: {
                    
                    Image(systemName: "qrcode")
                }
            )
        )
    }
    
    @ViewBuilder
    private func makePaymentsTransfersTransfersView(
        transfersPicker: PayHubUI.TransfersPicker
    ) -> some View {
        
        if let binder = transfersPicker.transfersBinder {
            
            makePaymentsTransfersTransfersView(transfers: binder)
            
        } else {
            
            Text("Unexpected transfersPicker type \(String(describing: transfersPicker))")
                .foregroundColor(.red)
        }
    }
    
    private func makePaymentsTransfersTransfersView(
        transfers: PaymentsTransfersPersonalTransfersDomain.Binder
    ) -> some View {
        
        ComposedPaymentsTransfersTransfersView(
            flow: transfers.flow,
            contentView: {
                
                ComposedPaymentsTransfersTransfersContentView(
                    content: transfers.content
                )
            },
            factory: rootViewFactory.personalTransfersFlowViewFactory
        )
    }
    
    private func itemLabel(
        item: CategoryPickerSectionDomain.ContentDomain.State.Item
    ) -> some View {
        
        CategoryPickerSectionStateItemLabel(
            item: item,
            config: .iFora,
            categoryIcon: categoryIcon,
            placeholderView: { PlaceholderView(opacity: 0.5) }
        )
    }
    
    private func itemLabel(
        item: OperationPickerState.Item
    ) -> some View {
        
        OperationPickerStateItemLabel(
            item: item,
            config: .iFora,
            placeholderView:  {
                
                LatestPlaceholder(
                    opacity: 1,
                    config: OperationPickerStateItemLabelConfig.iFora.latestPlaceholder
                )
            }
        )
    }
    
    private func categoryIcon(
        category: ServiceCategory
    ) -> some View {
        
        Color.blue.opacity(0.1)
    }
}

// MARK: - View Factories

private extension RootViewFactory {
    
    var personalTransfersFlowViewFactory: PaymentsTransfersPersonalTransfersFlowViewFactory {
        
        return .init(
            makeContactsView: components.makeContactsView,
            makePaymentsMeToMeView: components.makePaymentsMeToMeView,
            makePaymentsView: components.makePaymentsView
        )
    }
}

// MARK: - payment flow

private extension RootView {
    
    @ViewBuilder
    func makeAnywayFlowView(
        flowModel: AnywayFlowModel
    ) -> some View {
        
        let anywayPaymentFactory = rootViewFactory.makeAnywayPaymentFactory {
            
            flowModel.state.content.event(.payment($0))
        }
        
        AnywayFlowView(
            flowModel: flowModel,
            factory: .init(
                makeElementView: anywayPaymentFactory.makeElementView,
                makeFooterView: anywayPaymentFactory.makeFooterView
            ),
            makePaymentCompleteView: {
                
                rootViewFactory.makePaymentCompleteView(
                    .init(
                        formattedAmount: $0.formattedAmount,
                        merchantIcon: $0.merchantIcon,
                        result: $0.result.mapError {
                            
                            return .init(hasExpired: $0.hasExpired)
                        }
                    ),
                    { flowModel.event(.goTo(.main)) }
                )
            }
        )
    }
}


private extension AlertModelOf<CategoryPickerSectionDomain.FlowDomain.Event> {
    
    static func error(
        message: String? = nil,
        event: PrimaryEvent
    ) -> Self {
        
        .default(
            title: message != .errorRequestLimitExceeded ? "Ошибка" : "",
            message: message,
            primaryEvent: event
        )
    }
    
    private static func `default`(
        title: String,
        message: String?,
        primaryEvent: PrimaryEvent,
        secondaryEvent: SecondaryEvent? = nil
    ) -> Self {
        
        .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: primaryEvent
            ),
            secondaryButton: secondaryEvent.map {
                
                .init(
                    type: .cancel,
                    title: "Отмена",
                    event: $0
                )
            }
        )
    }
}

extension PaymentProviderPicker.Flow {
    
    func handleFooterEvent(
        _ event: FooterEvent
    ) {
        switch event {
        case .addCompany:
            self.event(.select(.chat))
            
        case .payByInstruction:
            self.event(.select(.detailPayment))
        }
    }
    
    func selectLatest(
        _ latest: Latest
    ) {
        self.event(.select(.latest(latest)))
    }
    
    func selectProvider(
        _ provider: PaymentProviderPicker.Provider
    ) {
        self.event(.select(.provider(provider)))
    }
}

extension Latest: Named {
    
    public var name: String {
        
        switch self {
        case let .service(service):
            return service.name ?? String(describing: service)
            
        case let .withPhone(withPhone):
            return withPhone.name ?? String(describing: withPhone)
        }
    }
    
    var amount: Decimal? {
        
        switch self {
        case let .service(service):
            return service.amount
            
        case let .withPhone(withPhone):
            return withPhone.amount
        }
    }
    
    var md5Hash: String? {
        
        switch self {
        case let .service(service):
            return service.md5Hash
            
        case let .withPhone(withPhone):
            return withPhone.md5Hash
        }
    }
}

extension ServiceCategory: Named {}

extension View {
    
    func taggedTabItem(
        _ tab: RootViewModel.TabType,
        selected: RootViewModel.TabType
    ) -> some View  {
        
        self
            .tabItem {
                
                tab.tabIcon(isSelected: tab == selected)
                Text(tab.name)
                    .foregroundColor(.black)
            }
            .tag(tab)
    }
}

extension RootViewModel.TabType {
    
    @ViewBuilder
    func tabIcon(
        isSelected: Bool
    ) -> some View {
        
        let icon = icon(isSelected: isSelected)
        
        if isSelected {
            
            icon
                .renderingMode(.original)
        } else {
            
            icon
                .renderingMode(.template)
                .foregroundColor(.iconGray)
        }
    }
    
    func icon(isSelected: Bool) -> Image {
        
        switch self {
        case .main:
            return isSelected ? .ic24LogoForaColor : .ic24LogoForaLine
            
        case .payments:
            return isSelected ? .ic24PaymentsActive : .ic24PaymentsInactive
            
        case .history:
            return isSelected ? .ic24HistoryActive : .ic24HistoryInactive
            
        case .chat:
            return isSelected ? .ic24ChatActive : .ic24ChatInactive
            
        case .market:
            return isSelected ? .ic24MarketplaceActive : .ic24MarketplaceInactive
        }
    }
}

struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        RootView(
            viewModel: .init(
                fastPaymentsFactory: .legacy, 
                stickerViewFactory: .preview,
                navigationStateManager: .preview,
                productNavigationStateManager: .preview,
                tabsViewModel: .preview,
                informerViewModel: .init(.emptyMock),
                .emptyMock,
                showLoginAction: { _ in
                    
                        .init(viewModel: .init(authLoginViewModel: .preview))
                }, 
                landingServices: .empty()
            ),
            rootViewFactory: .preview
        )
    }
}

private extension RootViewFactory {
    
    static var preview: Self {
        
        let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView = {
            
            .init(
                viewModel: $0,
                map: PublishingInfo.preview(info:),
                config: .iFora
            )
        }
        
        return .init(
            makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:),
            makeAnywayPaymentFactory: { _ in fatalError() },
            makeHistoryButtonView: { _,_,_,_   in
                HistoryButtonView(event: { event in }, isFiltered: { return true }, isDateFiltered: { true }, clearOptions: {})
            },
            makeIconView: IconDomain.preview,
            makeGeneralIconView: IconDomain.preview,
            makePaymentCompleteView: { _,_ in fatalError() },
            makePaymentsTransfersView: {
                
                .init(
                    viewModel: $0,
                    viewFactory: .init(
                        makeAnywayPaymentFactory: { _ in fatalError() },
                        makeIconView: IconDomain.preview, 
                        makeGeneralIconView: IconDomain.preview,
                        makePaymentCompleteView: { _,_ in fatalError() },
                        makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
                        makeInfoViews: .default,
                        makeUserAccountView: { UserAccountView.init(viewModel: $0, config: $1, viewFactory: .preview) },
                        components: .preview
                    ),
                    productProfileViewFactory: .init(
                        makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:),
                        makeHistoryButton: { .init(event: $0, isFiltered: { return true }, isDateFiltered: { true }, clearOptions: $3) },
                        makeRepeatButtonView: { _ in .init(action: {})}
                    ),
                    getUImage: { _ in nil }
                )
            },
            makeReturnButtonView: { _ in .init(action: {}) },
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeInfoViews: .default,
            makeUserAccountView: { _,_ in UserAccountView.init(viewModel: .sample, config: .preview, viewFactory: .preview) },
            makeMarketShowcaseView: { _,_,_   in .none },
            components: .preview
        )
    }
}

private struct IgnoringSafeArea: ViewModifier {
    
    let needIgnoringSafeArea: Bool
    let edgeSet: Edge.Set
    
    init(
        _ needIgnoringSafeArea: Bool,
        _ edgeSet: Edge.Set
    ) {
        self.needIgnoringSafeArea = needIgnoringSafeArea
        self.edgeSet = edgeSet
    }
        
    func body(content: Content) -> some View {
        
        if needIgnoringSafeArea {
            content
                .edgesIgnoringSafeArea(edgeSet)
        } else { content }
    }
}
