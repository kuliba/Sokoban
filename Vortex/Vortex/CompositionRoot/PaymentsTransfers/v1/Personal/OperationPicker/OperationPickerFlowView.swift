//
//  OperationPickerFlowView.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import SwiftUI

struct OperationPickerFlowView<ContentView, DestinationView>: View
where ContentView: View,
      DestinationView: View {
    
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
        
        factory.makeContent()
            .navigationDestination(
                destination: state.navigation?.destination,
                dismiss: { event(.dismiss) },
                content: factory.makeDestination
            )
    }
}

extension OperationPickerFlowView {
    
    typealias Domain = OperationPickerDomain
    typealias FlowDomain = Domain.FlowDomain
    
    typealias State = FlowDomain.State
    typealias Event = FlowDomain.Event
    typealias Factory = OperationPickerFlowViewFactory<ContentView, DestinationView>
}

// MARK: - UI Mapping

extension OperationPickerDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case .exchangeFailure:
            return .exchangeFailure
            
        case let .exchange(exchange):
            return .exchange(exchange)
            
        case let .latest(latest):
            return .latest(latest)
            
        case .outside, .templates:
            return nil
        }
    }
    
    enum Destination {
        
        case exchangeFailure
        case exchange(CurrencyWalletViewModel)
        case latest(PaymentsDomain.Navigation)
    }
}

extension OperationPickerDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .exchangeFailure:
            return .exchangeFailure
            
        case let .exchange(exchange):
            return .exchange(.init(exchange))
            
        case let .latest(latest):
            switch latest {
            case let .anywayPayment(anywayPayment):
                return .latest(.anywayPayment(.init(anywayPayment.model)))
            
            case let .meToMe(meToMe):
                return .latest(.meToMe(.init(meToMe)))
            
            case let .payments(payments):
                return .latest(.payments(.init(payments)))
            }
        }
    }
    
    enum ID: Hashable {
        
        case exchangeFailure
        case exchange(ObjectIdentifier)
        case latest(Latest)
        
        enum Latest: Hashable {
            
            case anywayPayment(ObjectIdentifier)
            case meToMe(ObjectIdentifier)
            case payments(ObjectIdentifier)
        }
    }
}
