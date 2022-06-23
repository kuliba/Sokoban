//
//  MeToMeSettingView+Legacy.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 21.06.2022.
//

import SwiftUI

struct MeToMeSettingView: UIViewControllerRepresentable {
    
    var viewModel: ViewModel

    func makeUIViewController(context: Context) -> UINavigationController {
        
        let vc = MeToMeSettingViewController()
        vc.model = viewModel.model
        vc.newModel = viewModel.newModel
        let navigation = UINavigationController(rootViewController: vc)
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    struct ViewModel {
        let model: [FastPaymentContractFindListDatum]?
        let newModel: Model
        let closeAction: () -> Void
    }
    
    
}


