//
//  ControlPanelView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 27.06.2024.
//

import SwiftUI
import LandingUIComponent

struct ControlPanelView: View {
    
    let items: [ControlPanelButtonDetails]
    let landingViewModel: LandingWrapperViewModel?
    let event: (Event) -> Void
    let config: ControlPanelView.Config = .default
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                ForEach(items, id: \.title, content: view)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, config.paddings.horizontal)

            landingViewModel.map {
                LandingWrapperView(viewModel: $0)
            }
            .padding(.top, config.paddings.top)
        }
        .padding(.top, config.paddings.top)
    }
    
    private func view(details: ControlPanelButtonDetails) -> some View {
        
        HorizontalPanelButton(
            details: details,
            event: { event(details.event) },
            config: config)
    }
}

extension ControlPanelView {
    
    typealias Event = ControlButtonEvent
}
