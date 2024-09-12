//
//  BannerPickerSectionFlowView.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

import PayHub

import SwiftUI

public struct BannerPickerSectionFlowView<ContentView, DestinationView, Banner, SelectedBanner, BannerList>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
    
    public var body: some View {
        
        factory.makeContentView()
            .navigationDestination(
                destination: state.destination,
                dismissDestination: { event(.dismiss) },
                content: factory.makeDestinationView
            )
    }
}

public extension BannerPickerSectionFlowView {
    
    typealias State = BannerPickerSectionFlowState<SelectedBanner, BannerList>
    typealias Event = BannerPickerSectionFlowEvent<Banner, SelectedBanner, BannerList>
    typealias Factory = BannerPickerSectionFlowViewFactory<ContentView, DestinationView, SelectedBanner, BannerList>
}

extension BannerPickerSectionDestination: Identifiable {
    
    public var id: ID {
        
        switch self {
        case .banner: return .banner
        case .list:   return .list
        }
    }
    
    public enum ID: Hashable {
        
        case banner, list
    }
}

#warning("move to module")
private extension View {
    
    func navigationDestination<Destination: Identifiable, Content: View>(
        destination: Destination?,
        dismissDestination: @escaping () -> Void,
        @ViewBuilder content: @escaping (Destination) -> Content
    ) -> some View {
        
        navigationDestination(
            item: .init(
                get: { destination },
                set: { if $0 == nil { dismissDestination() }}
            ),
            content: content
        )
    }
}
