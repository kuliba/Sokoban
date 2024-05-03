//
//  PaymentsTransfersView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import UIPrimitives
import SwiftUI

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
            
        case let .utilityFlow(utilityFlow):
            utilityPrepaymentView(utilityFlow)
                .navigationTitle("Utility Prepayment View")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func utilityPrepaymentView(
        _ utilityFlow: UtilityFlow
    ) -> some View {
        
        UtilityPrepaymentWrapperView(
            viewModel: utilityFlow.viewModel,
            flowEvent: { viewModel.event(.utilityFlow(.prepayment($0.flowEvent))) },
            config: config
        )
        .navigationDestination(
            item: .init(
                get: { utilityFlow.destination },
                set: { if $0 == nil { viewModel.event(.utilityFlow(.prepayment(.dismissDestination))) }}
            ),
            content: utilityFlowDestinationView
        )
    }
    
    @ViewBuilder
    private func utilityFlowDestinationView(
        _ destination: UtilityFlow.Destination
    ) -> some View {
        
        switch destination {
        case let .operatorFailure(`operator`):
            Text("TBD: Operator Failure view for \(`operator`) with Pay by Instructions Button (!!!)")
            
        case .payByInstructions:
            Text("Pay by Instructions")
            
        case .payment:
            Text("TBD: Payment")
            
        case let .serviceFailure(serviceFailure):
            Text("TBD: Alerts with OK that resets destination")
            
        case let .services(services, for: `operator`):
            List {
                ForEach(services.elements) {service in
                    
                    Button(String(service.id.prefix(24))) {
                        
                        viewModel.event(.utilityFlow(.prepayment(.select(.service(service, for: `operator`)))))
                    }
                }
            }
#warning("add navigation destination")
        }
    }
}

extension PaymentsTransfersView {
    
    typealias UtilityFlow = PaymentsTransfersViewModel.State.Route.Destination.UtilityFlow
    
    typealias Config = UtilityPrepaymentWrapperView.Config
    typealias Destination = ViewModel.State.Route.Destination
    typealias ViewModel = PaymentsTransfersViewModel
}

extension PaymentsTransfersViewModel.State.Route.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payByInstructions:
            return .payByInstructions
            
        case let .utilityFlow(utilityFlow):
            return .utilityFlow(ObjectIdentifier(utilityFlow.viewModel))
        }
    }
    
    enum ID: Hashable {
        
        case payByInstructions
        case utilityFlow(ObjectIdentifier)
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityFlow.Destination: Identifiable {
    
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
            
        case let .services(_, for: `operator`):
            return .services(for: `operator`.id)
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
