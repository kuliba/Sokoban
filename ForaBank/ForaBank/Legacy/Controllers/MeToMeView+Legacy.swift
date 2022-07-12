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
        
        switch viewModel.type {
        case .general:
            let controller = CustomPopUpWithRateView()
            controller.viewModel = model
            controller.viewModel.closeAction = viewModel.closeAction
            controller.modalPresentationStyle = .custom
            
            return controller
            
        case let .template(paymentTemplateData):
            let controller = CustomPopUpWithRateView(paymentTemplate: paymentTemplateData)
            controller.viewModel = model
            controller.viewModel.closeAction = viewModel.closeAction
            controller.modalPresentationStyle = .fullScreen
            
            context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
                vc.parent?.navigationItem.title = vc.navigationItem.title
                vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
                vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
            })
            
            return controller
            
        case let .refill(productData):
            let controller = CustomPopUpWithRateView(cardTo: productData.userAllProducts())
            controller.viewModel = model
            controller.viewModel.closeAction = viewModel.closeAction
            controller.modalPresentationStyle = .custom
            
            return controller
            
        case let .transferDeposit(productData, amount):
            let popView = CustomPopUpWithRateView(cardFrom: productData.userAllProducts(), totalAmount: amount)
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
    
    let type: Kind
    let closeAction: () -> Void
 
    init(type: Kind = .general, closeAction: @escaping () -> Void) {
        
        self.type = type
        self.closeAction = closeAction
    }
    
    enum Kind {
        case general
        case template(PaymentTemplateData)
        case refill(ProductData)
        case transferDeposit(ProductData, Double)
    }
}

