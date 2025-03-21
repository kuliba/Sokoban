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
            
            makeC2GPaymentStatementDetailButtonsView(
                details: details.details,
                document: details.document
            )
            
        } content: {
            
            makeStatementDetailContentView(details: details)
        }
        .padding(.horizontal)
    }
    
    @inlinable
    func makeC2GPaymentStatementDetailButtonsView(
        details: OperationDetailDomain.Model,
        document: C2GDocumentButtonDomain.Binder?
    ) -> some View {
        
        HStack(alignment: .top, spacing: 8) {
            
            document.map(makeC2GDocumentButtonDomainBinderView)
            
            RxWrapperView(model: details) { state, _ in
                
                makeC2GPaymentCompleteDetailsAndRequisitesButtonsView(state: state)
            }
        }
    }
    
    @inlinable
    func makeC2GDocumentButtonFlowView(
        _ flow: C2GDocumentButtonDomain.Flow
    ) -> some View {
        
        RxWrapperView(model: flow) { state, event in
            
            Color.clear
                .fullScreenCover(
                    cover: state.navigation,
                    dismiss: { event(.dismiss) },
                    content: {
                        
                        makeC2GDocumentButtonDomainNavigationView(
                            navigation: $0,
                            dismiss: { flow.event(.dismiss) }
                        )
                    }
                )
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeC2GDocumentButtonDomainNavigationView(
        navigation: C2GDocumentButtonDomain.Navigation,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        switch navigation {
        case let .destination(binder):
            makePDFDocumentDomainContentView(binder.content, dismiss: dismiss)
                .background(makePDFDocumentDomainFlowView(binder.flow, dismiss: dismiss))
        }
    }
    
    @inlinable
    @ViewBuilder
    func makePDFDocumentDomainContentView(
        _ content: PDFDocumentDomain.Content,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        RxWrapperView(model: content) { state, event in
            
            switch state {
            case let .completed(pdfDocument):
                PDFDocumentWrapperView(
                    pdfDocument: pdfDocument, 
                    dismissAction: dismiss
                )
                .navigationBarWithClose(
                    title: "Сохранить или отправить ", 
                    dismiss: dismiss
                )
                
            case .failure, .pending:
                EmptyView()
                
            case .loading:
                SpinnerView(viewModel: .init())
            }
        }
    }
    
    @inlinable
    @ViewBuilder
    func makePDFDocumentDomainFlowView(
        _ flow: PDFDocumentDomain.Flow,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        RxWrapperView(model: flow) { state, _ in
            
            Color.clear
                .alert(item: state.navigation) {
                    
                    switch $0 {
                    case let .alert(message):
                        return .init(with: .techError(
                            message: message,
                            primaryAction: dismiss
                        ))
                    }
                }
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

extension C2GDocumentButtonDomain.Navigation: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .destination(binder):
            return .destination(.init(binder))
        }
    }
    
    enum ID: Hashable {
        
        case destination(ObjectIdentifier)
    }
}

extension PDFDocumentDomain.Navigation: Identifiable {
    
    var id: String {
        
        switch self {
        case let .alert(string): return string
        }
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
                .previewDisplayName("completed no doc")
            
            view(.completed(.preview), .preview)
                .previewDisplayName("completed with doc")
            
            view(.failure(NSError(domain: "Load Failure", code: -1)))
                .previewDisplayName("failure")
            
            view(.loading(nil))
                .previewDisplayName("loading")
            
            view(.pending)
                .previewDisplayName("pending")
        }
    }
    
    private static func view(
        _ fullDetails: OperationDetailDomain.State.ExtendedDetailsState,
        _ document: C2GDocumentButtonDomain.Binder? = nil
    ) -> some View {
        
        ViewComponents.preview.makeStatementDetailView(.init(
            content: .init(logo: nil, name: "merchant"),
            details: .preview(
                basicDetails: .preview,
                fullDetails: fullDetails
            ),
            document: document
        ))
    }
}

private extension C2GDocumentButtonDomain.Binder {
    
    static let preview: C2GDocumentButtonDomain.Binder = .init(
        content: 0,
        flow: .init(
            initialState: .init(),
            reduce: { state, _ in (state, nil) },
            handleEffect: { _,_ in }
        ),
        bind: { _,_ in [] }
    )
}
