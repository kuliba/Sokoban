//
//  RootViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation
import SwiftUI
import Combine

class RootViewModel: ObservableObject, Resetable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var selected: TabType
    @Published var alert: Alert.ViewModel?
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var informerViewModel: InformerView.ViewModel?
    
    let mainViewModel: MainViewModel
    let paymentsViewModel: PaymentsTransfersViewModel
    let chatViewModel: ChatViewModel
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(_ model: Model) {
        
        self.selected = .main
        self.mainViewModel = MainViewModel(model)
        self.paymentsViewModel = .init(model: model)
        self.chatViewModel = .init()
        self.model = model
        
        mainViewModel.rootActions = rootActions
        
        bind()
    }
    
    func reset() {
        
        mainViewModel.reset()
        paymentsViewModel.reset()
        chatViewModel.reset()
    }
    
    private func bind() {
        
        model.auth
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] auth in
                
                switch auth {
                case .registerRequired:
                    let loginViewModel = AuthLoginViewModel(model, rootActions: rootActions)
                    action.send(RootViewModelAction.Cover.ShowLogin(viewModel: loginViewModel))
                    
                case .signInRequired:
                    let lockViewModel = AuthPinCodeViewModel(model, mode: .unlock(attempt: 0, auto: true), rootActions: rootActions)
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel, animated: false))
                    
                case .unlockRequired:
                    let lockViewModel = AuthPinCodeViewModel(model, mode: .unlock(attempt: 0, auto: true), rootActions: rootActions)
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel, animated: true))
                    action.send(RootViewModelAction.DismissAll())
                    action.send(RootViewModelAction.SwitchTab(tabType: .main))
                
                case .unlockRequiredManual:
                    let lockViewModel = AuthPinCodeViewModel(model, mode: .unlock(attempt: 0, auto: false), rootActions: rootActions)
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel, animated: true))
                    action.send(RootViewModelAction.DismissAll())
                    action.send(RootViewModelAction.SwitchTab(tabType: .main))
                    
                case .authorized:
                    action.send(RootViewModelAction.Cover.Hide())
                    action.send(RootViewModelAction.DismissAll())
                    
                    switch model.notificationsTransition.value {
                    case .history:
                        let messagesHistoryViewModel: MessagesHistoryViewModel = .init(model: model, closeAction: {[weak self] in self?.link = nil })
                        link = .messages(messagesHistoryViewModel)
                        model.notificationsTransition.value = nil
                        
                    case .me2me(let requestMeToMeModel):
                        link = .me2me(requestMeToMeModel)
                        model.notificationsTransition.value = nil

                    default:
                        break
                    } 
                }
                
            }.store(in: &bindings)
        
        model.informer
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                guard let informerData = data else {
                    return
                }
                
                if informerViewModel == nil {
                    
                    informerViewModel = .init {
                        
                        self.informerViewModel = nil
                        self.model.informer.value = nil
                    }
                }
                
                withAnimation {
                    
                    if let informerViewModel = informerViewModel {
                        informerViewModel.informers.append(informerData)
                    }
                }
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as RootViewModelAction.SwitchTab:
                    withAnimation {
                        selected = payload.tabType
                    }
                    
                case _ as RootViewModelAction.DismissAll:
                    reset()
                    
                case _ as RootViewModelAction.C2bShow:
                    link = .c2b
                
                case _ as RootViewModelAction.CloseAlert:
                    alert = nil
                    
                default:
                    break
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
                            
                            break
                            //TODO: set logger
                        }
                    }
                case let payload as ModelAction.Consent.Me2MeDebit.Response:
                    switch payload.result {
                    case .success(let consentData):
                        
                        self.action.send(RootViewModelAction.DismissAll())
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {

                            self.link = .me2me(.init(model: consentData.getConcentLegacy()))
                        }
                        
                    case .failure(let error):
                        
                        break
                        //TODO: set logger
                    }
                default:
                    break
                }
            }.store(in: &bindings)
        
        model.notificationsTransition
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] transition in
                
                if model.auth.value == .authorized {
                 
                    switch transition {
                    case .history:
                        
                        self.rootActions.dismissAll()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {

                            let messagesHistoryViewModel: MessagesHistoryViewModel = .init(model: self.model, closeAction: {[weak self] in self?.link = nil })
                            self.link = .messages(messagesHistoryViewModel)
                            self.model.notificationsTransition.value = nil
                            
                        }

                    case .me2me(let requestMeToMeModel):
                        link = .me2me(requestMeToMeModel)
                        model.notificationsTransition.value = nil

                    default:
                        break
                    }
                }
                
            }.store(in: &bindings)
    }
    
    lazy var rootActions: RootViewModel.RootActions = {
        
        let dismissCover: (() -> Void) = { [weak self] in
            
            self?.action.send(RootViewModelAction.Cover.Hide())
        }
        
        let spinnerShow: (() -> Void) = { [weak self] in
            
            self?.action.send(RootViewModelAction.Spinner.Show(viewModel: .init()))
        }
        
        let spinnerHide: (() -> Void) = { [weak self] in
            
            self?.action.send(RootViewModelAction.Spinner.Hide())
        }
        
        let switchTab: ((RootViewModel.TabType) -> Void) = { [weak self] tabType in
            
            self?.action.send(RootViewModelAction.SwitchTab(tabType: tabType))
        }
        
        let dismissAll: (() -> Void) = { [weak self] in
            
            self?.action.send(RootViewModelAction.DismissAll())
        }
        
        return .init(dismissCover: dismissCover, spinner: .init(show: spinnerShow, hide: spinnerHide), switchTab: switchTab, dismissAll: dismissAll)
    }()
}

//MARK: - Types

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
    }
    
    struct RootActions {
        
        let dismissCover: () -> Void
        let spinner: Spinner
        let switchTab: (RootViewModel.TabType) -> Void
        let dismissAll: () -> Void
        
        struct Spinner {
            
            let show: () -> Void
            let hide: () -> Void
        }
    }
    
    enum Link {
        
        case messages(MessagesHistoryViewModel)
        case me2me(RequestMeToMeModel)
        case c2b
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
    
    struct SwitchTab: Action {
        
        let tabType: RootViewModel.TabType
    }
    
    struct DismissAll: Action {}
    
    struct CloseAlert: Action {}
    
    struct C2bShow: Action {}
}
