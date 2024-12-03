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
    
    typealias State = CategoryPickerSectionDomain.FlowDomain.State
    typealias Event = CategoryPickerSectionDomain.FlowDomain.Event
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
            
        case .qrNavigation:
            return nil
        }
    }
    
    var failure: SelectedCategoryFailure? {
        
        switch self {
        case let .failure(failure):
            return failure
            
        case .paymentFlow:
            return nil
            
        case let .qrNavigation(qrNavigation):
            return qrNavigation.failure
        }
    }
}

extension SelectedCategoryNavigation {
    
    enum Destination {
        
        case paymentFlow(PaymentFlowDestination)
        case qrDestination(QRNavigation.Destination)
        
        typealias PaymentFlowDestination = PayHub.PaymentFlowDestination<Mobile, Standard, Tax, Transport>
    }
}

extension SelectedCategoryNavigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .paymentFlow(paymentFlow):
            return .paymentFlow(paymentFlow.id)
            
        case let .qrDestination(qrDestination):
            return .qrDestination(qrDestination.id)
        }
    }
    
    enum ID: Hashable {
        
        case paymentFlow(PaymentFlowDestinationID)
        case qrDestination(QRNavigation.Destination.ID)
    }
}
