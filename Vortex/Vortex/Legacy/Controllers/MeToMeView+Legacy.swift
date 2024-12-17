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
        
        let model = ConfirmViewControllerModel(type: .card2card, status: .succses)
        
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
                vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
            })
           
            return controller
            
        case let .refill(productData):
            let controller = CustomPopUpWithRateView(cardTo: productData.userAllProducts())
            controller.viewModel = model
            controller.viewModel.closeAction = viewModel.closeAction
            controller.modalPresentationStyle = .custom
            
            return controller
            
        case let .transferDepositRemains(productData, amount):
            let popView = CustomPopUpWithRateView(cardFrom: productData.userAllProducts(), totalAmount: amount)
            popView.depositClose = true
            popView.viewModel = model
            popView.viewModel.closeAction = viewModel.closeAction
            popView.modalPresentationStyle = .custom
            
            return popView
          
        case let .transferBeforeCloseDeposit(productData, amount):
            let popView = CustomPopUpWithRateView(cardFrom: productData.userAllProducts(), totalAmount: amount)
            popView.depositClose = true
            popView.viewModel = model
            popView.meToMeViewModelType = .beforeClosing
            popView.viewModel.closeAction = viewModel.closeAction
            popView.modalPresentationStyle = .custom
            
            return popView
            
        case let .transferDepositInterest(productData, interest):
            let popView = CustomPopUpWithRateView(cardFrom: productData.userAllProducts(), maxSum: interest)
            popView.viewModel = model
            popView.viewModel.closeAction = viewModel.closeAction
            popView.modalPresentationStyle = .custom
            
            return popView
            
        case let .closeAccount(productData, amount):
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
        case transferDepositRemains(ProductData, Double)
        case transferDepositInterest(ProductData, Double)
        case transferBeforeCloseDeposit(ProductData, Double)
        case closeAccount(ProductData, Double)
    }
}

