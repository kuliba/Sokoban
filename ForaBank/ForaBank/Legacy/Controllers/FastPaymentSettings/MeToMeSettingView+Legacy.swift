//
//  MeToMeSettingView+Legacy.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 21.06.2022.
//

import SwiftUI

struct MeToMeSettingView: UIViewControllerRepresentable {
    
    var viewModel: ViewModel

    func makeUIViewController(context: Context) -> MeToMeSettingViewController {
        
        let controller = MeToMeSettingViewController()
        controller.model = viewModel.model
        controller.newModel = viewModel.newModel
        controller.closeAction = viewModel.closeAction
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MeToMeSettingViewController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
    
    struct ViewModel {
        
        let model: [FastPaymentContractFindListDatum]?
        let newModel: Model
        let closeAction: () -> Void
    }
}


