//
//  DetailsWrappedView.swift
//
//
//  Created by Andryusina Nataly on 08.03.2024.
//

import RxViewModel
import SwiftUI
import Tagged

public typealias DetailsViewModel = RxViewModel<DetailsState, DetailsEvent, DetailsEffect>

public struct DetailsWrappedView: View {
    
    @ObservedObject var viewModel: DetailsViewModel
    
    @State var isCheck = false

    public let config: Config
    public let title: String
    public let showCheckbox: Bool

    public init(
        viewModel: DetailsViewModel,
        config: Config,
        title: String,
        showCheckbox: Bool
    ) {
        self.viewModel = viewModel
        self.config = config
        self.title = title
        self.showCheckbox = showCheckbox
    }

    public var body: some View {
        
        DetailsView(
            items: viewModel.state.items,
            event: { viewModel.event(.itemTapped($0)) },
            config: config,
            title: title,
            showCheckbox: showCheckbox,
            isCheck: $isCheck
        )
    }
}
