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
                items: viewModel.state.buttons,
                landingViewModel: viewModel.state.landingWrapperViewModel,
                event: { viewModel.event(.controlButtonEvent($0)) }
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
}

extension ControlPanelWrapperView {
    
    typealias ViewModel = ControlPanelViewModel
    typealias Config = ControlPanelView.Config
}
