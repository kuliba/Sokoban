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
            
        case let .utilityFlow(utilityPaymentViewModel):
            UtilityPrepaymentWrapperView(
                viewModel: utilityPaymentViewModel,
                flowEvent: { viewModel.event(.utilityFlow(.prepayment($0.flowEvent))) },
                config: config
            )
            .navigationTitle("Utility Prepayment View")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension PaymentsTransfersView {
    
    typealias Config = UtilityPrepaymentWrapperView.Config
    typealias Destination = ViewModel.State.Route.Destination
    typealias ViewModel = PaymentsTransfersViewModel
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
