//
//  MeToMeExternalView+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 12.07.2022.
//

import Foundation
import SwiftUI

struct MeToMeExternalView: UIViewControllerRepresentable {
    
    let viewModel: MeToMeExternalViewModel
    
    func makeUIViewController(context: Context) -> MeToMeViewController {
        
        let controller = MeToMeViewController(cardFrom: viewModel.productTo?.userAllProducts(), getUImage: viewModel.getUImage)
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MeToMeViewController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
    
}

struct MeToMeExternalViewModel {
    
    let productTo: ProductData?
    let closeAction: () -> Void
    let getUImage: (Md5hash) -> UIImage?
    
    init(
        productTo: ProductData? = nil,
        closeAction: @escaping () -> Void,
        getUImage: @escaping (Md5hash) -> UIImage?
    ) {
        
        self.productTo = productTo
        self.closeAction = closeAction
        self.getUImage = getUImage
    }
}
