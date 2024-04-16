//
//  ThreeButtonsWrappedView.swift
//
//
//  Created by Andryusina Nataly on 31.01.2024.
//

import RxViewModel
import SwiftUI
import Tagged

public typealias CardGuardianViewModel = RxViewModel<CardGuardianState, CardGuardianEvent, CardGuardianEffect>

public struct ThreeButtonsWrappedView: View {
    
    @ObservedObject var viewModel: CardGuardianViewModel
    public let config: CardGuardian.Config
    
    public init(
        viewModel: CardGuardianViewModel,
        config: CardGuardian.Config
    ) {
        self.viewModel = viewModel
        self.config = config
    }

    public var body: some View {
        
        ThreeButtonsView(
            buttons: viewModel.state.buttons,
            event: { viewModel.event(.buttonTapped($0)) },
            config: config
        )
    }
}
