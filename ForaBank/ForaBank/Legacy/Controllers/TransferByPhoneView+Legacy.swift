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
    
    func makeUIViewController(context: Context) -> ContactsViewController {
        
        let vc = ContactsViewController()
        vc.modalPresentationStyle = .custom
  
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ContactsViewController, context: Context) {}
}

struct TransferByPhoneViewModel {
    
    var closeAction: () -> Void
}
