//
//  InfoViewHostingViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 31.03.2022.
//

import UIKit
import SwiftUI
import Combine

class BottomSheetHostingViewController: UIHostingController<BottomSheetView<InfoView>> {
    
    private let viewModel: InfoView.ViewModel
    private var bindings = Set<AnyCancellable>()

    init(with viewModel: InfoView.ViewModel) {
        
        self.viewModel = viewModel
        super.init(rootView:  BottomSheetView(isOpen: .constant(true), maxHeight: 260) {
            InfoView(viewModel: .init())
        })
        modalPresentationStyle = .custom
        transitioningDelegate = self
        view.backgroundColor = .clear
        bind()
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self = self else {
                    return
                }
                
                switch action {
                case _ as InfoView.ViewModelAction.Dismiss:
                    self.dismiss(animated: true)
                default:
                    break

                }
                
            }.store(in: &bindings)
    }
    
}

extension BottomSheetHostingViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = Int(UIScreen.main.bounds.height)
        
        return presenter
    }
}

