//
//  QrView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 01.07.2022.
//

import Foundation
import SwiftUI
import Combine

struct QrScannerView: UIViewControllerRepresentable {
        
    let viewModel: QrViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        guard let controller = QRViewController.storyboardInstance() else {
            return UIViewController()
        }
        
        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { controller, _ in
            controller.parent?.navigationController?.isNavigationBarHidden = true
            controller.parent?.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem
            controller.parent?.navigationItem.rightBarButtonItems = controller.navigationItem.rightBarButtonItems
        })
                
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Self.Coordinator { Coordinator() }
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
}

struct QrViewModel {

    let closeAction: (Bool) -> Void
}
