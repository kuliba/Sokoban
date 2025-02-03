//
//  CollateralLoanLandingCompleteView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 03.02.2025.
//

import SwiftUI
import UIPrimitives

struct CollateralLoanLandingCompleteView: View {
    
    let state: State
    let goToMain: () -> Void
    let factory: Factory
    let makeIconView: (String?) -> UIPrimitives.AsyncImage

    var body: some View {

        TransactionCompleteView(
            state: transactionCompleteState,
            goToMain: {},
            repeat: {},
            factory: factory,
            content: content
        )
    }
}

extension CollateralLoanLandingCompleteView {
    
    typealias Factory = PaymentCompleteViewFactory
    typealias State = PaymentCompleteState
}

extension CollateralLoanLandingCompleteView {
    
    var transactionCompleteState: TransactionCompleteState {
     
        // Stub
        .init(
            details: nil,
            documentID: nil,
            status: .completed
        )
    }
}

private func content() -> some View {
    
    Text("content")
}
