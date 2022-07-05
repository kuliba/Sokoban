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
    
    @Published var selected: TabType

    let mainViewModel: MainViewModel
    let paymentsViewModel: PaymentsTransfersViewModel
    let chatViewModel: ChatViewModel
    let informerViewModel: InformerView.ViewModel
    @Published var alert: Alert.ViewModel?

    private let model: Model
    private var bindings = Set<AnyCancellable>()

    init(_ model: Model) {
        
        self.selected = .main
        self.mainViewModel = MainViewModel(model)
        self.paymentsViewModel = .init(model: model)   //.sample
        self.chatViewModel = .init()
        self.informerViewModel = .init()
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

        model.informer
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in

                withAnimation {
                    informerViewModel.message = data?.message
                }
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.AppVersion.Response:
                 
                    withAnimation {
                        
                        switch payload.result {
                        case let .success(appInfo):
                            
                            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, appInfo.version > appVersion {

                                self.alert = .init(title: "Новая версия", message: "Доступна новая версия \(appInfo.version).", primary: .init(type: .default, title: "Не сейчас", action: {}), secondary: .init(type: .default, title: "Обновить", action: {
                                    guard let url = URL(string: "\(appInfo.trackViewUrl)") else {
                                        return
                                    }
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    
                                }))
                            }
                            
                        case let .failure(error):
                            
                            print("AppVersion Response error: \(error) ")
                        }
                    }
                default:
                    break
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
    
    enum TabType: String, Hashable {
        
        case main
        case payments
        case history
        case chat
        
        var name: String {
            
            switch self {
            case .main: return "Главный"
            case .payments: return "Платежи"
            case .history: return "История"
            case .chat: return "Чат"
            }
        }
        
        //TODO: load images from figma style guide
        func image(for selected: TabType) -> Image {
            
            if self == selected {
                
                switch self {
                case .main: return Image("tabBar-main-fill")
                case .payments: return Image("tabBar-card-fill")
                case .history: return Image("tabBar-history-fill")
                case .chat: return Image("tabBar-chat-fill")
                }
                
            } else {
                
                switch self {
                case .main: return Image("tabBar-main")
                case .payments: return Image("tabBar-card")
                case .history: return Image("tabBar-history")
                case .chat: return Image("tabBar-chat")
                }
            }
        }
    }
    
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
