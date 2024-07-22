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
    let event: (Event) -> Void
    let config: ControlPanelViewConfig
    let destinationView: (Destination) -> DestinationView

    var body: some View {
        
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                ForEach(state.buttons, id: \.title, content: view)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, config.paddings.horizontal)

            if let viewModel = state.landingWrapperViewModel {
                LandingWrapperView(viewModel: viewModel)
                    .padding(.top, config.paddings.top)
            } else {
                if state.status != .failure {
                    placeHolderView()
                        .padding(.top, config.paddings.top)
                } else { Spacer() }
            }
        }
        .navigationDestination(
            destination: state.destination,
            dismissDestination: { event(.dismiss(.destination)) },
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
    
    private func placeHolderView() -> some View {
                
        VStack(spacing: config.placeHolder.padding) {
            
            placeHolderItems()
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                placeHolderItems(width: config.placeHolder.bannerWidth)
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
        
    private func placeHolderItems(width: CGFloat = -1) -> some View {
        
        HStack(spacing: config.placeHolder.padding/2) {
            
            ForEach((1...2), id: \.self) { _ in
                
                placeHolderItem(width: width)
            }
        }
        .padding(.horizontal, config.placeHolder.padding)
        .frame(height: config.placeHolder.height)
    }
    
    private func placeHolderItem(width: CGFloat = -1) -> some View {
        
        RoundedRectangle(cornerRadius: config.placeHolder.cornerRadius)
            .foregroundColor(.bgIconGrayLightest)
            .shimmering()
            .modifier(WidthModifier(width: width))
    }
    
    private struct WidthModifier : ViewModifier {
        
        let width : CGFloat
        
        @ViewBuilder 
        func body(content: Content) -> some View {
            if width > 0 {
                content.frame(width: width)
            } else {
                content
            }
        }
    }

}

extension ControlPanelView {
    
    typealias Event = ControlPanelEvent
    typealias State = ControlPanelState
    typealias Destination = ControlPanelState.Destination
}

