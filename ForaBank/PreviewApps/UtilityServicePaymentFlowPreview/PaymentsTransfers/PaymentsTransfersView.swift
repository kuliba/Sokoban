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
        
        Button("Utility", action: viewModel.openUtilityPayment)
            .navigationDestination(
                item: .init(
                    get: { viewModel.state.route.destination },
                    set: { if $0 == nil { viewModel.resetDestination() }}
                ),
                content: destinationView
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
            
        case let .utilityPrepayment(utilityPrepayment):
            utilityPrepaymentView(utilityPrepayment)
                .navigationTitle("Utility Prepayment View")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func utilityPrepaymentView(
        _ utilityPrepayment: UtilityPrepayment
    ) -> some View {
        
        UtilityPrepaymentWrapperView(
            viewModel: utilityPrepayment.viewModel,
            flowEvent: { viewModel.event(.utilityFlow(.prepayment($0.flowEvent))) },
            config: config
        )
        .navigationDestination(
            item: .init(
                get: { utilityPrepayment.destination },
                set: { if $0 == nil { viewModel.event(.utilityFlow(.prepayment(.dismissDestination))) }}
            ),
            content: utilityPrepaymentDestinationView
        )
    }
    
    @ViewBuilder
    private func utilityPrepaymentDestinationView(
        _ destination: UtilityPrepayment.Destination
    ) -> some View {
        
        switch destination {
        case let .operatorFailure(`operator`):
            Text("TBD: Operator Failure view for \(`operator`) with Pay by Instructions Button (!!!)")
            
        case .payByInstructions:
            Text("Pay by Instructions")
            
        case let .payment(response):
            Text("TBD: Payment with \(response)")
            
        case let .serviceFailure(serviceFailure):
            Text("TBD: Alerts for \(serviceFailure) with OK that resets destination")
            
        case let .servicePicker(servicePickerState):
            servicePicker(servicePickerState)
                .navigationTitle(String(describing: servicePickerState.operator))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func servicePicker(
        _ servicePickerState: PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination.ServicePickerState
    ) -> some View {
        
        List {
            ForEach(servicePickerState.services.elements) { service in
                
                Button(String(service.id.prefix(24))) {
                    
                    viewModel.event(.utilityFlow(.prepayment(.select(.service(
                        service,
                        for: servicePickerState.`operator`
                    )))))
                }
            }
        }
        .navigationDestination(
            item: .init(
                get: { servicePickerState.destination },
                set: { if $0 == nil { viewModel.event(.utilityFlow(.prepayment(.dismissServicesDestination))) }}
            ),
            content: servicesDestinationView
        )
    }
    
    @ViewBuilder
    private func servicesDestinationView(
        destination: PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination.ServicePickerState.Destination
    ) -> some View {
        
        switch destination {
        case let .payment(response):
            Text("TBD: Payment with \(response)")
        }
    }
}

extension PaymentsTransfersView {
    
    typealias UtilityPrepayment = PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment
    
    typealias Config = UtilityPrepaymentWrapperView.Config
    typealias Destination = ViewModel.State.Route.Destination
    typealias ViewModel = PaymentsTransfersViewModel
}

extension PaymentsTransfersViewModel.State.Route.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payByInstructions:
            return .payByInstructions
            
        case let .utilityPrepayment(utilityPrepayment):
            return .utilityFlow(ObjectIdentifier(utilityPrepayment.viewModel))
        }
    }
    
    enum ID: Hashable {
        
        case payByInstructions
        case utilityFlow(ObjectIdentifier)
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .operatorFailure(`operator`):
            return .operatorFailure(`operator`.id)
            
        case .payByInstructions:
            return .payByInstructions
            
        case .payment:
            return .payment
            
        case let .serviceFailure(serviceFailure):
            return  .serviceFailure(serviceFailure)
            
        case let .servicePicker(services):
            return .services(for: services.`operator`.id)
        }
    }
    
    enum ID: Hashable {
        
        case operatorFailure(Operator.ID)
        case payByInstructions
        case payment
        case serviceFailure(ServiceFailure)
        case services(for: Operator.ID)
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination.ServicePickerState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payment: return .payment
        }
    }
    
    enum ID: Hashable {
        
        case payment
    }
}

private extension UtilityPrepaymentFlowEvent {
    
    var flowEvent: PaymentsTransfersEvent.UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent {
        
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
