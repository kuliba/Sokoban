//
//  PaymentsTransfersView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI
import UIPrimitives

struct PaymentsTransfersView: View {
    
    @StateObject private var viewModel: ViewModel
    private let config: Config
    
    init(
        viewModel: ViewModel,
        config: Config
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.config = config
    }
    
    var body: some View {
        
        Button("Utility", action: viewModel.startUtilityPaymentProcess)
            .navigationDestination(
                destination: viewModel.state.route.destination,
                dismissDestination: viewModel.dismissDestination,
                content: destinationView
            )
            .fullScreenCover(
                cover: viewModel.state.route.modal,
                dismissFullScreenCover: { viewModel.event(.dismissFullScreenCover) },
                content: { modal in
                    
#warning("extract to helper")
                    switch modal {
                    case let .paymentCancelled(expired: expired):
                        VStack(spacing: 32) {
                            
                            Text("Payment cancelled!")
                                .foregroundColor(.red)
                                .frame(maxHeight: .infinity)
                            
                            if expired {
                                
                                Text("time expired")
                            }
                            
                            Divider()
                            
                            Button("Go to main", action: { viewModel.event(.goToMain) })
                        }
                    }
                }
            )
    }
    
    @ViewBuilder
    private func destinationView(
        destination: Destination
    ) -> some View {
        
        switch destination {
        case .payByInstructions:
            Text("TBD: Pay by Instructions")
                .navigationTitle("Pay by Instructions")
                .navigationBarTitleDisplayMode(.inline)
            
        case let .utilityPayment(utilityPrepayment):
            utilityPrepaymentView(
                state: utilityPrepayment,
                event: { viewModel.event(.utilityFlow($0)) }
            )
            .navigationTitle("Utility Prepayment View")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func utilityPrepaymentView(
        state: UtilityPaymentFlowState,
        event: @escaping (UtilityPaymentFlowEvent) -> ()
    ) -> some View {
        
         UtilityPrepaymentFlowView(
            state: state,
            event: { event(.prepayment($0)) },
            content: {
                
                UtilityPrepaymentWrapperView(
                    viewModel: state.viewModel,
                    flowEvent: { event(.prepayment($0.flowEvent)) },
                    config: config
                )
            },
            destinationView: {
                
                utilityPrepaymentDestinationView(state: $0, event: event)
            }
         )
    }
    
    private func utilityPrepaymentDestinationView(
        state: UtilityPaymentFlowState.Destination,
        event: @escaping (UtilityPaymentFlowEvent) -> Void
    ) -> some View {
        
        UtilityPrepaymentDestinationView(
            state: state,
            event: event,
            factory: .init(
                makeOperatorFailureView: operatorFailureView,
                makePaymentFlowView: paymentFlowView,
                makeServicePicker: { servicePicker(state: $0, event: event) }
            )
        )
    }
    
#warning("multiple closures could be encapsulated into one `event: (Event) -> Void closure`")
    #warning("move to factory")
    private func operatorFailureView(
        _ operatorFailure: OperatorFailure,
        payByInstructions: @escaping () -> Void,
        dismissDestination: @escaping () -> Void
    ) -> some View {
        
        VStack(spacing: 32) {
            
            Text("TBD: Operator Failure view for \(operatorFailure.operator)")
            
            Button("Pay by Instructions", action: payByInstructions)
        }
        .navigationDestination(
            destination: operatorFailure.destination,
            dismissDestination: dismissDestination,
            content: operatorFailureDestinationView
        )
    }
    
    @ViewBuilder
    private func operatorFailureDestinationView(
        destination: OperatorFailure.Destination
    ) -> some View {
        
        Text("TBD: Pay by Instructions (OperatorFailure.Destination)")
    }
    private func paymentFlowView(
        state: PaymentFlowState,
        event: @escaping (UtilityServicePaymentFlowEvent) -> Void
    ) -> some View {
        
        PaymentFlowView(state: state, event: event) {
            
            PaymentFlowMockView(viewModel: state.viewModel)
        }
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func servicePicker(
        state: ServicePickerState,
        event: @escaping (UtilityPaymentFlowEvent) -> Void
    ) -> some View {
        
        List {
            ForEach(state.services.elements) { service in
                
                Button(String(service.id.prefix(24))) {
                    
                    event(.prepayment(.select(.service(
                        service,
                        for: state.`operator`
                    ))))
                }
            }
        }
        .navigationDestination(
            destination: state.destination,
            dismissDestination: { event(.prepayment(.dismissServicesDestination)) },
            content: servicesDestinationView
        )
        .alert(
            item: state.alert,
            content: servicePickerAlert(event: { event(.servicePicker($0)) })
        )
        .navigationTitle(String(describing: state.operator))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func servicesDestinationView(
        destination: ServicePickerState.Destination
    ) -> some View {
        
        switch destination {
        case let .payment(response):
            Text("TBD: Payment with \(response)")
        }
    }
    
    private func servicePickerAlert(
        event: @escaping (UtilityPaymentFlowEvent.ServicePickerFlowEvent) -> Void
    ) -> (ServicePickerState.Alert) -> Alert {
        
        return { alert in
            
            switch alert {
            case let .serviceFailure(serviceFailure):
                return serviceFailure.alert(
                    event: event,
                    map: {
                        switch $0 {
                        case .dismissAlert: return .dismissAlert
                        }
                    }
                )
            }
        }
    }
}

extension PaymentsTransfersView {
    
    typealias OperatorFailure = UtilityPaymentFlowState.Destination.OperatorFailure
    typealias ServicePickerState = UtilityPaymentFlowState.Destination.ServicePickerState
    
    typealias Config = UtilityPrepaymentWrapperView.Config
    typealias Destination = ViewModel.State.Route.Destination
    typealias ViewModel = PaymentsTransfersViewModel
}

extension PaymentsTransfersViewModel.State.Route.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payByInstructions:
            return .payByInstructions
            
        case let .utilityPayment(utilityPrepayment):
            return .utilityFlow(ObjectIdentifier(utilityPrepayment.viewModel))
        }
    }
    
    enum ID: Hashable {
        
        case payByInstructions
        case utilityFlow(ObjectIdentifier)
    }
}

extension PaymentsTransfersViewModel.State.Route.Modal: Identifiable {
    
