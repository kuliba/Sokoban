//
//  PaymentFlowMockView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

import SwiftUI

struct PaymentFlowMockView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
     
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        VStack(spacing: 32) {
                        
            Button("Detect Fraud", action: viewModel.detectFraud)
                .foregroundColor(.red)
        }
    }
}

extension PaymentFlowMockView {
    
    typealias ViewModel = PaymentFlowMockViewModel
}
