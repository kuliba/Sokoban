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
    
    func makeUIViewController(context: Context) -> TransferByRequisitesViewController {
        
        let popView = TransferByRequisitesViewController()
        popView.modalPresentationStyle = .fullScreen
  
        return popView
    }
    
    func updateUIViewController(_ uiViewController: TransferByRequisitesViewController, context: Context) {}
}

struct TransferByRequisitesViewModel {
    
    var closeAction: () -> Void
}
