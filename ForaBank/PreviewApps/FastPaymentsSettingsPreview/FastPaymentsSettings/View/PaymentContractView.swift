//
//  PaymentContractView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct PaymentContractView: View {
    
    let paymentContract: PaymentContract
    let action: () -> Void
    
    var body: some View {
        
        VStack(alignment: .leading) {

            labeledToggle()
            
            subtitleView()
        }
    }

    private func labeledToggle() -> some View {
        
        HStack {
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Button(action: action) {
                
                ToggleMockView(status: status)
            }
        }
    }
    
    private var title: String { "Включить переводы СБП" }
    
    @ViewBuilder
    private func subtitleView() -> some View {
        
        Group {
            switch paymentContract.contractStatus {
            case .active:
                Text("Настройки для входящих и исходящих переводов СБП  ")
                
            case .inactive:
#warning("link inside!!!")
                Text("Подключая возможность осуществлять переводы денежных средств в рамках СБП, соглашаюсь с условиями осуществления переводов СБП")
            }
        }
        .foregroundColor(.secondary)
        .font(.subheadline)
    }
    
    private var status: ToggleMockView.Status {
        
        switch paymentContract.contractStatus {
        case .active:   return .active
        case .inactive: return .inactive
        }
    }
}

extension PaymentContractView {
    
    typealias PaymentContract = UserPaymentSettings.PaymentContract
}

struct PaymentContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            paymentContractView(.active)
            
            Divider()
            
            paymentContractView(.inactive)
        }
        .padding()
    }
    
    private static func paymentContractView(
        _ paymentContract: PaymentContractView.PaymentContract
    ) -> some View {
        
        PaymentContractView(paymentContract: paymentContract, action: {})
    }
}
