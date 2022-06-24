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
    
    func makeUIViewController(context: Context) -> UINavigationController {
        
        let vc = PaymentByPhoneViewController(viewModel: PaymentByPhoneViewModel(phoneNumber: viewModel.phoneNumber, bankId: viewModel.bankId, closeAction: viewModel.closeAction))
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel.setBackAction = true
        let navigation = UINavigationController(rootViewController: vc)
        return navigation

    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
