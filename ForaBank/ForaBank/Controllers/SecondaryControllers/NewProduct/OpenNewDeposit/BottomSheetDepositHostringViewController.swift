//
//  BottomSheetDepositHostringViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 04.05.2022.
//

import UIKit
import SwiftUI
import Combine

class BottomSheetDepositHostringViewController: UIHostingController<BottomSheetView<OfferProductView.DetailConditionView>> {
    
    private let viewModel: OfferProductView.ViewModel.AdditionalCondition
    private var bindings = Set<AnyCancellable>()

    init(with viewModel: OfferProductView.ViewModel.AdditionalCondition) {
        
        self.viewModel = viewModel
        super.init(rootView:  BottomSheetView(isOpen: .constant(true), maxHeight: 610) {
            OfferProductView.DetailConditionView(viewModel: .init(desc: [.init(desc: "", enable: true)]))
        })
        modalPresentationStyle = .custom
        transitioningDelegate = self
        view.backgroundColor = .clear
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BottomSheetDepositHostringViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = Int(UIScreen.main.bounds.height)
        
        return presenter
    }
}
