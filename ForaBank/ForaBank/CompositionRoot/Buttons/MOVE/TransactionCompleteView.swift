//
//  TransactionCompleteView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import PaymentComponents
import SwiftUI

struct TransactionCompleteView: View {
    
    let state: State
    let goToMain: () -> Void
    let config: Config
    
    var body: some View {
        
        VStack {
            
            VStack(spacing: 24) {
                
                iconFor(status: state.status)
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
    
    typealias Config = TransactionCompleteViewConfig
    
    struct State {
        
        let details: Details?
        let status: Status
        
        typealias Details = TransactionDetailButton.Details
        
        enum Status {
            
            case completed, inflight, rejected, fraud
        }
    }
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
    
    func buttons() -> some View {
        
        HStack {
            
            state.details.map(TransactionDetailButton.init)
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
    
    func iconFor(
        status: TransactionCompleteView.State.Status
    ) -> Icons.Icon {
        
        switch status {
        case .completed: return icons.completed
        case .inflight:  return icons.inflight
        case .rejected:  return icons.rejected
        case .fraud:     return icons.fraud
        }
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
        
        let state = TransactionCompleteView.State(
            details: details,
            status: status
        )
        
        return TransactionCompleteView(state: state, goToMain: {}, config: .iFora)
    }
}
