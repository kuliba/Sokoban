//
//  PaymentsTransfersView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import UIPrimitives
import SwiftUI

struct PaymentsTransfersView<DestinationView: View>: View {
    
    @StateObject private var viewModel: ViewModel
    let factory: Factory
    
    init(
        viewModel: ViewModel,
        factory: Factory
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.factory = factory
    }
    
    var body: some View {
        
        Button("Utility", action: viewModel.openUtilityPayment)
            .navigationDestination(
                item: .init(
                    get: { viewModel.state.route.destination },
                    set: { if $0 == nil { viewModel.resetDestination() }}
                ),
                content: factory.makeDestinationView
            )
    }
}

extension PaymentsTransfersView {
    
    typealias Destination = ViewModel.State.Route.Destination
    typealias Factory = PaymentsTransfersViewFactory<DestinationView>
    typealias ViewModel = PaymentsTransfersViewModel
}

#Preview {
    
    NavigationView {
        
        PaymentsTransfersView(viewModel: .preview(), factory: .preview)
    }
}
