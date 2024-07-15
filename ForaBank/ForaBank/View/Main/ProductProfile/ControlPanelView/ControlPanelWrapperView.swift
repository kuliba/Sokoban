//
//  ControlPanelWrapperView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 03.07.2024.
//

import SwiftUI
import RxViewModel

typealias ControlPanelViewModel = RxViewModel<ControlPanelState, ControlPanelEvent, ControlPanelEffect>

struct ControlPanelWrapperView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let config: Config
    private let getUImage: (Md5hash) -> UIImage?

    init(
        viewModel: ViewModel,
        config: Config,
        getUImage: @escaping (Md5hash) -> UIImage?
    ) {
        self.viewModel = viewModel
        self.config = config
        self.getUImage = getUImage
    }
    
    var body: some View {
        
        ZStack {
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
            .navigationBar(with: viewModel.state.navigationBarViewModel)
            
            viewModel.state.spinner.map { spinner in
                
                SpinnerView(viewModel: spinner)
                    .zIndex(.greatestFiniteMagnitude)
            }
        }
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
        }
    }
}

extension ControlPanelWrapperView {
    
    typealias ViewModel = ControlPanelViewModel
    typealias Config = ControlPanelViewConfig
}
