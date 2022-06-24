//
//  MeToMeViewController+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 30.05.2022.
//

import Foundation
import SwiftUI

struct MeToMeView: UIViewControllerRepresentable {
    
    let viewModel: MeToMeViewModel
    
    func makeUIViewController(context: Context) -> CustomPopUpWithRateView {
        
        let model = ConfirmViewControllerModel(type: .card2card)
        let popView = CustomPopUpWithRateView()
        popView.viewModel = model
        popView.viewModel.closeAction = viewModel.closeAction
        popView.modalPresentationStyle = .custom
  
        return popView
    }
    
    func updateUIViewController(_ uiViewController: CustomPopUpWithRateView, context: Context) {}
}

struct MeToMeViewModel {
    
    let closeAction: () -> Void
}
