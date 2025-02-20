//
//  ViewComponents+makeC2GPaymentCompleteButtonsView.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import RxViewModel
import StateMachines
import SwiftUI
import UIPrimitives

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentCompleteButtonsView(
        _ model: OperationDetailDomain.Model
    ) -> some View {
        
        RxWrapperView(model: model) { state, _ in
            
            makeC2GPaymentCompleteButtonsView(state: state)
        }
    }
    
    @inlinable
    func makeC2GPaymentCompleteButtonsView(
        state: OperationDetailDomain.State
    ) -> some View {
        
        HStack(spacing: 8) {
            
            switch state.details {
            case let .completed(details):
                makeC2GPaymentCompleteDetailsButton(details: details)
                makeC2GPaymentCompleteRequisitesButton(details: details)
                
            case .failure:
                makeC2GPaymentCompleteShortDetailsButton(response: state.response)
                
            case .loading:
                Group {
                    
                    circleButton(image: .ic24Info, title: "Детали") {}
                    circleButton(image: .ic24Share, title: "Реквизиты") {}
                }
                .disabled(true)
                .redacted(reason: .placeholder)
                ._shimmering()
                
            case .pending:
                EmptyView()
            }
        }
    }
    
    @inlinable
    func makeC2GPaymentCompleteDetailsButton(
        details: OperationDetailDomain.State.Details
    ) -> some View {
        
        WithSheetView {
            circleButton(image: .ic24Info, title: "Детали", action: $0)
        } sheet: {
            c2gTransactionDetails(details: details, dismiss: $0)
        }
    }
    
    @inlinable
    func makeC2GPaymentCompleteShortDetailsButton(
        response: OperationDetailDomain.State.EnhancedResponse
    ) -> some View {
        
        WithSheetView {
            circleButton(image: .ic24Info, title: "Детали", action: $0)
        } sheet: {
            c2gTransactionDetails(details: response, dismiss: $0)
        }
    }
    
    @inlinable
    func makeC2GPaymentCompleteRequisitesButton(
        details: OperationDetailDomain.State.Details
    ) -> some View {
        
        WithSheetView {
            circleButton(image: .ic24Share, title: "Реквизиты", action: $0)
        } sheet: {
            c2gPaymentRequisites(details: details, dismiss: $0)
        }
    }
    
    @inlinable
    func circleButton(
        image: Image,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        
        ButtonIconTextView(viewModel: .init(
            icon: .init(image: image, background: .circle),
            title: .init(text: title),
            orientation: .vertical,
            action: action
        ))
        .frame(width: 100, height: 92)
    }
}

extension OperationDetailDomain.State {
    
    var _details: OperationDetailDomain.State.Details? {
        
        guard case let .completed(details) = details else { return nil }
        
        return details
    }
}

// MARK: - Previews

struct MakeC2GPaymentCompleteButtonsView_Previews: PreviewProvider {
    
    typealias Details = StateMachines.LoadState<OperationDetailDomain.State.Details, Error>
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            view(.completed(1))
            view(.failure(NSError(domain: "Failure", code: -1)))
            view(.loading(nil))
            view(.pending)
        }
    }
    
    private static func view(
        _ details: Details
    ) -> some View {
        
        ViewComponents.preview.makeC2GPaymentCompleteButtonsView(
            state: .init(details: details, response: .preview)
        )
    }
}

extension OperationDetailDomain.State.EnhancedResponse {
    
    static let preview: Self = .init(formattedAmount: nil, formattedDate: nil, merchantName: nil, message: nil, paymentOperationDetailID: 1, product: .preview, purpose: nil, status: .completed, uin: UUID().uuidString)
}
