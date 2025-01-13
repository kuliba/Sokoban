//
//  TopUpCardWrappedView.swift
//  
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import RxViewModel
import SwiftUI
import Tagged

public typealias TopUpCardViewModel = RxViewModel<TopUpCardState, TopUpCardEvent, TopUpCardEffect>

public struct TopUpCardWrappedView: View {
    
    @ObservedObject var viewModel: TopUpCardViewModel
    public let config: Config
    
    public init(
        viewModel: TopUpCardViewModel,
        config: Config
    ) {
        self.viewModel = viewModel
        self.config = config
    }

    public var body: some View {
        
        TopUpCardView(
            buttons: viewModel.state.buttons,
            event: { viewModel.event(.buttonTapped($0)) },
            config: config
        )
    }
}
