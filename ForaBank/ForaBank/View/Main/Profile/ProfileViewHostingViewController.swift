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

    let action: PassthroughSubject<Action, Never> = .init()

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
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case _ as ProductProfileViewModelAction.CustomName:
                    alert = .init(title: "Активировать карту?", message: "После активации карта будет готова к использованию", primary: .init(type: .default, title: "Отмена", action: { [weak self] in
                        self?.alert = nil
                    }), secondary: .init(type: .default, title: "Ok", action: { [weak self] in
                        self?.model.action.send(ModelAction.Card.Unblock.Request(cardId: 1))
                        self?.alert = nil
                    }))
                default:
                    break
                }
            }.store(in: &bindings)
    }
}
