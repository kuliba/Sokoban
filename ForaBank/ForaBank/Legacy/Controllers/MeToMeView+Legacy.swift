//
//  MeToMeViewController+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 30.05.2022.
//

import Foundation
import SwiftUI

struct MeToMeView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> CustomPopUpWithRateView {
        
        let model = ConfirmViewControllerModel(type: .card2card)
        let popView = CustomPopUpWithRateView()
        popView.viewModel = model
        popView.modalPresentationStyle = .custom
  
        return popView
    }
    
    func updateUIViewController(_ uiViewController: CustomPopUpWithRateView, context: Context) {}
}
