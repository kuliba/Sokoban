//
//  MobilePayView.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.06.2022.
//

import Foundation
import SwiftUI

struct MobilePayView: UIViewControllerRepresentable {
    
    var viewModel: MobilePayViewModel
    
    func makeUIViewController(context: Context) -> UINavigationController {
        
        let controller = MobilePayViewController()
        controller.viewModel = viewModel
        let navigation = UINavigationController(rootViewController: controller)
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct MobilePayViewModel {
    
    var closeAction: () -> Void
}
