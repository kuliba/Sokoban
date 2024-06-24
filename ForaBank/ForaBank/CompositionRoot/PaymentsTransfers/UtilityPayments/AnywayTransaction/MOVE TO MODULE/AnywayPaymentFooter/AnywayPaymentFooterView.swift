//
//  AnywayPaymentFooterView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import SwiftUI

struct AnywayPaymentFooterView: View {
    
    let state: State
    let config: Config
    
    var body: some View {
        
        switch state {
        case let .amount(node):
            BottomAmountStateWrapperView(
                viewModel: node.model,
                config: config.amountConfig,
                infoView: EmptyView.init
            )
            
        case let .continueButton(action):
            // TODO: move title to config
            continueButton("Продолжить", action: action, config: config.buttonConfig)
        }
    }
}

extension AnywayPaymentFooterView {
    
    typealias State = AnywayTransactionState.AmountFooter
    typealias Config = AnywayPaymentFooterConfig
}

private extension AnywayPaymentFooterView {
    
    func continueButton(
        _ title: String,
        action: @escaping () -> Void,
        config: ButtonConfig
    ) -> some View {
        
        PaymentComponents.ButtonView(
            state: .init(
                id: .buttonPay,
                value: title,
                color: .red,
                action: .pay,
                placement: .bottom
            ),
            event: action,
            config: config
        )
        .padding(.horizontal)
        //        .disabled(!state.isEnabled)
    }
}

private extension AmountEvent {
    
    var event: AnywayPaymentFooterEvent {
        
        switch self {
        case let .edit(decimal):
            return .edit(decimal)
            
        case .pay:
            return .continue
        }
    }
}

private extension PaymentComponents.Amount {
    
    init(
        buttonTitle: String,
        value: Decimal,
        isEnabled: Bool
    ) {
        self.init(
            title: buttonTitle,
            value: value,
            button: .init(
                title: buttonTitle,
                isEnabled: isEnabled
            )
        )
    }
}
