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
    
    var body: some View {
        
        factory.makeContentView()
            .alert(
                item: state.failure,
                content: factory.makeAlert
            )
            .fullScreenCover(
                cover: state.fullScreenCover,
                // full screen cover should not be dismissed by SwiftUI, only programmatically
                dismissFullScreenCover: {},
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
    
    typealias State = CategoryPickerSection.FlowDomain.State
    typealias Event = CategoryPickerSection.FlowDomain.Event
    typealias Factory = CategoryPickerSectionFlowViewFactory<ContentView, DestinationView, FullScreenCoverView>
}

// MARK: - UI mapping

private extension CategoryPickerSection.FlowDomain.State {
    
    var destination: CategoryPickerSectionNavigation.Destination? {
        
        navigation?.destination
    }
    
    var failure: SelectedCategoryFailure? {
        
        navigation?.failure
    }
    
    var fullScreenCover: CategoryPickerSectionNavigation.FullScreenCover? {
        
        navigation?.fullScreenCover
    }
}
