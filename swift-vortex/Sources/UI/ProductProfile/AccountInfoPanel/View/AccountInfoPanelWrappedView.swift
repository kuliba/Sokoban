//
//  AccountInfoPanelWrappedView.swift
//
//
//  Created by Andryusina Nataly on 04.03.2024.
//

import RxViewModel
import SwiftUI
import Tagged

public typealias AccountInfoPanelViewModel = RxViewModel<AccountInfoPanelState, AccountInfoPanelEvent, AccountInfoPanelEffect>

public struct AccountInfoPanelWrappedView: View {
    
    @ObservedObject var viewModel: AccountInfoPanelViewModel
    public let config: Config
    
    public init(
        viewModel: AccountInfoPanelViewModel,
        config: Config
    ) {
        self.viewModel = viewModel
        self.config = config
    }

    public var body: some View {
        
        AccountInfoPanelView(
            buttons: viewModel.state.buttons,
            event: { viewModel.event(.buttonTapped($0)) },
            config: config
        )
    }
}
