//
//  PaymentProviderPickerFlowView.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import PayHub
import SwiftUI

struct PaymentProviderPickerFlowView<ContentView, DestinationView>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let contentView: () -> ContentView
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        contentView()
            .alert(item: backendFailure, content: alert)
            .navigationDestination(
                destination: destination,
                dismiss: { event(.dismiss) },
                content: destinationView
            )
    }
}

extension PaymentProviderPickerFlowView {
    
    typealias Domain = PaymentProviderPickerDomain.FlowDomain
    typealias State = Domain.State
    typealias Event = Domain.Event
    typealias Destination = PaymentProviderPickerDomain.Destination
}

private extension PaymentProviderPickerFlowView {
    
    var backendFailure: BackendFailure? {
        
        guard case let .alert(backendFailure) = state.navigation
        else { return nil }
        
        return backendFailure
    }
    
    var destination: Destination? {
        
        guard case let .destination(destination) = state.navigation
        else { return nil }
        
        return destination
    }
    
    func alert(
        backendFailure: BackendFailure
    ) -> Alert {
        
        return backendFailure.alert { event(.select(.outside(.payments))) }
    }
}

extension BackendFailure: Identifiable {
    
    public var id: String { message + String(describing: source) }
}

extension BackendFailure {
    
    func alert(
        action: @escaping () -> Void
    ) -> SwiftUI.Alert {
        
        return .init(title: Text(title), message: Text(message), dismissButton: .default(Text("OK"), action: action))
    }
    
    private var title: String {
        
        switch source {
        case .connectivity: return ""
        case .server:       return "Ошибка"
        }
    }
}

extension PaymentProviderPickerDomain.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
            
        case .backendFailure:  return .backendFailure
        case .detailPayment:   return .detailPayment
        case .payment:         return .payment
        case .servicePicker:   return .servicePicker
        case .servicesFailure: return .servicesFailure
        }
    }
    
    enum ID: Hashable {
        
        case backendFailure
        case detailPayment
        case payment
        case servicePicker
        case servicesFailure
    }
}
