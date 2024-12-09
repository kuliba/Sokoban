//
//  ContactsLatestPaymentsView.swift
//  Vortex
//
//  Created by Max Gribov on 14.11.2022.
//

import SwiftUI

struct ContactsLatestPaymentsSectionView: View {
    
    @ObservedObject var viewModel: ContactsLatestPaymentsSectionViewModel
    
    var body: some View {
       
        LatestPaymentsView(viewModel: viewModel.latestPayments, config: .prod())
    }
}

//MARK: - Preview

struct ContactsLatestPaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContactsLatestPaymentsSectionView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension ContactsLatestPaymentsSectionViewModel {
    
    static let sample = ContactsLatestPaymentsSectionViewModel(latestPayments: .sample, mode: .fastPayment, model: .emptyMock)
}
