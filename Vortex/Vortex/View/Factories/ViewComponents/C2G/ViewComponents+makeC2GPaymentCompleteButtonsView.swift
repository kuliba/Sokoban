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
        
        RxWrapperView(model: model) { state, _ in
            
            makeC2GPaymentCompleteButtonsView(state: state)
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeC2GPaymentCompleteButtonsView(
        state: OperationDetailDomain.State
    ) -> some View {
        
        HStack(spacing: 8) {
            
            switch state.details {
            case .completed, .loading:
                // Text("2 buttons")
                Group {
                 
                    WithSheetView {
                        circleButton(image: .ic24Info, title: "Детали", action: $0)
                    } sheet: {
                         Text("TBD: Детали")
                        // c2gTransactionDetails(details: <#T##any TransactionDetailsProviding<[DetailsCell]>#>, dismiss: $0)
                    }

                    WithSheetView {
                        circleButton(image: .ic24Share, title: "Реквизиты", action: $0)
                    } sheet: {
                         Text("TBD: Реквизиты")
                        // c2gPaymentRequisites(details: <#T##any PaymentRequisitesProviding<[DetailsCell]>#>, dismiss: $0)
                    }
                }
                .disabled(state._details == nil)
                .redacted(reason: state._details == nil ? .privacy : [])
                ._shimmering(isActive: state._details == nil)
                
            case .failure:
                // Text(" 1 button with short details")
                WithSheetView {
                    circleButton(image: .ic24Info, title: "Детали", action: $0)
                } sheet: {
                    Text("TBD: short details")
                }
                                
            case .pending:
                EmptyView()
            }
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
            state: .init(details: details, response: .preview)
        )
    }
}

private extension OperationDetailDomain.State.EnhancedResponse {
    
    static let preview: Self = .init(formattedAmount: nil, merchantName: nil, message: nil, paymentOperationDetailID: 1, product: .preview, purpose: nil, status: .completed, uin: UUID().uuidString)
}

