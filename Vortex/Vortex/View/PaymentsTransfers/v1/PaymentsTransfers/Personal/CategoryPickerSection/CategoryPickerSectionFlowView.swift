//
//  CategoryPickerSectionFlowView.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import SwiftUI
import UIPrimitives

struct CategoryPickerSectionFlowView<ContentView, DestinationView>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        factory.makeContentView()
            .alert(
                item: state.failure,
                content: factory.makeAlert
            )
            .navigationDestination(
                destination: state.destination,
                content: factory.makeDestinationView
            )
    }
}

extension CategoryPickerSectionFlowView {
    
    typealias FlowDomain = CategoryPickerSectionDomain.FlowDomain
    typealias State = FlowDomain.State
    typealias Event = FlowDomain.Event
    typealias Factory = CategoryPickerSectionFlowViewFactory<ContentView, DestinationView>
}

// MARK: - UI mapping

private extension CategoryPickerSectionDomain.FlowDomain.State {
    
    var destination: SelectedCategoryNavigation.PaymentFlow? {
        
        navigation?.destination
    }
    
    var failure: SelectedCategoryFailure? {
        
        navigation?.failure
    }
}

// MARK: - UI mapping

private extension SelectedCategoryNavigation {
    
    var destination: SelectedCategoryNavigation.PaymentFlow? {
        
        switch self {
        case .failure:
            return nil
            
        case let .paymentFlow(paymentFlow):
            return paymentFlow
        }
    }
    
    var failure: SelectedCategoryFailure? {
        
        switch self {
        case let .failure(failure):
            return failure
            
        case .paymentFlow:
            return nil
        }
    }
}

extension SelectedCategoryNavigation.PaymentFlow: Identifiable {}
