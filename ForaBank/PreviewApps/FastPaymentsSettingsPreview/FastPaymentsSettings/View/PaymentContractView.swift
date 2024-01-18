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
    let actionOff: () -> Void
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 16) {
                
                Text(title)
                    .font(.subheadline)
                
                ToggleMockView(status: status)
            }
            
            Button(buttonTitle, action: actionOff)
        }
    }
    
    var buttonTitle: String {
        
        switch paymentContract.contractStatus {
        case .active:   return "Выключить переводы СБП"
        case .inactive: return "Включить переводы СБП"
        }
    }
    
    var title: String {
        
        switch paymentContract.contractStatus {
        case .active:   return "Переводы включены"
        case .inactive: return "Переводы выключены"
        }
    }
    
    var status: ToggleMockView.Status {
        
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
        
        VStack(spacing: 16) {
            
            paymentContractView(.active)
            
            Divider()
            
            paymentContractView(.inactive)
        }
    }
    
    private static func paymentContractView(
        _ paymentContract: PaymentContractView.PaymentContract
    ) -> some View {
        
        PaymentContractView(paymentContract: paymentContract, actionOff: {})
    }
}
