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
import UtilityServicePrepaymentUI

struct RootView: View {
    
    @ObservedObject var viewModel: RootViewModel
    
    let rootViewFactory: RootViewFactory
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            GeometryReader { geo in
                
                TabView(selection: $viewModel.selected) {
                    
                    mainViewTab(viewModel.tabsViewModelFactory.mainViewModel)
                    paymentsViewTab(viewModel.tabsViewModelFactory.paymentsModel)
                    marketShowcaseViewTab(viewModel.tabsViewModelFactory.marketShowcaseModel)
                    chatViewTab(viewModel.tabsViewModelFactory.chatViewModel)
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
                navigationOperationView: RootViewModelFactory.makeNavigationOperationView(
                    httpClient: viewModel.model.authenticatedHTTPClient(),
                    model: viewModel.model,
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
                
            case let .v1(switcher):
                paymentsTransfersSwitcherView(switcher)
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
        _ marketShowcaseViewModel: MarketShowcaseViewModel
    ) -> some View {
        
        rootViewFactory.makeMarketShowcaseView(viewModel.tabsViewModelFactory.marketShowcaseModel).map {
            $0
            .taggedTabItem(.market, selected: viewModel.selected)
        }
        .taggedTabItem(.market, selected: viewModel.selected)
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
                UserAccountView(viewModel: viewModel)
            }
            
        case let .payments(paymentsViewModel):
            NavigationView {
                PaymentsView(viewModel: paymentsViewModel)
            }
        }
    }
}

// MARK: - PaymentsTransfers v1

private extension RootView {
    
    func paymentsTransfersSwitcherView(
        _ switcher: PaymentsTransfersSwitcher
    ) -> some View {
        
        ComposedProfileSwitcherView(
            model: switcher,
            corporateView: paymentsTransfersCorporateView,
            personalView: paymentsTransfersPersonalView,
            undefinedView: { SpinnerView(viewModel: .init()) }
        )
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
                            makeToolbarView: makePaymentsTransfersToolbarView
                        ),
                        config: .iFora
                    )
                }
            )
        )
    }
    
    func makeCategoryPickerSectionView(
        binder: CategoryPickerSectionBinder
    ) -> some View {
        
        ComposedCategoryPickerSectionFlowView(
            binder: binder,
            config: .iFora,
            itemLabel: itemLabel,
            makeDestinationView: makeCategoryPickerSectionDestinationView
        )
    }
    
    @ViewBuilder
    func makeCategoryPickerSectionDestinationView(
        destination: CategoryPickerSectionDestination
    ) -> some View {
        
        switch destination {
        case let .category(selected):
            selectedCategoryView(selected)
            
        case let .list(categoryListModelStub):
            categoryListView(categoryListModelStub)
        }
    }
    
    @ViewBuilder
    func selectedCategoryView(
        _ selected: SelectedCategoryDestination
    ) -> some View {
        
        switch selected {
        case let .mobile(mobile):
            Text("TBD: \(String(describing: mobile))")
            
        case let .qr(qr):
            Text("TBD: \(String(describing: qr))")
            
        case let .standard(standard):
            switch standard {
            case let .failure(failedPaymentProviderPicker):
                Text("TBD: \(String(describing: failedPaymentProviderPicker))")
                
            case let .success(binder):
                paymentProviderPicker(binder)
            }
            
        case let .taxAndStateServices(taxAndStateServices):
            Text("TBD: \(String(describing: taxAndStateServices))")
            
        case let .transport(transport):
            Text("TBD: \(String(describing: transport))")
        }
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
            
        case let .detailPayment(detailPayment):
            Text("TBD: destination view \(String(describing: detailPayment))")
            
        case let .payment(payment):
            Text("TBD: destination view \(String(describing: payment))")
            
        case let .servicePicker(servicePicker):
            Text("TBD: destination view \(String(describing: servicePicker))")
            
        case let .servicesFailure(servicesFailure):
            Text("TBD: destination view \(String(describing: servicesFailure))")
        }
    }
    
    func categoryListView(
        _ categoryListModelStub: CategoryListModelStub
    ) -> some View {
        
        Text("TBD: CategoryPickerSectionDestinationView for \(String(describing: categoryListModelStub))")
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
            CurrencyWalletView(viewModel: currencyWalletViewModel)
            
        case let .latest(latest):
            Text("TBD: destination " + String(describing: latest))
            
        case let .status(operationPickerFlowStatus):
            EmptyView()
            
        case let .templates(templates):
            Text("TBD: destination " + String(describing: templates))
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
    
    private func itemLabel(
        item: CategoryPickerSectionState.Item
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
                navigationStateManager: .preview,
                productNavigationStateManager: .preview,
                tabsViewModelFactory: .preview,
                informerViewModel: .init(.emptyMock),
                .emptyMock,
                showLoginAction: { _ in
                    
                        .init(viewModel: .init(authLoginViewModel: .preview))
                }
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
            makeHistoryButtonView: { _ in .init { event in }},
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
                        makeUserAccountView: UserAccountView.init(viewModel:)
                    ),
                    productProfileViewFactory: .init(
                        makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:),
                        makeHistoryButton: { .init(event: $0 ) },
                        makeRepeatButtonView: { _ in .init(action: {})}
                    ),
                    getUImage: { _ in nil }
                )
            },
            makeReturnButtonView: { _ in .init(action: {}) },
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeInfoViews: .default,
            makeUserAccountView: UserAccountView.init(viewModel:),
            makeMarketShowcaseView: { _ in .none }
        )
    }
}
