//
//  TransactionView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct TransactionView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        List {
            
            Section {
                button("complete with failure", .completePayment(nil))
                    .foregroundColor(.red)
                
                button("complete", .completePayment(.init(status: .completed, info: .detailID(123))))
                button("inflight", .completePayment(.init(status: .inflight, info: .detailID(123))))
                button("reject", .completePayment(.init(status: .rejected, info: .detailID(123))))
            } header: {
                Text("complete Payment event")
            }
            
            Section {
                button("Continue", .continue)
            } header: {
                Text("Continue")
            }
            
            Section {
                button("dismissRecoverableError", .dismissRecoverableError)
            } header: {
                Text("dismiss Recoverable Error")
            }
            
            Section {
                button("cancel", .fraud(.cancel))
                button("continue", .fraud(.continue))
                button("expire", .fraud(.expired))
            } header: {
                Text("Fraud")
            }
            
            Section {
                button("initiatePayment", .initiatePayment)
            } header: {
                Text("initiate Payment")
            }
            
            Section {
                button("payment", .payment(.anEvent))
            } header: {
                Text("payment")
            }
            
            Section {
                
                button("updatePayment Failure", .updatePayment(.failure(.connectivityError)))
                    .foregroundColor(.red)
                
                button("updatePayment Success", .updatePayment(.success(9876)))
            } header: {
                Text("update Payment")
            }
        }
    }
    
    private func button(
        _ title: String,
        _ event: Event
    ) -> some View {
        
        Button(title) { self.event(event) }
            .contentShape(Rectangle())
    }
}

extension TransactionView {
    
    typealias State = TransactionState
    typealias Event = TransactionEvent
}

#Preview {
    TransactionView(state: .preview, event: { print($0) })
}
