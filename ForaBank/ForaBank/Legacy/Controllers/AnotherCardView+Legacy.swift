//
//  AnotherCardView+Legacy.swift
//  ForaBank
//
//  Created by Mikhail on 17.06.2022.
//

import Foundation
import SwiftUI

struct AnotherCardView: UIViewControllerRepresentable {
    
    let viewModel: AnotherCardViewModel
    
    func makeUIViewController(context: Context) -> MemeDetailVC {
        
        let popView = MemeDetailVC()
        popView.anotherCardModel = viewModel
        popView.modalPresentationStyle = .custom
        popView.transitioningDelegate = context.coordinator
        return popView
    }
    
    func updateUIViewController(_ uiViewController: MemeDetailVC, context: Context) {}
    
    class Coordinator: NSObject, UIViewControllerTransitioningDelegate {
        
        func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
            let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
            presenter.height = 490
            return presenter
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}


struct AnotherCardViewModel {
    
    var closeAction: () -> Void
}
