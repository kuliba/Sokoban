//
//  TransactionCompleteView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import PaymentComponents
import PaymentCompletionUI
import SwiftUI

struct TransactionCompleteView<Content: View>: View {
    
    let state: State
    let goToMain: () -> Void
    let `repeat`: () -> Void
    let factory: Factory
    let content: () -> Content
    
    var body: some View {
        
        VStack {
            
            content()
            
            Spacer()
            
            VStack(spacing: 56) {
                
                buttons()
                    .frame(maxHeight: .infinity, alignment: .bottom)
                
                VStack(spacing: 8) {
                    
                    // repeatButton()
                    
                    PaymentComponents.ButtonView.goToMain(goToMain: goToMain)
                }
            }
        }
        .padding(.bottom)
        .padding(.horizontal)
    }
}

extension TransactionCompleteView {
    
    typealias State = TransactionCompleteState
    typealias Config = PaymentCompletionConfig
    typealias Factory = PaymentCompleteViewFactory
}

private extension TransactionCompleteView {
    
    @ViewBuilder
    func buttons() -> some View {
        
        switch state.status {
        case .completed:
            HStack {
                
                factory.makeTemplateButton()
                state.documentID.map(factory.makeDocumentButton)
                state.details.map(factory.makeDetailButton)
            }
            
        case .inflight:
            HStack {
                
                factory.makeTemplateButton()
                state.details.map(factory.makeDetailButton)
            }
            
        case .rejected, .fraud:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func repeatButton() -> some View {
        
        if state.status == .rejected {
            
            Button("TBD: Repeat Button", action: `repeat`)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color.buttonSecondary)
                )
        }
    }
}

#if DEBUG
struct TransactionCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            completeView(.completed)
            completeView(.completedWithDetails)
            completeView(.completedWithDocumentID)
            completeView(.completedWithDetailsAndDocumentID)
            
            completeView(.inflight)
            completeView(.rejected)
            completeView(.fraud)
        }
    }
    
    private static func completeView(
        _ state: TransactionCompleteState
    ) -> some View {
        
        return TransactionCompleteView(
            state: state,
            goToMain: {},
            repeat: {},
            factory: .init(
                makeDetailButton: TransactionDetailButton.init,
                makeDocumentButton: { _ in .init(getDocument: { $0(nil) }) },
                makeTemplateButton: { nil }
            ),
            content: { Text("Content") }
        )
    }
}

private extension TransactionCompleteState {
    
    static let completed: Self = .completed()
    static let completedWithDetails: Self = .completed(details: .empty)
    static let completedWithDocumentID: Self = .completed(documentID: 1)
    static let completedWithDetailsAndDocumentID: Self = .completed(
        details: .empty,
        documentID: 1
    )
    private static func completed(
        details: Details? = nil,
        documentID: DocumentID? = nil
    ) -> Self {
        
        return .init(details: details, documentID: documentID, status: .completed)
    }
    
    static let inflight: Self = .init(details: .empty, .inflight)
    static let rejected: Self = .init(.rejected)
    static let fraud: Self = .init(.fraud)
    
    private init(
        details: Details? = nil,
        documentID: DocumentID? = nil,
        _ status: Status
    ) {
        self.init(details: details, documentID: documentID, status: status)
    }
}

private extension TransactionDetailButton.Details {
    
    static let empty: Self = .init(logo: nil, cells: [])
}
#endif
