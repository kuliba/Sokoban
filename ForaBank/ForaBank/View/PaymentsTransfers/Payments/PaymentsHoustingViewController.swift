//
//  PaymentsHoustingViewController.swift
//  ForaBank
//
//  Created by Max Gribov on 14.03.2022.
//

import UIKit
import SwiftUI
import Combine

struct PaymentsHostingViewControllerViewFactory {
    
    let makePaymentsView: MakePaymentsView
}

class PaymentsHoustingViewController: UIHostingController<PaymentsView> {
    
    private let viewModel: PaymentsViewModel
    private let viewFactory: PaymentsHostingViewControllerViewFactory
    private var bindings = Set<AnyCancellable>()
    
    init(with viewModel: PaymentsViewModel, viewFactory: PaymentsHostingViewControllerViewFactory) {
        
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        super.init(rootView: viewFactory.makePaymentsView(viewModel))
        
        bind()
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self = self else {
                    return
                }
                
                switch action {
                case _ as PaymentsViewModelAction.Dismiss:
                    self.dismiss(animated: true)

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}


