//
//  ControlPanelWrapperView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 03.07.2024.
//

import SwiftUI
import RxViewModel
import ManageSubscriptionsUI
import UIPrimitives

typealias ControlPanelViewModel = RxViewModel<ControlPanelState, ControlPanelEvent, ControlPanelEffect>

struct ControlPanelWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
    private let config: Config
    private let getUImage: (Md5hash) -> UIImage?

    init(
        viewModel: ViewModel,
        config: Config,
        getUImage: @escaping (Md5hash) -> UIImage?
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.config = config
        self.getUImage = getUImage
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                NavigationBar(viewModel.state.navigationBarInfo)
                ControlPanelView(
                    state: viewModel.state,
                    event: { viewModel.event($0) },
                    config: config,
                    destinationView: destinationView
                )
                .alert(
                    item: viewModel.state.alert,
                    content: Alert.init(with:)
                )
            }

            viewModel.state.spinner.map { spinner in
                
                SpinnerView(viewModel: spinner)
                    .zIndex(.greatestFiniteMagnitude)
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    private func destinationView(_ destination: ControlPanelState.Destination) -> some View {
        
        switch destination {
        case let .contactTransfer(viewModel):
            return AnyView(PaymentsView(viewModel: viewModel))
            
        case let .migTransfer(viewModel):
            return AnyView(PaymentsView(viewModel: viewModel))

        case let .landing(viewModel):
            return AnyView(AuthProductsView(viewModel: viewModel))
            
        case let .orderSticker(view):
            
            let newView = view
                .navigationBarTitle("Оформление заявки", displayMode: .inline)
                .edgesIgnoringSafeArea(.bottom)

            return AnyView(newView)
            
        case let .openDeposit(viewModel):
            return AnyView(OpenDepositDetailView(viewModel: viewModel, getUImage: getUImage))

        case let .openDepositsList(viewModel):
            return AnyView(OpenDepositListView(viewModel: viewModel, getUImage: getUImage))
            
        case let .openSubscriptions(subscriptionViewModel):
            return AnyView(ManagingSubscriptionView(
                subscriptionViewModel: subscriptionViewModel,
                configurator: .config,
                footerImage: .ic72Sbp,
                searchCancelAction: subscriptionViewModel.searchViewModel.dismissKeyboard)
            )
            
        case let .successView(successViewModel):
            return AnyView(PaymentsSuccessView(viewModel: successViewModel))
        }
    }
}

extension ControlPanelWrapperView {
    
    typealias ViewModel = ControlPanelViewModel
    typealias Config = ControlPanelViewConfig
}

private extension ManageSubscriptionsUI.ProductViewConfig {
    
    static let config: Self = .init(
        titleFont: .textBodyMR14180(),
        titleColor: .textPlaceholder,
        nameFont: .textH4M16240(),
        nameColor: .mainColorsBlack,
        descriptionFont: .textBodyMR14180()
    )
}

private extension NavigationBar {
    
    init(
        _ info: ControlPanelState.NavigationBarInfo,
        _ config: NavigationBarConfig = .default
    ) {
        self.init(
            backAction: info.action,
            title: info.title,
            subtitle: info.subtitle,
            config: config)
    }
}
