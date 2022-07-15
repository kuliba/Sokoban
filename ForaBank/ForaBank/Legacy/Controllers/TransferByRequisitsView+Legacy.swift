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
        
        let controller = setupController(viewModel.type)
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return controller
    }
    
    func setupController(_ type: TransferByRequisitesViewModel.Kind) -> TransferByRequisitesViewController {
        
        switch type {
            
        case .general:
            let controller = TransferByRequisitesViewController()
            controller.viewModel.closeAction = viewModel.closeAction
            return controller
            
        case .template(let templateData):
            
            switch templateData.type {
            case .externalEntity:
                
                let controller = TransferByRequisitesViewController(orgPaymentTemplate: templateData)
                controller.viewModel.closeAction = viewModel.closeAction
                return controller

            default:
                
                let controller = TransferByRequisitesViewController(paymentTemplate: templateData)
                controller.viewModel.closeAction = viewModel.closeAction
                return controller

            }
        }
    }
    
    func updateUIViewController(_ uiViewController: TransferByRequisitesViewController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}

struct TransferByRequisitesViewModel {
    
    let closeAction: () -> Void
    let type: Kind
    
    init(type: Kind = .general, closeAction: @escaping () -> Void) {
        
        self.closeAction = closeAction
        self.type = type
    }
    
    enum Kind {
        
        case general
        case template(PaymentTemplateData)
    }
}