    var id: ID {
        
        switch self {
        case .paymentCancelled:
            return .paymentCancelled
        }
    }
    
    enum ID: Hashable {
        
        case paymentCancelled
    }
}

extension UtilityPaymentFlowState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .operatorFailure(operatorFailure):
            return .operatorFailure(operatorFailure.operator.id)
            
        case .payByInstructions:
            return .payByInstructions
            
        case .payment:
            return .payment
            
        case let .servicePicker(services):
            return .services(for: services.`operator`.id)
        }
    }
    
    enum ID: Hashable {
        
        case operatorFailure(Operator.ID)
        case payByInstructions
        case payment
        case services(for: Operator.ID)
    }
}

extension UtilityPaymentFlowState.Alert: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .serviceFailure(serviceFailure):
            return  .serviceFailure(serviceFailure)
        }
    }
    
    enum ID: Hashable {
        
        case serviceFailure(ServiceFailure)
    }
}

extension UtilityPaymentFlowState.Destination.OperatorFailure.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payByInstructions: return .payByInstructions
        }
    }
    
    enum ID: Hashable {
        
        case payByInstructions
    }
}

extension UtilityPaymentFlowState.Destination.ServicePickerState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payment: return .payment
        }
    }
    
    enum ID: Hashable {
        
        case payment
    }
}

extension UtilityPaymentFlowState.Destination.ServicePickerState.Alert: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .serviceFailure(serviceFailure):
            return  .serviceFailure(serviceFailure)
        }
    }
    
    enum ID: Hashable {
        
        case serviceFailure(ServiceFailure)
    }
}

extension PaymentFlowState.Alert: Identifiable {
    
    var id: ID {
        
        switch self {
        case .terminalError: return  .terminalError
        }
    }
    
    enum ID: Hashable {
        
        case terminalError
    }
}

extension PaymentFlowState.Modal: Identifiable {
    
    var id: ID {
        
        switch self {
        case .fraud: return  .fraud
        }
    }
    
    enum ID: Hashable {
        
        case fraud
    }
}

private extension ServiceFailure {
    
    func alert<Event>(
        event: @escaping (Event) -> Void,
        map: @escaping (ServiceFailureEvent) -> Event
    ) -> Alert {
        
        self.alert(event: { event(map($0)) })
    }
    
    enum ServiceFailureEvent {
        
        case dismissAlert
    }
    
    private func alert(
        event: @escaping (ServiceFailureEvent) -> Void
    ) -> Alert {
        
        switch self {
        case .connectivityError:
            let model = alertModelOf(title: "Error!", message: "alert message")
            return .init(with: model, event: event)
            
        case let .serverError(message):
            let model = alertModelOf(title: "Error!", message: message)
            return .init(with: model, event: event)
        }
    }
    
    private func alertModelOf(
        title: String,
        message: String? = nil
    ) -> AlertModelOf<ServiceFailureEvent> {
        
        .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: .dismissAlert
            )
        )
    }
}

private extension UtilityPrepaymentFlowEvent {
    
    var flowEvent: UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent {
        
        switch self {
        case .addCompany:
            return .addCompany
            
        case .payByInstructions:
            return .payByInstructions
            
        case .payByInstructionsFromError:
            return .payByInstructionsFromError
            
        case let .select(select):
            switch select {
            case let .lastPayment(lastPayment):
                return .select(.lastPayment(lastPayment))
                
            case let .operator(`operator`):
                return .select(.operator(`operator`))
            }
        }
    }
}

#Preview {
    
    NavigationView {
        
        PaymentsTransfersView(viewModel: .preview(), config: .preview)
    }
}
