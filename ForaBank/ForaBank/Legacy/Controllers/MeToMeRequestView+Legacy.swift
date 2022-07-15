//
//  MeToMeRequestView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 15.07.2022.
//

import Foundation
import SwiftUI

struct MeToMeRequestView: UIViewControllerRepresentable {
    
    let viewModel: RequestMeToMeModel
    
    func makeUIViewController(context: Context) -> MeToMeRequestController {
        
        let controller = MeToMeRequestController()
        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MeToMeRequestController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
    
}

