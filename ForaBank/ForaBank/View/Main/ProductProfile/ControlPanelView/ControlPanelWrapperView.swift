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
    
    init(viewModel: ViewModel, config: Config) {
        self.viewModel = viewModel
        self.config = config
    }
    
    var body: some View {
        
        ZStack {
            ControlPanelView(
                state: viewModel.state,
                landingViewModel: viewModel.state.landingWrapperViewModel,
                event: { viewModel.event($0) },
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
        case let .landing(viewModel):
            return AnyView(AuthProductsView(viewModel: viewModel))
            
        case let .orderSticker(view):
            
            let newView = view
                .navigationBarTitle("Оформление заявки", displayMode: .inline)
                .edgesIgnoringSafeArea(.bottom)

            return AnyView(newView)
        }
    }
}

extension ControlPanelWrapperView {
    
    typealias ViewModel = ControlPanelViewModel
    typealias Config = ControlPanelViewConfig
}
