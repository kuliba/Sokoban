//
//  ThreeButtonsWrappedView.swift
//
//
//  Created by Andryusina Nataly on 31.01.2024.
//

import RxViewModel
import SwiftUI
import Tagged

typealias CardGuardianViewModel =  RxViewModel<CardGuardianState, CardGuardian.ButtonTapped, Never>

struct ThreeButtonsWrappedView: View {
    
    @ObservedObject var viewModel: CardGuardianViewModel
    let config: CardGuardian.Config

    var body: some View {
        
        ThreeButtonsView(
            buttons: viewModel.state.buttons,
            event: viewModel.event,
            config: config
        )
    }
}
