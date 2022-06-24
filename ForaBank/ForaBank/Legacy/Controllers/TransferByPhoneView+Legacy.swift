//
//  TransferByPhoneView.swift
//  ForaBank
//
//  Created by Дмитрий on 06.06.2022.
//

import Foundation
import SwiftUI

struct TransferByPhoneView: UIViewControllerRepresentable {
    
    let viewModel: TransferByPhoneViewModel
    
    func makeUIViewController(context: Context) -> UINavigationController {
        
        let vc = ContactsViewController()
        vc.modalPresentationStyle = .custom
        vc.viewModel = viewModel
        let navigation = UINavigationController(rootViewController: vc)
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct TransferByPhoneViewModel {
    
    let closeAction: () -> Void
}
