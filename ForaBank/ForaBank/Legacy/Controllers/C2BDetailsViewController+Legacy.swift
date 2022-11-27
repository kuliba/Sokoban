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
    
    func makeUIViewController(context: Context) -> UINavigationController {
        guard let controller = C2BDetailsViewController.storyboardInstance() else {
            return UINavigationController()
        }
        
        controller.modalPresentationStyle = .fullScreen
        controller.closeAction = viewModel.closeAction
        controller.viewModel = .init(qrViewModel: viewModel)

        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return .init(rootViewController: controller)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}

struct C2BViewModel {
    
    let closeAction: () -> Void
    let mode:  Mode
    
    enum Mode {
        
        case general
        case c2bURL(URL)
    }
    
    init(closeAction: @escaping () -> Void, mode: Mode) {

        self.closeAction = closeAction
        self.mode = mode
        GlobalModule.c2bURL = "success"
    }
}
