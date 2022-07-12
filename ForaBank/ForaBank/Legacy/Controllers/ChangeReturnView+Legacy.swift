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
        
        let confurmVCModel = ConfirmViewControllerModel(type: .contact)
        confurmVCModel.summTransction = viewModel.amount
        confurmVCModel.name = viewModel.name
        confurmVCModel.surname = viewModel.surname
        confurmVCModel.secondName = viewModel.secondName
        confurmVCModel.paymentOperationDetailId = viewModel.paymentOperationDetailId
        confurmVCModel.numberTransction = viewModel.transferReference
        confurmVCModel.cardFromRealm = viewModel.product.userAllProducts()
        let controller = ChangeReturnCountryController(type: viewModel.type, operatorsViewModel: viewModel.operatorsViewModel)
        controller.confurmVCModel = confurmVCModel

        return controller
    }
    
    func updateUIViewController(_ uiViewController: ChangeReturnCountryController, context: Context) {}
}


struct ChangeReturnViewModel {
    
    let amount: String
    let name: String
    let surname: String
    let secondName: String
    let paymentOperationDetailId: Int
    let transferReference: String
    let product: ProductData
    let type: ChangeReturnCountryController.ChangeReturnType
    let operatorsViewModel: OperatorsViewModel
}
