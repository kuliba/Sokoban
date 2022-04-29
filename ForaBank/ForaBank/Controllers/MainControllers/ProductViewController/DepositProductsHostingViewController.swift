//
//  DepositProductsHostingViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 28.04.2022.
//

import Foundation
import SwiftUI
import Combine

class OpenProductHostingViewController: UIHostingController<OpenDepositView> {
    
    private let viewModel: OpenDepositViewModel
    private var bindings = Set<AnyCancellable>()
    
    init(with viewModel: OpenDepositViewModel) {
        
        self.viewModel = viewModel
        super.init(rootView: OpenDepositView(viewModel: viewModel))
        
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
                case _ as OperationDetailViewModelAction.Dismiss:
                    self.dismiss(animated: true)
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}
