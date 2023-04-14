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
        
        let controller = PaymentByPhoneViewController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.title = vc.navigationItem.title
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PaymentByPhoneViewController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}
