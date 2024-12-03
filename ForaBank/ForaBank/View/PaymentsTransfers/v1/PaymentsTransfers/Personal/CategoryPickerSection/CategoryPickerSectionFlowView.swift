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
    
    var destination: SelectedCategoryNavigation.Destination? {
        
        navigation?.destination
    }
    
    var failure: SelectedCategoryFailure? {
        
        navigation?.failure
    }
}

// MARK: - UI mapping

private extension SelectedCategoryNavigation {
    
    var destination: Destination? {
        
        switch self {
        case .failure:
            return nil
            
        case let .paymentFlow(paymentFlow):
            switch paymentFlow {
            case let .mobile(mobile):
                return .paymentFlow(.mobile(mobile))
                
            case .qr:
                return nil
                
            case let .standard(standard):
                return .paymentFlow(.standard(standard))
                
            case let .taxAndStateServices(taxAndStateServices):
                return .paymentFlow(.taxAndStateServices(taxAndStateServices))
                
            case let .transport(transport):
                return .paymentFlow(.transport(transport))
            }
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

extension SelectedCategoryNavigation {
    
    enum Destination {
        
        case paymentFlow(PaymentFlowDestination)
        
        typealias PaymentFlowDestination = PayHub.PaymentFlowDestination<Mobile, Standard, Tax, Transport>
    }
}

extension SelectedCategoryNavigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .paymentFlow(paymentFlow):
            return .paymentFlow(paymentFlow.id)
        }
    }
    
    enum ID: Hashable {
        
        case paymentFlow(PaymentFlowDestinationID)
    }
}
