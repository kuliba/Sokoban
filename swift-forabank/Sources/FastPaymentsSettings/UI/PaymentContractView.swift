//
//  PaymentContractView.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import SwiftUI
import UIPrimitives

struct PaymentContractView: View {
    
    let paymentContract: PaymentContract
    let action: () -> Void
    let config: PaymentContractConfig
    
    var body: some View {
        
        VStack(alignment: .leading) {

            labeledToggle()
            
            subtitleView()
        }
        .foregroundColor(.secondary)
    }

    private func labeledToggle() -> some View {
        
        Button(action: action) {
            
            HStack {
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                ToggleMockView(status: status, color: color)
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
                AttributedTextView(
                    attributedString: .consent,
                    linkColor: .red
                )
            }
        }
        .font(.subheadline)
    }
    
    private var status: ToggleMockView.Status {
        
        switch paymentContract.contractStatus {
        case .active:   return .on(.enabled)
        case .inactive: return .off(.enabled)
        }
    }
    
    private var color: Color {
        
        switch paymentContract.contractStatus {
        case .active:   return config.active.toggleColor
        case .inactive: return config.inactive.toggleColor
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
        
        PaymentContractView(
            paymentContract: paymentContract,
            action: {},
            config: .preview
        )
    }
}
