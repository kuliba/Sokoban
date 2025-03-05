//
//  ViewComponents+makePaymentCompletionLayoutView.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.02.2025.
//

import PaymentCompletionUI
import PaymentComponents
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makePaymentCompletionLayoutView(
        state: PaymentCompletion,
        config: PaymentCompletionLayoutViewConfig = .iVortex,
        statusConfig: PaymentCompletionConfig,
        buttons: @escaping () -> some View,
        details: @escaping () -> some View,
        footer: @escaping () -> some View
    ) -> some View {
        
        PaymentCompletionLayoutView(
            state: state,
            makeIconView: makeIconView,
            config: config,
            statusConfig: statusConfig,
            buttons: buttons,
            details: details,
            footer: footer
        )
        .padding(.horizontal)
    }
    
    /// Without `details`.
    @inlinable
    func makePaymentCompletionLayoutView(
        state: PaymentCompletion,
        config: PaymentCompletionLayoutViewConfig = .iVortex,
        statusConfig: PaymentCompletionConfig,
        buttons: @escaping () -> some View,
        footer: @escaping () -> some View
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: state,
            config: config,
            statusConfig: statusConfig,
            buttons: buttons,
            details: EmptyView.init,
            footer: footer
        )
    }
    
    @inlinable
    func makePaymentCompletionLayoutView(
        state: PaymentCompletion,
        config: PaymentCompletionLayoutViewConfig = .iVortex,
        details: @escaping () -> some View,
        statusConfig: PaymentCompletionConfig
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: state,
            config: config,
            statusConfig: statusConfig,
            buttons: EmptyView.init,
            details: details
        ) {
            PaymentComponents.ButtonView.goToMain(goToMain: goToMain)
                .conditionalBottomPadding()
        }
    }
    
    @inlinable
    func makePaymentCompletionLayoutView(
        state: PaymentCompletion,
        config: PaymentCompletionLayoutViewConfig = .iVortex,
        statusConfig: PaymentCompletionConfig,
        buttons: @escaping () -> some View
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: state,
            config: config,
            statusConfig: statusConfig,
            buttons: buttons,
            details: EmptyView.init
        ) {
            PaymentComponents.ButtonView.goToMain(goToMain: goToMain)
                .conditionalBottomPadding()
        }
    }
    
    @inlinable
    func makePaymentCompletionLayoutView(
        state: PaymentCompletion,
        config: PaymentCompletionLayoutViewConfig = .iVortex,
        statusConfig: PaymentCompletionConfig
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: state,
            config: config,
            statusConfig: statusConfig,
            buttons: EmptyView.init
        )
    }
}
