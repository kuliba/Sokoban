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

// MARK: - UI mapping

private extension CategoryPickerSection.FlowDomain.FlowState {
    
    var destination: CategoryPickerSectionNavigation.Destination? {
        
        switch navigation {
        case .failure, .none, .qrFlow:
            return nil
            
        case let .list(list):
            return .list(list)
            
        case let .paymentFlow(paymentFlow):
            switch paymentFlow {
            case let .mobile(mobile):
                return .mobile(mobile)
                
            case .qr:
                return nil
                
            case let .standard(standard):
                return .standard(standard)
                
            case let .taxAndStateServices(taxAndStateServices):
                return .taxAndStateServices(taxAndStateServices)
                
            case let .transport(transport):
                return .transport(transport)
            }
        }
    }
    
    var failure: SelectedCategoryFailure? {
        
        guard case let .failure(failure) = navigation else { return nil }
        
        return failure
    }
    
    var fullScreenCover: CategoryPickerSectionNavigation.FullScreenCover? {
        
        guard case let .paymentFlow(.qr(qr)) = navigation else { return nil }
        
        return .init(id: .init(), qr: qr)
    }
}

extension CategoryPickerSectionNavigation {
    
    struct FullScreenCover: Identifiable {
        
        let id: UUID
        let qr: QRModel
    }
    
    enum Destination: Identifiable {
        
        case list(CategoryListModelStub)
        case mobile(ClosePaymentsViewModelWrapper)
        case standard(StandardSelectedCategoryDestination)
        case taxAndStateServices(ClosePaymentsViewModelWrapper)
        case transport(TransportPaymentsViewModel)
        
        var id: ID {
            
            switch self {
            case .list:                return .list
            case .mobile:              return .mobile
            case .standard:            return .standard
            case .taxAndStateServices: return .taxAndStateServices
            case .transport:           return .transport
            }
        }
        
        enum ID: Hashable {
            
            case list
            case mobile
            case standard
            case taxAndStateServices
            case transport
        }
    }
}
