//
//  QRFailedViewModelWrapperView.swift
//  Vortex
//
//  Created by Igor Malyarov on 14.11.2024.
//

import SwiftUI

struct QRFailedViewModelWrapperView: View {
    
    @ObservedObject var viewModel: QRFailedViewModelWrapper
    
    let viewFactory: QRFailedViewFactory
    let paymentsViewFactory: PaymentsViewFactory
    
    var body: some View {
        
        QRFailedView(
            viewModel: viewModel.qrFailedViewModel,
            viewFactory: viewFactory
        )
        .navigationDestination(
            destination: viewModel.destination,
            dismiss: viewModel.dismiss,
            content: {
                
                PaymentsView(
                    viewModel: $0.model,
                    viewFactory: paymentsViewFactory
                )
            }
        )
    }
}

extension Node: Identifiable where Model: AnyObject {
    
    public var id: ObjectIdentifier { .init(model) }
}

private extension QRFailedViewModelWrapper {
    
    var destination: Node<PaymentsViewModel>? {
        
        guard case let .destination(node) = navigation else { return nil }
        
        return node
    }
}
