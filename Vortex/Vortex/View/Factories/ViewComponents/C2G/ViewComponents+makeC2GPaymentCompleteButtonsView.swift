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
        details: OperationDetailDomain.Model,
        document: C2GDocumentButtonDomain.Binder
    ) -> some View {
        
        HStack(alignment: .top, spacing: 8) {
            
            makeC2GDocumentButtonDomainBinderView(document)
            
            RxWrapperView(model: details) { state, _ in
                
                makeC2GPaymentCompleteDetailsAndRequisitesButtonsView(state: state)
            }
        }
    }
    
    @inlinable
    func makeC2GDocumentButtonDomainBinderView(
        _ binder: C2GDocumentButtonDomain.Binder
    ) -> some View {
        
        circleButton(image: .ic24File, title: "Документ") {
            
            binder.flow.event(.select(.tap(binder.content)))
        }
        .background(makeC2GDocumentButtonFlowView(binder.flow))
    }
    
    @inlinable
    func makeC2GPaymentCompleteDetailsAndRequisitesButtonsView(
        state: OperationDetailDomain.State
    ) -> some View {
        
        HStack(alignment: .top, spacing: 8) {
            
            switch state.extendedDetails {
            case let .completed(details):
                makeC2GPaymentCompleteDetailsButton(details)
                makeC2GPaymentCompleteRequisitesButton(details)
                
            case .failure:
                makeC2GPaymentCompleteBasicDetailsButton(state.basicDetails)
                
            case .loading:
                circleButtonPlaceholder()
                circleButtonPlaceholder()
                
            case .pending:
                EmptyView()
            }
        }
    }
    
    @inlinable
    func makeC2GPaymentCompleteDetailsButton(
        _ fullDetails: OperationDetailDomain.ExtendedDetails
    ) -> some View {
        
        WithFullScreenCoverView {
            circleButton(image: .ic24Info, title: "Детали", action: $0)
        } sheet: {
            c2gTransactionDetails(details: fullDetails, dismiss: $0)
        }
    }
    
    @inlinable
    func makeC2GPaymentCompleteBasicDetailsButton(
        _ basicDetails: OperationDetailDomain.BasicDetails
    ) -> some View {
        
        WithFullScreenCoverView {
            circleButton(image: .ic24Info, title: "Детали", action: $0)
        } sheet: {
            c2gTransactionDetails(details: basicDetails, dismiss: $0)
        }
    }
    
    @inlinable
    func makeC2GPaymentCompleteRequisitesButton(
        _ fullDetails: OperationDetailDomain.ExtendedDetails
    ) -> some View {
        
        WithFullScreenCoverView {
            circleButton(image: .ic24Share, title: "Реквизиты", action: $0)
        } sheet: {
            c2gPaymentRequisites(details: fullDetails, dismiss: $0)
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
        .frame(width: 100, height: 92, alignment: .top)
        .contentShape(Rectangle())
    }
    
    @inlinable
    func circleButtonPlaceholder() -> some View {
        
        PaymentCompleteButtonsPlaceholderView(config: .iVortex)
            ._shimmering()
            .frame(width: 100, height: 92, alignment: .top)
    }
}

private extension OperationDetailDomain.State {
    
    var _details: OperationDetailDomain.ExtendedDetails? {
        
        guard case let .completed(details) = extendedDetails else { return nil }
        
        return details
    }
}

// MARK: - Previews

struct MakeC2GPaymentCompleteDetailsAndRequisitesButtonsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            view(.completed(.preview))
            view(.failure(NSError(domain: "Failure", code: -1)))
            view(.loading(nil))
            view(.pending)
        }
    }
    
    private static func view(
        _ fullDetails: OperationDetailDomain.State.ExtendedDetailsState
    ) -> some View {
        
        ViewComponents.preview.makeC2GPaymentCompleteDetailsAndRequisitesButtonsView(
            state: .init(basicDetails: .preview, extendedDetails: fullDetails)
        )
    }
}

extension OperationDetailDomain.BasicDetails {
    
    static let preview: Self = .init(
        formattedAmount: "2 000 ₽",
        formattedDate: "06.05.2021 15:38:12",
        product: .preview
    )
}

extension OperationDetailDomain.ModelPayload {
    
    static let preview: Self = .init(
        product: .preview,
        status: .completed,
        dateForDetail: "19 февраля 2025, 12:44",
        formattedAmount: "2 000 ₽",
        merchantName: "2 000 ₽",
        message: nil,
        paymentOperationDetailID: 1,
        purpose: "Единый налоговый платеж",
        uin: UUID().uuidString
    )
}
