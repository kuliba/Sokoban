//
//  RootViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation
import SwiftUI
import Combine

class RootViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    private var bindings = Set<AnyCancellable>()
    
    private let model: Model
    
    init(_ model: Model) {
        
        self.model = model
        
        bind()
    }
    
    private func bind() {
        
        model.auth
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] auth in
                
                switch auth {
                case .registerRequired:
                    action.send(RootViewModelAction.Cover.ShowLogin(viewModel: loginViewModel(with: model)))
                    
                case .signInRequired(pincode: let pincode):
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel(with: model, pincode: pincode), animated: false))
                    
                case .unlockRequired(pincode: let pincode):
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel(with: model, pincode: pincode), animated: true))
                    
                case .authorized:
                    action.send(RootViewModelAction.Cover.Hide())
                }
                
            }.store(in: &bindings)
    }
    
    private func loginViewModel(with model: Model) -> AuthLoginViewModel {
        
        AuthLoginViewModel(model, rootActions: .init(dismiss: {[weak self] in
            self?.action.send(RootViewModelAction.Cover.Hide())
        }, spinner: .init(show: {[weak self] in
            self?.action.send(RootViewModelAction.Spinner.Show(viewModel: .init()))
        }, hide: {[weak self] in
            self?.action.send(RootViewModelAction.Spinner.Hide())
        })))
    }
    
    private func lockViewModel(with model: Model, pincode: String) -> AuthPinCodeViewModel {
        
        //TODO: pass pincode to AuthPinCodeViewModel
        AuthPinCodeViewModel(model, mode: .unlock(attempt: 0), dismissAction: {[weak self] in
            self?.action.send(RootViewModelAction.Cover.Hide()) })
    }
    
    private func permissionsViewModel(with model: Model, sensorType: BiometricSensorType) -> AuthPermissionsViewModel {
        
        AuthPermissionsViewModel(model, sensorType: sensorType, dismissAction: {[weak self] in
            self?.action.send(RootViewModelAction.Cover.Hide()) })
    }
}

extension RootViewModel {
    
    struct AuthActions {
        
        let dismiss: () -> Void
        let spinner: Spinner
        
        struct Spinner {
            
            let show: () -> Void
            let hide: () -> Void
        }
    }
}

//MARK: - Action

enum RootViewModelAction {
    
    enum Cover {
    
        struct ShowLogin: Action {
            
            let viewModel: AuthLoginViewModel
        }
        
        struct ShowLock: Action {
            
            let viewModel: AuthPinCodeViewModel
            let animated: Bool
        }

        struct Hide: Action {}
    }
    
    enum Spinner {
    
        struct Show: Action {
            
            let viewModel: SpinnerView.ViewModel
        }
        
        struct Hide: Action {}
    }
    
    struct ShowPermissions: Action {
        
        let sensorType: BiometricSensorType
    }
}
