//
//  RootViewHostingViewController.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation
import SwiftUI
import Combine

class RootViewHostingViewController: UIHostingController<RootView> {
    
    private let viewModel: RootViewModel
    private var bindings = Set<AnyCancellable>()
    
    init(with viewModel: RootViewModel) {
        
        self.viewModel = viewModel
        super.init(rootView: RootView(viewModel: viewModel))
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLogin() {
        
//        viewModel.showLogin()
    }
}
