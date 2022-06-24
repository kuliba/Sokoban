//
//  TransferByRequisitsView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 14.06.2022.
//

import Foundation
import SwiftUI

struct TransferByRequisitesView: UIViewControllerRepresentable {
    
    let viewModel: TransferByRequisitesViewModel
    
    func makeUIViewController(context: Context) -> UINavigationController {
        
        let vc = TransferByRequisitesViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel.closeAction = viewModel.closeAction

        let navigation = UINavigationController(rootViewController: vc)
        return navigation
  
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct TransferByRequisitesViewModel {
    
    let closeAction: () -> Void
}
