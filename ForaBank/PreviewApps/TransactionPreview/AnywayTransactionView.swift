//
//  AnywayTransactionView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct AnywayTransactionView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        List {
            
            Section {
                Text("Payment UI")
                button("payment", .payment(.anEvent))
            } header: {
                Text("payment")
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
                button("Continue", .continue)
            } header: {
                Text("Continue")
            }
            
            Section {} header: {
                Text("\"Effect\" (non-UI) events")
                    .foregroundColor(.orange)
            }
            
            Section {
                button("complete with failure", .completePayment(nil))
                    .foregroundColor(.red)
                
                button(
                    "complete",
                    .completePayment(.init(status: .completed, info: .detailID(123)))
                )
                button(
                    "inflight",
                    .completePayment(.init(status: .inflight, info: .detailID(123)))
                )
                button(
                    "reject",
                    .completePayment(.init(status: .rejected, info: .detailID(123)))
                )
            } header: {
                Text("complete Payment event")
            }
            
            Section {
                button("initiatePayment", .initiatePayment)
            } header: {
                Text("initiate Payment")
            }
            
            Section {
                
                button(
                    "updatePayment Failure",
                    .updatePayment(.failure(.connectivityError))
                )
                .foregroundColor(.red)
                
                button(
                    "updatePayment Success",
                    .updatePayment(.success(.preview))
                )
            } header: {
                Text("update Payment")
            }
        }
        .listStyle(.grouped)
    }
    
    private func button(
        _ title: String,
        _ event: Event
    ) -> some View {
        
        Button(title) { self.event(event) }
            .contentShape(Rectangle())
    }
}

extension AnywayTransactionView {
    
    typealias State = AnywayTransactionState
    typealias Event = AnywayTransactionEvent
}

#Preview {
    AnywayTransactionView(state: .preview, event: { print($0) })
}
