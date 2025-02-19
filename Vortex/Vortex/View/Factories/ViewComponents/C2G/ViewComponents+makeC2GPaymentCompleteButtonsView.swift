//
//  ViewComponents+makeC2GPaymentCompleteButtonsView.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import RxViewModel
import StateMachines
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentCompleteButtonsView(
        _ model: OperationDetailDomain.Model
    ) -> some View {
        
        RxWrapperView(model: model, makeContentView: makeC2GPaymentCompleteButtonsView)
    }
    
    @inlinable
    @ViewBuilder
    func makeC2GPaymentCompleteButtonsView(
        state: OperationDetailDomain.State,
        event: @escaping (OperationDetailDomain.Event) -> Void
    ) -> some View {
        
        switch state.details {
        case let .completed(details):
            Text("2 buttons")
            
        case .failure:
            Text(" 1 button with short details")
            
        case .loading:
            Text("2 button labels")
                ._shimmering()
            
        case .pending:
            EmptyView()
        }
    }
}

struct MakeC2GPaymentCompleteButtonsView_Previews: PreviewProvider {
    
    typealias Details = StateMachines.LoadState<OperationDetailDomain.State.Details, Error>
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            view(.completed(()))
            view(.failure(NSError(domain: "Failure", code: -1)))
            view(.loading(nil))
            view(.pending)
        }
    }
    
    private static func view(
        _ details: Details
    ) -> some View {
        
        ViewComponents.preview.makeC2GPaymentCompleteButtonsView(
            state: .init(details: details, response: .preview),
            event: { print($0) }
        )
    }
}

private extension OperationDetailDomain.State.EnhancedResponse {
    
    static let preview: Self = .init(formattedAmount: nil, merchantName: nil, message: nil, paymentOperationDetailID: 1, product: .preview, purpose: nil, status: .completed, uin: UUID().uuidString)
}

