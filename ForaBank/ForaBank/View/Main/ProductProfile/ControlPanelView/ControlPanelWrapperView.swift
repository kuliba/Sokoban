//
//  ControlPanelWrapperView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
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
        
        ControlPanelView(
            items: viewModel.state.buttons,
            event: { viewModel.event(.controlButtonEvent($0)) }
            )
        .alert(
            item: viewModel.state.alert,
            content: Alert.init(with:)
        )
    }
}

extension ControlPanelWrapperView {
    
    typealias ViewModel = ControlPanelViewModel
    typealias Config = ControlPanelView.Config
}
