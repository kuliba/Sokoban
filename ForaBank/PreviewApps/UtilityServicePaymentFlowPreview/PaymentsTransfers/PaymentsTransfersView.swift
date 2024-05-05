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
        
        content()
            .navigationDestination(
                destination: viewModel.state.route.destination,
                dismissDestination: viewModel.dismissDestination,
                content: { destination in
                    
                    destinationView(
                        destination: destination,
                        event: { viewModel.event(.utilityFlow($0)) }
                    )
                }
            )
            .fullScreenCover(
                cover: viewModel.state.route.modal,
                dismissFullScreenCover: { viewModel.event(.dismissFullScreenCover) },
                content: { modal in
                    
                    fullScreenCoverView(
                        modal: modal,
                        event: { viewModel.event(.goToMain) }
                    )
                }
            )
    }
}

extension PaymentsTransfersView {
    
    typealias OperatorFailure = UtilityPaymentFlowState.Destination.OperatorFailureFlowState
    typealias ServicePickerState = UtilityPaymentFlowState.Destination.ServicePickerFlowState
    
    typealias Config = UtilityPrepaymentWrapperView.Config
    typealias Destination = ViewModel.State.Route.Destination
    typealias ViewModel = PaymentsTransfersViewModel
}

private extension PaymentsTransfersView {
    
    func content() -> some View {
        
        Button("Utility", action: viewModel.startUtilityPaymentProcess)
    }
    
    @ViewBuilder
    func destinationView(
        destination: Destination,
        event: @escaping (UtilityPaymentFlowEvent) -> Void
    ) -> some View {
        
        switch destination {
        case .payByInstructions:
            Text("TBD: Pay by Instructions")
                .navigationTitle("Pay by Instructions")
                .navigationBarTitleDisplayMode(.inline)
            
        case let .utilityPayment(utilityPrepayment):
            utilityPrepaymentView(state: utilityPrepayment, event: event)
                .navigationTitle("Utility Prepayment View")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func utilityPrepaymentView(
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
    
    @ViewBuilder
    func utilityPrepaymentDestinationView(
        state: UtilityPaymentFlowState.Destination,
        event: @escaping (UtilityPaymentFlowEvent) -> Void
    ) -> some View {
        
        switch state {
        case let .operatorFailure(operatorFailure):
            operatorFailureView(
                operatorFailure: operatorFailure,
                payByInstructions: { event(.prepayment(.payByInstructions)) },
                dismissDestination: { event(.prepayment(.dismissOperatorFailureDestination)) }
            )
            .navigationTitle(String(describing: operatorFailure.content))
            .navigationBarTitleDisplayMode(.inline)
            
            
        case .payByInstructions:
            Text("Pay by Instructions")
                .navigationTitle("Pay by Instructions")
                .navigationBarTitleDisplayMode(.inline)
            
        case let .payment(state):
            paymentFlowView(state: state, event: { event(.payment($0)) })
            
        case let .servicePicker(state):
            servicePicker(state: state, event: event)
        }
    }
    
    func operatorFailureView(
        operatorFailure: UtilityPaymentFlowState.Destination.OperatorFailureFlowState,
        payByInstructions: @escaping () -> Void,
        dismissDestination: @escaping () -> Void
    ) -> some View {
        
        OperatorFailureFlowView(
            state: operatorFailure,
            event: dismissDestination,
            content: {
                
                OperatorFailureView(
                    state: operatorFailure.content,
                    event: payByInstructions
                )
            },
            destinationView: operatorFailureDestinationView
        )
    }
    
    @ViewBuilder
    func operatorFailureDestinationView(
        destination: OperatorFailure.Destination
    ) -> some View {
        
        Text("TBD: Pay by Instructions (OperatorFailure.Destination)")
            .navigationTitle("Pay by Instructions")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    func paymentFlowView(
        state: PaymentFlowState,
        event: @escaping (UtilityServicePaymentFlowEvent) -> Void
    ) -> some View {
        
        PaymentFlowView(state: state, event: event) {
            
            PaymentFlowMockView(viewModel: state.viewModel)
        }
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func servicePicker(
        state: ServicePickerState,
        event: @escaping (UtilityPaymentFlowEvent) -> Void
    ) -> some View {
        
        ServicePickerFlowView(
            state: state,
            event: event,
            content: {
                
                ServicePickerView(
                    state: state.content,
                    event: { event(.prepayment(.select($0))) }
                )
            },
            destinationView: servicesDestinationView
        )
        .navigationTitle(String(describing: state.content))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func servicesDestinationView(
        destination: ServicePickerState.Destination
    ) -> some View {
        
        switch destination {
        case let .payment(response):
            Text("TBD: Payment with \(response)")
        }
    }
    
    @ViewBuilder
    func fullScreenCoverView(
        modal: PaymentsTransfersViewModel.State.Route.Modal,
        event: @escaping () -> Void
    ) -> some View {
        
        switch modal {
        case let .paymentCancelled(expired: expired):
            PaymentCancelledView(state: expired, event: event)
        }
    }
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
