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
                
                PaymentComponents.ButtonView.goToMain(goToMain: goToMain)
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

struct TransactionCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            completeView(nil)
            completeView(nil, .fraud)
            completeView(nil, .inflight)
            completeView(nil, .rejected)
            completeView(nil)
            completeView(.init(logo: .ic16Tv, cells: []))
            completeView(.init(logo: .ic16Tv, cells: [
                OperationDetailInfoViewModel.DefaultCellViewModel(title: "Title"),
                OperationDetailInfoViewModel.PropertyCellViewModel(title: "title", iconType: .cardPlaceholder, value: "value"),
                OperationDetailInfoViewModel.IconCellViewModel(icon: .ic24Car),
            ]))
        }
    }
    
    private static func completeView(
        _ details: TransactionCompleteView.State.Details?,
        _ status: TransactionCompleteView.State.Status = .completed
    ) -> some View {
        
        let state = TransactionCompleteState(
            details: details,
            documentID: .init(12345),
            status: status
        )
        
        return TransactionCompleteView(
            state: state,
            goToMain: {},
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
