//
//  MeToMeViewController+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 30.05.2022.
//

import Foundation
import SwiftUI

struct MeToMeView: UIViewControllerRepresentable {
    
    let viewModel: MeToMeViewModel
    
    func makeUIViewController(context: Context) -> CustomPopUpWithRateView {
        
        let model = ConfirmViewControllerModel(type: .card2card)
        
        if let paymentTemplate = viewModel.paymentTemplate {
            
            let popView = CustomPopUpWithRateView(paymentTemplate: paymentTemplate)
            popView.viewModel = model
            popView.viewModel.closeAction = viewModel.closeAction
            popView.modalPresentationStyle = .fullScreen
            
            context.coordinator.parentObserver = popView.observe(\.parent, changeHandler: { vc, _ in
                vc.parent?.navigationItem.title = vc.navigationItem.title
                vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
                vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
            })
            
            return popView
            
        } else {
            
            let popView = CustomPopUpWithRateView()
            popView.viewModel = model
            popView.viewModel.closeAction = viewModel.closeAction
            popView.modalPresentationStyle = .custom
            
            return popView
        }
    }
    
    func updateUIViewController(_ uiViewController: CustomPopUpWithRateView, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
    
}

struct MeToMeViewModel {
    
    let closeAction: () -> Void
    let paymentTemplate: PaymentTemplateData?
    
    init(closeAction: @escaping () -> Void, paymentTemplate: PaymentTemplateData? = nil) {
        
        self.closeAction = closeAction
        self.paymentTemplate = paymentTemplate
    }
}

