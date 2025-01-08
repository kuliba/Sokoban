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
        
        ZStack {
            
            contentView()
            
            fixedFrameTinyClear()
                .alert(item: backendFailure, content: alert)
            //  .id(backendFailure?.id)
            
            fixedFrameTinyClear()
                .navigationDestination(
                    destination: destination,
                    // dismiss: { event(.dismiss) },
                    content: destinationView
                )
                .id(destination?.id) // hack to prevent double view redraw, downside: not smooth animation
        }
    }
}

extension PaymentProviderPickerFlowView {
    
    typealias Domain = PaymentProviderPickerDomain.FlowDomain
    typealias State = PaymentProviderPickerDomain.Navigation?
    typealias Event = Domain.Event
    typealias Destination = PaymentProviderPickerDomain.Destination
}

private extension PaymentProviderPickerFlowView {
    
    func fixedFrameTinyClear() -> some View {
        
        Color.clear.frame(width: 1, height: 1)
    }
}

private extension PaymentProviderPickerFlowView {
    
    var backendFailure: BackendFailure? {
        
        guard case let .alert(backendFailure) = state
        else { return nil }
        
        return backendFailure
    }
    
    func alert(
        backendFailure: BackendFailure
    ) -> Alert {
        
        return backendFailure.alert { event(.select(.outside(.payments))) }
    }
    
    var destination: Destination? {
        
        guard case let .destination(destination) = state
        else { return nil }
        
        return destination
    }
}

extension BackendFailure: Identifiable {
    
    public var id: String { message + String(describing: source) }
}

extension BackendFailure {
    
    func alert(
        action: @escaping () -> Void
    ) -> SwiftUI.Alert {
        
        return .init(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("OK"), action: action)
        )
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
            
        case .detailPayment:   return .detailPayment
        case .payment:         return .payment
        case .servicePicker:   return .servicePicker
        case .servicesFailure: return .servicesFailure
        }
    }
    
    enum ID: Hashable {
        
        case detailPayment
        case payment
        case servicePicker
        case servicesFailure
    }
}
