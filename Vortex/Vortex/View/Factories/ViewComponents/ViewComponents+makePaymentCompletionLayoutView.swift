//
//  ViewComponents+makePaymentCompletionLayoutView.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SwiftUI

import PaymentCompletionUI
import PaymentComponents

extension ViewComponents {
    
    @inlinable
    func makePaymentCompletionLayoutView(
        state: PaymentCompletion,
        config: PaymentCompletionConfig,
        buttons: @escaping () -> some View,
        footer: @escaping () -> some View
    ) -> some View {
        
        PaymentCompletionLayoutView(
            state: state,
            makeIconView: makeIconView,
            config: config,
            buttons: buttons,
            footer: footer
        )
        .padding(.horizontal)
    }
    
    @inlinable
    func makePaymentCompletionLayoutView(
        state: PaymentCompletion,
        config: PaymentCompletionConfig,
        buttons: @escaping () -> some View
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: state,
            config: config,
            buttons: buttons
        ) {
            PaymentComponents.ButtonView.goToMain(goToMain: goToMain)
        }
    }
    
    @inlinable
    func makePaymentCompletionLayoutView(
        state: PaymentCompletion,
        config: PaymentCompletionConfig
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: state,
            config: config,
            buttons: EmptyView.init
        )
    }
}
