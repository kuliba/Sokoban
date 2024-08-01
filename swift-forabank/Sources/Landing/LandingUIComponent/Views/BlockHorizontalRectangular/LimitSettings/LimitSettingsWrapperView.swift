//
//  LimitSettingsWrapperView.swift
//  
//
//  Created by Andryusina Nataly on 25.07.2024.
//

import SwiftUI
import RxViewModel

typealias LimitSettingsViewModel = RxViewModel<LimitSettingsState, LimitEvent, LimitEffect>

struct LimitSettingsWrapperView<InfoView>: View
where InfoView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let config: Config
    let infoView: () -> InfoView
    let makeIconView: ViewFactory.MakeIconView

    init(
        viewModel: ViewModel,
        config: Config,
        infoView: @escaping () -> InfoView,
        makeIconView: @escaping ViewFactory.MakeIconView
    ) {
        self.viewModel = viewModel
        self.config = config
        self.infoView = infoView
        self.makeIconView = makeIconView
    }
    
    var body: some View {
        
        LimitView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: config,
            infoView: infoView,
            makeIconView: makeIconView)
    }
}

extension LimitSettingsWrapperView {
    
    typealias ViewModel = LimitSettingsViewModel
    typealias Config = LimitConfig
}
