//
//  PaymentsServicesLatestPaymentsSectionView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 24.03.2023.
//

import SwiftUI

struct PaymentsServicesLatestPaymentsSectionView: View {
    
    @ObservedObject var viewModel: PaymentsServicesLatestPaymentsSectionViewModel
    
    var config: LatestPaymentButtonLabelConfig = .prod()
    
    var body: some View {
       
        LatestPaymentsView(viewModel: viewModel.latestPayments, config: config)
    }
}

//MARK: - Preview

struct PaymentsServicesLatestPaymentsSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsServicesLatestPaymentsSectionView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension PaymentsServicesLatestPaymentsSectionViewModel {
    
    static let sample = PaymentsServicesLatestPaymentsSectionViewModel(latestPayments: .sample, mode: .fastPayment, model: .emptyMock)
}
