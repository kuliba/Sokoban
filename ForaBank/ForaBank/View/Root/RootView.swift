//
//  RootView.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import ActivateSlider
import InfoComponent
import SberQR
import SwiftUI
import PaymentSticker

struct RootView: View {
    
    @ObservedObject var viewModel: RootViewModel
    
    let rootViewFactory: RootViewFactory
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            GeometryReader { geo in
                
                TabView(selection: $viewModel.selected) {
                    
                    mainViewTab()
                    paymentsViewTab(viewModel.paymentsViewModel)
                    chatViewTab()
                }
                .accentColor(.black)
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
    
    private func mainViewTab() -> some View {
        
        NavigationView {
            
            MainView(
                viewModel: viewModel.mainViewModel,
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
        _ paymentsViewModel: PaymentsTransfersViewModel
    ) -> some View {
        
        NavigationView {
            
            rootViewFactory.makePaymentsTransfersView(paymentsViewModel)
        }
        .taggedTabItem(.payments, selected: viewModel.selected)
        .navigationViewStyle(StackNavigationViewStyle())
        .accessibilityIdentifier("tabBarTransferButton")
    }
    
    private func chatViewTab() -> some View {
        
        ChatView(viewModel: viewModel.chatViewModel)
            .taggedTabItem(.chat, selected: viewModel.selected)
            .accessibilityIdentifier("tabBarChatButton")
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
                mainViewModel: .sample,
                paymentsViewModel: .sample,
                chatViewModel: .init(),
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
                map: Info.preview(info:),
                config: .iFora
            )
        }
        
        return .init(
            makePaymentsTransfersView: {
                
                .init(
                    viewModel: $0,
                    viewFactory: .init(
                        makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
                        makeUserAccountView: UserAccountView.init(viewModel:),
                        makeIconView: IconDomain.preview
                    ),
                    productProfileViewFactory: .init(makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:)),
                    getUImage: { _ in nil }
                )
            },
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeUserAccountView: UserAccountView.init(viewModel:),
            makeIconView: IconDomain.preview,
            makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:)
        )
    }
}
