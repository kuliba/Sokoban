//
//  ChangeReturnView+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 04.07.2022.
//

import SwiftUI

struct ChangeReturnView: UIViewControllerRepresentable {

    let viewModel: ChangeReturnViewModel
    
    func makeUIViewController(context: Context) -> ChangeReturnCountryController {
        var status = ConfirmViewControllerModel.StatusOperation.changeRequest
        switch viewModel.type {
        case .changePay:
            status = .changeRequest
        case .returnPay:
            status = .returnRequest
        }
        
        let confurmVCModel = ConfirmViewControllerModel(type: .contact, status: status)
        confurmVCModel.summTransction = viewModel.amount
        confurmVCModel.name = viewModel.name
        confurmVCModel.surname = viewModel.surname
        confurmVCModel.secondName = viewModel.secondName
        confurmVCModel.paymentOperationDetailId = viewModel.paymentOperationDetailId
        confurmVCModel.numberTransction = viewModel.transferReference
        confurmVCModel.cardFromRealm = viewModel.product.userAllProducts()
        confurmVCModel.operatorImage = viewModel.paymantSystemIcon
        let controller = ChangeReturnCountryController(type: viewModel.type, operatorsViewModel: viewModel.operatorsViewModel)
        controller.confurmVCModel = confurmVCModel
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.title = vc.navigationItem.title
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })

        return controller
    }
    
    func updateUIViewController(_ uiViewController: ChangeReturnCountryController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}


struct ChangeReturnViewModel {
    
    let amount: String
    let name: String
    let surname: String
    let secondName: String
    let paymentOperationDetailId: Int
    let transferReference: String
    let product: ProductData
    let paymantSystemIcon: String
    let type: ChangeReturnCountryController.ChangeReturnType
    let operatorsViewModel: OperatorsViewModel
}
