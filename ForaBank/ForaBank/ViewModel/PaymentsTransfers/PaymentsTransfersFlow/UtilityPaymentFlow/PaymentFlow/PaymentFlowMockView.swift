//
//  PaymentFlowMockView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import SwiftUI

struct PaymentFlowMockView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Button("Payment success") { viewModel.event(.completePayment) }
                .foregroundColor(.blue)
            
            Button("Detect Fraud") { viewModel.event(.detectFraud) }
            
            Button("Produce Payment Error") { viewModel.event(.produceError) }
        }
        .foregroundColor(.red)
        .padding()
    }
}

extension PaymentFlowMockView {
    
    typealias ViewModel = ObservingPaymentFlowMockViewModel
}
