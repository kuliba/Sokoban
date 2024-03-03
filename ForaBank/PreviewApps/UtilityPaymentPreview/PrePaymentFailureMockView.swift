//
//  PrePaymentFailureMockView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI

struct PrePaymentFailureMockView: View {
    
    let payByInstruction: () -> Void
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Text("Что-то пошло не так.\nПопробуйте позже или воспользуйтесь другим способом оплаты.")
            
            Button("Pay by Instruction", action: payByInstruction)
        }
        .padding()
    }
}

struct PrePaymentFailureView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PrePaymentFailureMockView {}
    }
}
