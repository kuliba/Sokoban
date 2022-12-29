//
//  C2BDetailsViewController+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 27.07.2022.
//

import Foundation
import SwiftUI
import Combine

struct C2BDetailsView: UIViewControllerRepresentable {
    
    let viewModel: C2BViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        guard let controller = C2BDetailsViewController.storyboardInstance() else {
            return UIViewController()
        }
        
        controller.modalPresentationStyle = .fullScreen
        controller.closeAction = viewModel.closeAction
        controller.viewModel = .init(urlString: viewModel.urlString)

        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}

struct C2BViewModel {
    
    let urlString: String
    let closeAction: () -> Void

    init(urlString: String, closeAction: @escaping () -> Void) {

        self.urlString = urlString
        self.closeAction = closeAction
    }
}
