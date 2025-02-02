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
    
    let state: Navigation?
    let dismissAlert: () -> Void
    let contentView: () -> ContentView
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        contentView()
            .alert(item: backendFailure, content: alert)
            .fullScreenCover(cover: destination, content: destinationView)
    }
}

extension PaymentProviderPickerFlowView {
    
    typealias Navigation = PaymentProviderPickerDomain.Navigation
    typealias Destination = PaymentProviderPickerDomain.Destination
}

private extension PaymentProviderPickerFlowView {
    
    var backendFailure: BackendFailure? {
        
        switch state {
        case let .alert(backendFailure):
            return backendFailure
            
        case let .destination(.payment(.failure(.serviceFailure(serviceFailure)))):
            return .paymentServiceFailure(serviceFailure)
            
        default:
            return nil
        }
    }
    
    func alert(
        backendFailure: BackendFailure
    ) -> Alert {
        
        return backendFailure.alert(action: dismissAlert)
    }
    
    var destination: Destination? {
        
        guard case let .destination(destination) = state
        else { return nil }
        
        switch destination {
        case .payment(.failure(.serviceFailure)):
            return nil
            
        default:
            return destination
        }
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
    
    static func paymentServiceFailure(
        _ serviceFailure: ServiceFailureAlert.ServiceFailure
    ) -> Self {
        
        switch serviceFailure {
        case .connectivityError:
            return .paymentConnectivity
            
        case let .serverError(message):
            return .init(message: message, source: .server)
        }
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
        case let .detailPayment(node):
            return .detailPayment(.init(node.model))
            
        case let .payment(result):
            switch result {
            case let .failure(failure):
                switch failure {
                case let .operatorFailure(provider):
                    return .operatorFailure(provider.id)
                    
                case let .serviceFailure(serviceFailure):
                    return .serviceFailure(serviceFailure)
                }
                
            case let .success(success):
                switch success {
                case let .services(node):
                    return .services(.init(node.model))
                    
                case let .startPayment(node):
                    return .startPayment(.init(node.model))
                }
            }
            
        case let .servicePicker(servicePicker):
            return .servicePicker(.init(servicePicker))
            
        case let .servicesFailure(servicesFailure):
            return .servicesFailure(.init(servicesFailure))
        }
    }
    
    enum ID: Hashable {
        
        case detailPayment(ObjectIdentifier)
        case operatorFailure(UtilityPaymentProvider.ID)
        case serviceFailure(ServiceFailureAlert.ServiceFailure)
        case services(ObjectIdentifier)
        case startPayment(ObjectIdentifier)
        case servicePicker(ObjectIdentifier)
        case servicesFailure(ObjectIdentifier)
    }
}

// MARK: - Adapters

private extension BackendFailure {
    
    init(
        _ failure: ServiceFailureAlert.ServiceFailure,
        connectivityFailureMessage: String
    ) {
        
        switch failure {
        case .connectivityError:
            self.init(message: connectivityFailureMessage, source: .connectivity)
            
        case let .serverError(message):
            self.init(message: message, source: .server)
        }
    }
}
