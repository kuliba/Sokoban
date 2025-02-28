//
//  ViewComponents+makeStatementDetailView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import RxViewModel
import SharedConfigs
import SwiftUI
import UIPrimitives

extension ViewComponents {
    
    @inlinable
    func makeStatementDetailView(
        _ details: StatementDetails
    ) -> some View {
        
        StatementDetailLayoutView(config: .iVortex) {
            
            makeC2GPaymentCompleteButtonsView(
                details: details.details,
                document: details.document
            )
            
        } content: {
            
            makeStatementDetailContentView(details: details)
        }
    }
    
    @inlinable
    func makeStatementDetailContentView(
        details: StatementDetails
    ) -> some View {
        
        RxWrapperView(model: details.details) { state, _ in
            
            switch state.extendedDetails {
            case let .completed(extendedDetails):
                makeStatementDetailContentLayoutView(content: .init(
                    content: details.content,
                    extendedDetails: extendedDetails
                ))
                
            case .failure:
                makeStatementDetailContentLayoutView(content: .init(
                    content: details.content,
                    extendedDetails: nil
                ))
                
            case .loading:
                ProgressView() // TODO: replace with shimmer
                
            case .pending:
                ProgressView()
            }
        }
    }
    
    @inlinable
    func makeStatementDetailContentLayoutView(
        content: StatementDetailContent
    ) -> some View {
        
        StatementDetailContentLayoutView(
            content: content,
            config: .iVortex,
            makeLogoView: makeIconView
        )
    }
}

// MARK: - Adapters

private extension StatementDetailContent {
    
    init(
        content: StatementDetails.Content,
        extendedDetails: OperationDetailDomain.ExtendedDetails?
    ) {
        self.init(
            // Сумма операции+ валюта операции-  amount + payerCurrency из getOperationDetail
            formattedAmount: extendedDetails?.signedFormattedAmount,
            // Дата операции - "dateForDetail" из getOperationDetail
            formattedDate: extendedDetails?.dateForDetail,
            // Лого- md5hash из getCardStatementForPeriod_V3/getAccountStatementForPeriod_V3
            merchantLogo: content.logo,
            // Наименование получателя-    foreignName из getCardStatementForPeriod_V3/getAccountStatementForPeriod_V3
            merchantName: content.name,
            // Назначение платежа- "comment" из getOperationDetail
            purpose: extendedDetails?.comment,
            // Статус операции- operationStatus из getOperationDetail
            status: extendedDetails?.status._status
        )
    }
}

private extension OperationDetailDomain.ExtendedDetails {
    
    var signedFormattedAmount: String? {
        
        formattedAmount.map { "- " + $0 }
    }
}

private extension OperationDetailDomain.Status {
    
    var _status: StatementDetailContent.Status {
        
        switch self {
        case .completed: return .completed
        case .inflight:  return .inflight
        case .rejected:  return .rejected
        }
    }
}

// MARK: - Previews

struct MakeStatementDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            view(.completed(.preview))
                .previewDisplayName("completed")
            
            view(.failure(NSError(domain: "Load Failure", code: -1)))
                .previewDisplayName("failure")
            
            view(.loading(nil))
                .previewDisplayName("loading")
            
            view(.pending)
                .previewDisplayName("pending")
        }
    }
    
    private static func view(
        _ fullDetails: OperationDetailDomain.State.ExtendedDetailsState
    ) -> some View {
        
        ViewComponents.preview.makeStatementDetailView(.init(
            content: .init(logo: nil, name: "merchant"),
            details: .preview(
                basicDetails: .preview,
                fullDetails: fullDetails
            ),
            document: .preview
        ))
    }
}
