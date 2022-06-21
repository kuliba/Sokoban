//
//  PhonePaymentView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 17.06.2022.
//

import Foundation
import SwiftUI

struct PaymentPhoneView: UIViewControllerRepresentable {
    
    let viewModel: PaymentByPhoneViewModel
    
    func makeUIViewController(context: Context) -> PaymentByPhoneViewController {
        
        let vc = PaymentByPhoneViewController(viewModel: PaymentByPhoneViewModel(phoneNumber: viewModel.phoneNumber, bankId: viewModel.bankId))
        vc.modalPresentationStyle = .fullScreen
  
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PaymentByPhoneViewController, context: Context) {}
}

struct PaymentPhoneViewModel {
    
    var closeAction: () -> Void
}
