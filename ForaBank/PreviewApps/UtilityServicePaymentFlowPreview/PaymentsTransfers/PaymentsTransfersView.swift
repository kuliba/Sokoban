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
    
    private func destinationView(
        destination: Destination
    ) -> some View {
        
        switch destination {
        case let .utilityFlow(utilityPaymentViewModel):
            UtilityPrepaymentWrapperView(
                viewModel: utilityPaymentViewModel,
                flowEvent: { viewModel.event(.utilityFlow($0.flowEvent)) },
                config: config
            )
            .navigationTitle("UtilityPrepaymentView")
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
    
    var flowEvent: PaymentsTransfersEvent.UtilityFlowEvent {
        
        switch self {
        case .addCompany:
            return .addCompany
            
        case .payByInstructions:
            return .payByInstructions
            
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
