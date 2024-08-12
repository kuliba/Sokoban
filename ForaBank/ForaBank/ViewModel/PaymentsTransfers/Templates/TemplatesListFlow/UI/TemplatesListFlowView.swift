//
//  TemplatesListFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import SwiftUI

struct TemplatesListFlowView: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        
        TemplatesListView(viewModel: model.state.content)
            .navigationDestination(
                destination: model.state.destination,
                dismissDestination: { model.event(.dismiss(.destination)) },
                content: destinationContent
            )
    }
}

extension TemplatesListFlowView {
    typealias Model = TemplatesListFlowModel<TemplatesListViewModel>
}

extension TemplatesListFlowState {
    
    var destination: Status.Destination? {
        
        guard case let .destination(destination) = status
        else { return nil }
        
        return destination
    }
}

extension TemplatesListFlowState.Status.Destination: Identifiable {
 
    var id: ID {
        
        switch self {
        case .payment: return .payment
        }
    }
    
    enum ID: Hashable {
        
        case payment
    }
}

extension TemplatesListViewModel: ProductIDEmitter {
    
    var productIDPublisher: AnyPublisher<ProductID, Never> {
        
        action
            .compactMap { $0 as? TemplatesListViewModelAction.OpenProductProfile }
            .map(\.productId)
            .eraseToAnyPublisher()
    }
}

extension TemplatesListViewModel: TemplateEmitter {
    
    var templatePublisher: AnyPublisher<PaymentTemplateData, Never> {
        
        action
            .compactMap { $0 as? TemplatesListViewModelAction.OpenDefaultTemplate }
            .map(\.template)
            .eraseToAnyPublisher()
    }
}

private extension TemplatesListFlowView {
    
    @ViewBuilder
    func destinationContent(
        destination: Model.State.Status.Destination
    ) -> some View {
        
        switch destination {
        case let .payment(paymentsViewModel):
            PaymentsView(viewModel: paymentsViewModel)
        }
    }
}
