//
//  ProductStatementView+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 11.07.2022.
//

import Foundation
import SwiftUI

struct ProductStatementView: UIViewControllerRepresentable {
    
    let viewModel: ProductStatementViewModel
    
    func makeUIViewController(context: Context) -> AccountStatementController {
        
        let controller = AccountStatementController()
        controller.viewModel = viewModel
        controller.startProduct = viewModel.product.userAllProducts()
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.title = vc.navigationItem.title
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AccountStatementController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}

struct ProductStatementViewModel {
    
    let product: ProductData
    let closeAction: () -> Void
    let getUImage: (Md5hash) -> UIImage?

    init(
        product: ProductData,
        closeAction: @escaping () -> Void,
        getUImage: @escaping (Md5hash) -> UIImage?
    ) {
        
        self.product = product
        self.closeAction = closeAction
        self.getUImage = getUImage
    }
}
