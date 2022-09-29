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
    
    let mainViewModel: MainViewModel
    let paymentsViewModel: PaymentsTransfersViewModel
    let chatViewModel: ChatViewModel
    let informerViewModel: InformerView.ViewModel
    
    var coverPresented: RootViewHostingViewController.Cover.Kind?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    private var auithBinding: AnyCancellable?
    
    init(_ model: Model) {
        
        self.selected = .main
        self.mainViewModel = MainViewModel(model)
        self.paymentsViewModel = .init(model: model)
        self.chatViewModel = .init()
        self.informerViewModel = .init(model)
        self.model = model
        
        mainViewModel.rootActions = rootActions
                
        bindAuth()
    }
    
    func reset() {
        
        mainViewModel.reset()
        paymentsViewModel.reset()
        chatViewModel.reset()
    }
    

    
    private func bindAuth() {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "bind auth")
        
        auithBinding = model.auth
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] auth in
                
                switch auth {
                case .registerRequired:
                    guard coverPresented != .login else {
                        return
                    }
                    
                    resetRootView()
                    
                    let loginViewModel = AuthLoginViewModel(model, rootActions: rootActions)
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.Cover.ShowLogin")
                    action.send(RootViewModelAction.Cover.ShowLogin(viewModel: loginViewModel))
                    
                case .signInRequired:
                    guard coverPresented != .lock else {
                        return
                    }
                    
                    resetRootView()
                    
                    let lockViewModel = AuthPinCodeViewModel(model, mode: .unlock(attempt: 0, auto: true), rootActions: rootActions)
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.Cover.ShowLock, animated: false")
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel, animated: false))
                    
                case .unlockRequired:
                    guard coverPresented != .lock else {
                        return
                    }
                    
                    resetRootView()
                    
                    let lockViewModel = AuthPinCodeViewModel(model, mode: .unlock(attempt: 0, auto: true), rootActions: rootActions)
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.Cover.ShowLock, animated: true")
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel, animated: true))
                
                case .unlockRequiredManual:
                    guard coverPresented != .lock else {
                        return
                    }
                    
                    resetRootView()
                    
                    let lockViewModel = AuthPinCodeViewModel(model, mode: .unlock(attempt: 0, auto: false), rootActions: rootActions)
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.Cover.ShowLock, animated: true")
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel, animated: true))
                    
                case .authorized:
                    resetRootView()
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.Cover.Hide")
                    action.send(RootViewModelAction.Cover.Hide())
                }
            }
    }
    
    fileprivate func resetRootView() {
        
        LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.DismissAll")
        action.send(RootViewModelAction.DismissAll())
        
        LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.SwitchTab, type: .main")
        action.send(RootViewModelAction.SwitchTab(tabType: .main))
    }
    
    private func bind() {

        model.informer
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                withAnimation {
                    informerViewModel.message = data?.message
                }
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as RootViewModelAction.Appear:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.Appear")
                    bindAuth()
                    
                case let payload as RootViewModelAction.SwitchTab:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.SwitchTab, tab: .\(payload.tabType.rawValue)")
                    withAnimation {
                        selected = payload.tabType
                    }
                    
                case _ as RootViewModelAction.DismissAll:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.DismissAll")
                    reset()
                    
                case let payload as RootViewModelAction.ShowUserProfile:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.ShowUserProfile")
                    guard let clientInfo = model.clientInfo.value else {
                        return
                    }
                    link = .userAccount(.init(model: model, clientInfo: clientInfo, dismissAction: {[weak self] in
                        self?.action.send(RootViewModelAction.CloseLink())
                    }, bottomSheet: .init(sheetType: .sbpay(.init(model, personAgreements: payload.conditions, rootActions: rootActions)))))
                
                case _ as RootViewModelAction.CloseAlert:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.CloseAlert")
                    alert = nil
                    
                case _ as RootViewModelAction.CloseLink:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.CloseLink")
                    link = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)

        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                
                case let payload as ModelAction.DeepLink.Process:
                    
                    switch payload.type {
                    case let .me2me(bankId):
                        self.action.send(ModelAction.Consent.Me2MeDebit.Request(bankid: bankId))
                        model.action.send(ModelAction.DeepLink.Clear())

                    case let .c2b(urlString):
                        GlobalModule.c2bURL = urlString
                        link = .c2b(.init(closeAction: {[weak self] in
                            self?.action.send(RootViewModelAction.CloseLink())
                        }))
                        model.action.send(ModelAction.DeepLink.Clear())

                    case let .sbpPay(tokenIntent):
                        self.action.send(ModelAction.SbpPay.Register.Request(tokenIntent: tokenIntent))
                        self.action.send(ModelAction.FastPaymentSettings.ContractFindList.Request())
                    }
                    
                case let payload as ModelAction.Notification.Transition.Process:
                    
                    switch payload.transition {
                    case .history:
                        self.rootActions.dismissAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                            
                            let messagesHistoryViewModel: MessagesHistoryViewModel = .init(model: self.model, closeAction: {[weak self] in self?.action.send(RootViewModelAction.CloseLink()) })
                            self.link = .messages(messagesHistoryViewModel)
                            self.model.action.send(ModelAction.Notification.Transition.Clear())
                        }
                        
                    case .me2me(let requestMeToMeModel):
                        link = .me2me(requestMeToMeModel)
                        self.model.action.send(ModelAction.Notification.Transition.Clear())
                    }
                    
                case let payload as ModelAction.AppVersion.Response:
                    
                    withAnimation {
                        
                        switch payload.result {
                        case let .success(appInfo):
                            LoggerAgent.shared.log(level: .debug, category: .ui, message: "received ModelAction.AppVersion.Response, success, info: \(appInfo)")
                            
                            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, appInfo.version > appVersion {
                                
                                self.alert = .init(title: "Новая версия", message: "Доступна новая версия \(appInfo.version).", primary: .init(type: .default, title: "Не сейчас", action: {}), secondary: .init(type: .default, title: "Обновить", action: {
                                    guard let url = URL(string: "\(appInfo.trackViewUrl)") else {
                                        return
                                    }
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    
                                }))
                            }
                            
                        case let .failure(error):
                            LoggerAgent.shared.log(level: .error, category: .ui, message: "received ModelAction.AppVersion.Response, failure, error: \(error.localizedDescription)")
                        }
                    }
                case let payload as ModelAction.Consent.Me2MeDebit.Response:
                    switch payload.result {
                    case .success(let consentData):
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "received ModelAction.Consent.Me2MeDebit.Response, success, consentData: \(consentData)")
                        
                        self.action.send(RootViewModelAction.DismissAll())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {

                            self.link = .me2me(.init(model: consentData.getConcentLegacy()))
                        }
                        
                    case .failure(let error):
                        LoggerAgent.shared.log(level: .error, category: .ui, message: "received ModelAction.Consent.Me2MeDebit.Response, failure, error: \(error.localizedDescription)")
                    }
                    
                case let payload as ModelAction.SbpPay.Register.Response:
                    switch payload.result {
                    case .success:
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "received ModelAction.SbpPay.Register.Response, success")
                        self.model.action.send(ModelAction.GetPersonAgreement.Request(system: .sbp, type: nil))
                    case .failed:
                        LoggerAgent.shared.log(level: .error, category: .ui, message: "received ModelAction.SbpPay.Register.Response, failed")
                    }
                case let payload as ModelAction.GetPersonAgreement.Response:
                    switch payload.result {
                    case let .success(personAgreement):
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "received ModelAction.GetPersonAgreement.Response, success, personAgreement: \(personAgreement)")
                        
                        self.action.send(RootViewModelAction.DismissAll())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {

                            self.action.send(RootViewModelAction.ShowUserProfile(conditions: personAgreement))
                        }
                        
                    case let .failure(error):
                        LoggerAgent.shared.log(level: .error, category: .ui, message: "received ModelAction.GetPersonAgreement.Response, failure, error: \(error.localizedDescription)")
                    }
                    
                default:
                    break
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
        case c2b(C2BViewModel)
        case userAccount(UserAccountViewModel)
    }
}

//MARK: - Action

enum RootViewModelAction {
    
    struct Appear: Action {}
    
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
    
    struct CloseLink: Action {}
    
    struct ShowUserProfile: Action {
        
        let conditions: [PersonAgreement]
    }
}
