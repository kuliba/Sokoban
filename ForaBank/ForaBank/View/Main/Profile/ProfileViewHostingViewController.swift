//
//  ProfileViewHostingViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 21.04.2022.
//

import Foundation
import SwiftUI
import Combine

class ProfileViewHostingViewController: UIHostingController<ProfileView> {

    private let viewModel: ProfileViewModel
    private var bindings = Set<AnyCancellable>()
    private let model: Model

    @Published var alert: Alert.ViewModel?

    init(with viewModel: ProfileViewModel, model: Model) {
        
        self.viewModel = viewModel
        self.model = model
        super.init(rootView: ProfileView(viewModel: viewModel))

        bind()
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ProfileViewHostingViewController {
    
    func bind() {
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                    
                case _ as ProductProfileViewModelAction.Dismiss:
                    self.dismiss(animated: true)
                case _ as ProductProfileViewModelAction.CustomName:
                    let viewController = AccountDetailsViewController()
                    viewController.modalPresentationStyle = .custom
                    self.present(viewController, animated: true, completion: nil)
                default:
                    break
                }
            }.store(in: &bindings)
    }
}
