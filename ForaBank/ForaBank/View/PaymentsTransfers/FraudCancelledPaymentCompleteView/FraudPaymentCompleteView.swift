//
//  FraudPaymentCompleteView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.06.2024.
//

import PaymentComponents
import SwiftUI

struct FraudPaymentCompleteView: View {
    
    let state: State
    let action: () -> Void
    let config: Config
    
    var body: some View {
        
        VStack {
            
            content()
                .frame(maxHeight: .infinity, alignment: .top)
            
            PaymentComponents.ButtonView.goToMain(goToMain: action)
        }
        .padding(.top, 88)
        .padding(.bottom)
        .padding(.horizontal)
    }
}

extension FraudPaymentCompleteView {
    
    typealias Config = FraudPaymentCompleteViewConfig
    
    struct State: Equatable {
        
        let formattedAmount: String
        let hasExpired: Bool
    }
}

private extension FraudPaymentCompleteView {
    
    func content() -> some View {
        
        VStack(spacing: 24) {
            
            config.icon
                .foregroundColor(.iconWhite)
                .frame(width: 88, height: 88)
                .background(
                    Circle()
                        .foregroundColor(config.iconColor)
                )
                .accessibilityIdentifier("SuccessPageStatusIcon")
            
            VStack(spacing: 12) {
                
                config.message.text(withConfig: config.messageConfig)
                
                if state.hasExpired {
                    
                    config.reason.text(withConfig: config.reasonConfig)
                        .multilineTextAlignment(.center)
                }
            }
            
            state.formattedAmount.text(withConfig: config.amountConfig)
        }
    }
}

struct FraudPaymentCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            fraud(hasExpired: true)
            fraud(hasExpired: false)
        }
    }
    
    static func fraud(hasExpired: Bool) -> some View {
        
        FraudPaymentCompleteView(
            state: .init(
                formattedAmount: "1 000 ₽",
                hasExpired: hasExpired
            ),
            action: {},
            config: .iFora
        )
    }
}
