//
//  CategoryPickerSectionFlowView.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import SwiftUI

struct CategoryPickerSectionFlowView<ContentView, DestinationView, FullScreenCoverView>: View
where ContentView: View,
      DestinationView: View,
      FullScreenCoverView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
    
    var body: some View {
        
        factory.makeContentView()
            .alert(
                item: state.failure,
                content: factory.makeAlert
            )
            .fullScreenCover(
                cover: state.fullScreenCover,
                dismissFullScreenCover: { event(.dismiss) },
                content: factory.makeFullScreenCoverView
            )
            .navigationDestination(
                destination: state.destination,
                dismissDestination: { event(.dismiss) },
                content: factory.makeDestinationView
            )
    }
}

extension CategoryPickerSectionFlowView {
    
    typealias State = CategoryPickerSection.FlowDomain.FlowState
    typealias Event = CategoryPickerSection.FlowDomain.FlowEvent
    typealias Factory = CategoryPickerSectionFlowViewFactory<ContentView, DestinationView, FullScreenCoverView>
}

private extension CategoryPickerSection.FlowDomain.FlowState {
    
    var destination: CategoryPickerSection.Destination? {
        
        guard case let .destination(destination) = navigation
        else { return nil }
        
        return destination
    }
    
    var failure: SelectedCategoryFailure? {
        
        guard case let .failure(failure) = navigation
        else { return nil }
        
        return failure
    }
    
    var fullScreenCover: CategoryPickerSection.FullScreenCover? {
        
        guard case let .fullScreenCover(fullScreenCover) = navigation
        else { return nil }
        
        return fullScreenCover
    }
}
