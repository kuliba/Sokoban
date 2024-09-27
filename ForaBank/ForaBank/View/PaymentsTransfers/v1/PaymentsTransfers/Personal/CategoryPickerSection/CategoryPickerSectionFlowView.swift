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
    
    typealias State = CategoryPickerSection.FlowState
    typealias Event = CategoryPickerSection.FlowEvent
    typealias Factory = CategoryPickerSectionFlowViewFactory<ContentView, DestinationView, FullScreenCoverView>
}

private extension CategoryPickerSection.FlowState {
    
    var failure: SelectedCategoryFailure? {
        
        guard case let .failure(failure) = navigation
        else { return nil }
        
        return failure
    }
    
    var fullScreenCover: CategoryPickerSection.FullScreenCover? {
        
        guard case let .destination(.category(.qr(qr))) = navigation
        else { return nil }
        
        return .init(id: .init(), qr: qr)
    }
    
    var destination: CategoryPickerSection.Destination? {
        
        switch navigation {
        case .none, .failure:
            return .none
            
        case let .destination(destination):
            switch destination {
            case let .category(category):
                
                switch category {
                case let .mobile(mobile):
                    return .mobile(mobile)
                    
                case .qr:
                    return .none
                    
                case let .standard(standard):
                    return .standard(standard)
                    
                case let .taxAndStateServices(taxAndStateServices):
                    return .taxAndStateServices(taxAndStateServices)
                    
                case let .transport(transport):
                    return .transport(transport)
                }
                
            case let .list(list):
                return .list(list)
            }
        }
    }
}
