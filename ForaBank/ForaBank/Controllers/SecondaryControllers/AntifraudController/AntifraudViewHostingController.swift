//
//  AntifraudViewHostingController.swift
//  ForaBank
//
//  Created by Дмитрий on 11.01.2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class AntifraudViewHostingController: UIHostingController<AntifraudView> {
    
    private let viewModel: AntifraudViewModel
    private var bindings = Set<AnyCancellable>()

    init(with viewModel: AntifraudViewModel) {
        
        self.viewModel = viewModel
        super.init(rootView: AntifraudView(viewModel: viewModel, delegate: ContentViewDelegate()))
        modalPresentationStyle = .custom
        transitioningDelegate = self
        view.backgroundColor = .white
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
                case _ as AntifraudViewModelAction.Cancel:
                    self.dismiss(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name("dismissSwiftUI"), object: nil, userInfo: nil)
                case _ as AntifraudViewModelAction.TimerDismiss:
                    self.dismiss(animated: true)
                    let dic = ["Timer": true]
                    NotificationCenter.default.post(name: NSNotification.Name("dismissSwiftUI"), object: nil, userInfo: dic)
                case _ as AntifraudViewModelAction.Dismiss:
                    self.dismiss(animated: true)
                default:
                    break

                }
                
            }.store(in: &bindings)
    }

}

extension AntifraudViewHostingController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
        presenter.blurEffectView.isUserInteractionEnabled = false

        presenter.height = 460
        
        return presenter
    }
}
