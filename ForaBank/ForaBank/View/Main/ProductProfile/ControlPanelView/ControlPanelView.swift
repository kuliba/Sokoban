//
//  ControlPanelView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 27.06.2024.
//

import SwiftUI
import LandingUIComponent

struct ControlPanelView<DestinationView>: View 
where DestinationView: View {
    
    let state: State
    let landingViewModel: LandingWrapperViewModel?
    let event: (Event) -> Void
    let config: ControlPanelViewConfig = .default
    let destinationView: (Destination) -> DestinationView

    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                ForEach(state.buttons, id: \.title, content: view)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, config.paddings.horizontal)

            landingViewModel.map {
                LandingWrapperView(viewModel: $0)
            }
            .padding(.top, config.paddings.top)
        }
        .navigationDestination(
            destination: state.destination,
            dismissDestination: { event(.dismissDestination) },
            content: destinationView
        )
        .padding(.top, config.paddings.top)
    }
    
    private func view(details: ControlPanelButtonDetails) -> some View {
        
        HorizontalPanelButton(
            details: details,
            event: { event(.controlButtonEvent(details.event)) },
            config: config)
    }
}

extension ControlPanelView {
    
    typealias Event = ControlPanelEvent
    typealias State = ControlPanelState
    typealias Destination = ControlPanelState.Destination
}

