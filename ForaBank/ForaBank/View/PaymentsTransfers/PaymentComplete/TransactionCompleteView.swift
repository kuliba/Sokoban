//
//  TransactionCompleteView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import PaymentComponents
import SwiftUI

struct TransactionCompleteView<Content: View>: View {
    
    let state: State
    let goToMain: () -> Void
    let `repeat`: () -> Void
    let config: Config
    let content: () -> Content
    let factory: Factory
    
    var body: some View {
        
        VStack {
            
            VStack(spacing: 24) {
                
                iconFor(status: state.status)
                messageFor(status: state.status)
                content()
            }
            
            Spacer()
            
            VStack(spacing: 56) {
                
                buttons()
                    .frame(maxHeight: .infinity, alignment: .bottom)
                
                VStack(spacing: 8) {
                    
                    repeatButton()
                    
                    PaymentComponents.ButtonView.goToMain(goToMain: goToMain)
                }
            }
        }
        .padding(.top, 88)
        .padding(.bottom)
        .padding(.horizontal)
    }
}

extension TransactionCompleteView {
    
    typealias State = TransactionCompleteState
    typealias Config = TransactionCompleteViewConfig
    typealias Factory = PaymentCompleteViewFactory
}

private extension TransactionCompleteView {
    
    func iconFor(
        status: State.Status
    ) -> some View {
        
        config.imageFor(status: status)
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .frame(width: 48, height: 48)
            .foregroundColor(.iconWhite)
            .frame(width: 88, height: 88)
            .background(
                Circle()
                    .foregroundColor(config.colorFor(status: status))
            )
            .accessibilityIdentifier("SuccessPageStatusIcon")
    }
    
    func messageFor(
        status: State.Status
    ) -> some View {
        
        let textConfig = config.configFor(status: status).messageConfig
        
        return config.messageFor(status: status).text(withConfig: textConfig)
    }
    
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

private extension TransactionCompleteViewConfig {
    
    func imageFor(
        status: TransactionCompleteView.State.Status
    ) -> Image {
        
        iconFor(status: status).image
    }
    
    func colorFor(
        status: TransactionCompleteView.State.Status
    ) -> Color {
        
        iconFor(status: status).color
    }
    
    func configFor(
        status: TransactionCompleteView.State.Status
    ) -> TransactionCompleteViewConfig.Statuses.Status {
        
        switch status {
        case .completed: return statuses.completed
        case .inflight:  return statuses.inflight
        case .rejected:  return statuses.rejected
        case .fraud:     return statuses.fraud
        }
    }
    
    func iconFor(
        status: TransactionCompleteView.State.Status
    ) -> Statuses.Status.Icon {
        
        return configFor(status: status).icon
    }
    
    func messageFor(
        status: TransactionCompleteView.State.Status
    ) -> String {
        
        return configFor(status: status).message
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
            config: .iFora,
            content: { Text("Content") },
            factory: .init(
                makeDetailButton: TransactionDetailButton.init,
                makeDocumentButton: { _ in .init(getDocument: { $0(nil) }) },
                makeTemplateButton: { nil }
            )
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
