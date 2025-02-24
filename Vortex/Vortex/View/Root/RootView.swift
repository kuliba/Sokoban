//
//  RootView.swift
//  Vortex
//
//  Created by Max Gribov on 15.02.2022.
//

import ActivateSlider
import Combine
import FooterComponent
import InfoComponent
import LandingUIComponent
import LoadableResourceComponent
import MarketShowcase
import PayHubUI
import PaymentSticker
import RxViewModel
import SberQR
import SwiftUI
import UIPrimitives
import UtilityServicePrepaymentUI

struct RootView: View {
    
    @ObservedObject var viewModel: RootViewModel
    
    let rootViewFactory: RootViewFactory
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            GeometryReader { geo in
                
                TabView(selection: $viewModel.selected.animation(.easeOut)) {
                    
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
                getUImage: { viewModel.model.images.value[$0]?.uiImage },
                makeImageView: viewModel.model.generalImageCache().makeIconView(for:)
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
                rootViewFactory.components.makePaymentsTransfersSwitcherView(switcher)

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
        
        rootViewFactory.makeMarketShowcaseView(
            marketShowcaseBinder,
            viewModel.openCard,
            viewModel.openPayment
        )
        .taggedTabItem(.market, selected: viewModel.selected)
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
                
                rootViewFactory.makeUserAccountView(viewModel)
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

extension PaymentsTransfersCorporateDomain.Binder {
    
    func refresh() {
        
        self.content.reload()
    }
}

extension PaymentsTransfersPersonalDomain.Binder {
    
    func refresh() {
        
        self.content.reload()
    }
}

// MARK: - adapters

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

extension PaymentProviderPickerDomain.Flow {
    
    func handleFooterEvent(
        _ event: FooterEvent
    ) {
        switch event {
        case .addCompany:
            self.event(.select(.outside(.chat)))
            
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
        _ provider: PaymentProviderPickerDomain.Provider
    ) {
        self.event(.select(.provider(provider)))
    }
}

extension Latest: Named {}

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
            return isSelected ? .ic24LogoVortexColor : .ic24LogoVortexLine
            
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
                splash: .preview,
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

private extension SplashScreenViewModel {
    
    static let preview: SplashScreenViewModel = .init(
        initialState: .initialSplashData,
        reduce: {
            state,
            _ in (state, nil)
        },
        handleEffect: { _,_ in }
    )
}


private extension RootViewFactory {
    
    static var preview: Self {
        
        let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView = {
            
            .init(
                viewModel: $0,
                map: PublishingInfo.preview(info:),
                config: .iVortex
            )
        }
        
        let makeSplashScreenView: MakeSplashScreenView = { state, event in
            
            .init(splash: state, config: .prod())
        }
        
        return .init(
            rootEvent: { _ in },
            infra: .init(
                imageCache: .preview,
                generalImageCache: .preview,
                getUImage: { _ in nil }
            ),
            makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:),
            makeAnywayPaymentFactory: { _ in fatalError() },
            makeHistoryButtonView: { _,_,_,_   in
                HistoryButtonView(event: { event in }, isFiltered: { return true }, isDateFiltered: { true }, clearOptions: {})
            },
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
                        makeUserAccountView: {
                            
                            return .init(viewModel: $0, config: .preview, viewFactory: .preview)
                        },
                        components: .preview,
                        makeCollateralLoanShowcaseWrapperView: { _,_ in .preview }
                    ),
                    productProfileViewFactory: .init(
                        makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:),
                        makeHistoryButton: { .init(event: $0, isFiltered: { return true }, isDateFiltered: { true }, clearOptions: $3) },
                        makeRepeatButtonView: { _ in .init(action: {}) }
                    ),
                    getUImage: { _ in nil }
                )
            },
            makeReturnButtonView: { _ in .init(action: {}) },
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeSplashScreenView: makeSplashScreenView,
            makeUserAccountView: {
                
                return .init(
                    viewModel: $0,
                    config: .preview,
                    viewFactory: .preview
                )
            },
            makeMarketShowcaseView: { _,_,_ in .none },
            components: .preview,
            paymentsViewFactory: .preview,
            makeTemplateButtonWrapperView: {
                
                .init(viewModel: .init(model: .emptyMock, operation: nil, operationDetail: $0))
            },
            makeUpdatingUserAccountButtonLabel: {
                
                .init(label: .init(avatar: nil, name: ""), publisher: Empty().eraseToAnyPublisher(), config: .preview)
            }, 
            makeCollateralLoanShowcaseWrapperView: { _,_ in .preview }
        )
    }
}

private extension ImageCache {
    
    static let preview: ImageCache = .init(
        requestImages: { _ in },
        imagesPublisher: .init([:]),
        fallback: { _ in .ic24MoreHorizontal }
    )
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

private extension UserAccountButtonLabelConfig {
    
    static let preview = prod
}
