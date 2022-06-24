//
//  PaymentsHoustingViewController.swift
//  ForaBank
//
//  Created by Max Gribov on 14.03.2022.
//

import UIKit
import SwiftUI
import Combine

class PaymentsHoustingViewController: UIHostingController<PaymentsView> {
    
    private let viewModel: PaymentsViewModel
    private var bindings = Set<AnyCancellable>()
    
    init(with viewModel: PaymentsViewModel) {
        
        self.viewModel = viewModel
        super.init(rootView: PaymentsView(viewModel: viewModel))
        
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


