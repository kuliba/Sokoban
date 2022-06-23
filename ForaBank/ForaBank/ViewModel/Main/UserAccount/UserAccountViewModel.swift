//
//  UserAccountViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 18.04.2022.
//

import Foundation
import SwiftUI
import Combine

class UserAccountViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let navigationBar: NavigationBarView.ViewModel
    
    @Published var avatar: AvatarViewModel?
    @Published var sections: [AccountSectionViewModel]
    @Published var exitButton: AccountCellFullButtonView.ViewModel? = nil
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var bottomSheet: BottomSheet?
    @Published var sheet: Sheet?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(navigationBar: NavigationBarView.ViewModel, avatar: AvatarViewModel, sections: [AccountSectionViewModel], exitButton: AccountCellFullButtonView.ViewModel, model: Model = .emptyMock) {
        
        self.model = model
        self.navigationBar = navigationBar
        self.avatar = avatar
        self.sections = sections
        self.exitButton = exitButton
        
    }
    
    init(model: Model, clientInfo: ClientInfoData) {
        
        self.model = model
        sections = []
        navigationBar = .init(title: "Профиль", leftButtons: [
            NavigationBarView.ViewModel.BackButtonViewModel(icon: .ic24ChevronLeft)
        ])
        
        avatar = .init(
            image: nil, action: { [weak self] in
                self?.action.send(UserAccountModelAction.AvatarAction())
            })
        
        exitButton = .init(
            icon: .ic24LogOut, content: "Выход из приложения", action: { [weak self] in
                self?.action.send(UserAccountModelAction.ExitAction())
            })
        
        navigationBar.rightButtons = [
            .init(icon: .ic24Settings, action: { [weak self] in
                self?.action.send(UserAccountModelAction.SettingsAction())
            })]
        
        bind()
//        model.action.send(ModelAction.ClientInfo.Fetch.Request())
    }
        
    func bind() {
        
        model.clientInfo
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientInfo in
                
                guard let clientInfo = clientInfo else { return }
                sections = createSections(userData: clientInfo)
                bind(sections)
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {

                case _ as UserAccountModelAction.AvatarAction:
                    print("Open AvatarAction")
                    
                case _ as UserAccountModelAction.SettingsAction:
                    print("Open SettingsAction")
                    
                case _ as UserAccountModelAction.ExitAction:
                    print("Open ExitAction")
                    
                default:
                    break
                    
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ sections: [AccountSectionViewModel]) {
        
        for section in sections {
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {

                    case _ as UserAccountModelAction.ChangeUserName:
                        print("Open Изменить Имя")
                        
                    case _ as UserAccountModelAction.OpenFastPayment:
                        let viewModel = MeToMeSettingView.ViewModel
                            .init(model: model.fastPaymentContractFullInfo.value
                                .map { $0.getFastPaymentContractFindListDatum() },
                                  newModel: model,
                                  closeAction: { [weak self] in self?.link = nil })
                        link = .fastPaymentSettings(viewModel)
                       
                        print("Open FastPayment")
                        
                    case let payload as UserAccountModelAction.Switch:
                        switch payload.type {
                            
                        case .faceId:
                            print("Open FaceIdSwitch", payload.value)
                            
                        case .notification:
                            print("Open NotificationSwitch", payload.value)
                        }
                        
                    case let payload as UserAccountModelAction.OpenDocument:
                        guard let clientInfo = model.clientInfo.value else { return }
                        switch payload.type {
                            
                        case .passport:
                            
                            self.sheet = .init(sheetType: .userDocument(.init(clientInfo: clientInfo, itemType: .passport)))
                            
                        case .inn:
                            
                            guard let inn = clientInfo.INN else { return }
                            self.bottomSheet = .init(sheetType: .inn(.init(itemType: payload.type, content: inn)))
                            
                        case .adressPass:
                            
                            self.bottomSheet = .init(sheetType: .inn(.init(itemType: payload.type, content: clientInfo.address)))
                            
                        case .adress:
                            
                            guard let addressResidential = clientInfo.addressResidential else { return }
                            self.bottomSheet = .init(sheetType: .inn(.init(itemType: payload.type, content: addressResidential)))
                        }
                        
                    default:
                        break
                        
                    }
                    
                }.store(in: &bindings)
        }
    }
    
    func createSections(userData: ClientInfoData) -> [AccountSectionViewModel] {
        [
            UserAccountContactsView.ViewModel(userData: userData, isCollapsed: false),
            UserAccountDocumentsView.ViewModel(userData: userData, isCollapsed: false),
            UserAccountPaymentsView.ViewModel(isCollapsed: false),
            UserAccountSecurityView.ViewModel(isActiveFaceId: false, isActivePush: true, isCollapsed: false)
        ]
    }
}

extension UserAccountViewModel {
    
    class AvatarViewModel: ObservableObject {
        
        @Published var image: Image?
        let action: () -> Void
        
        internal init(image: Image?, action: @escaping () -> Void) {
            self.image = image
            self.action = action
        }
    }
    
    class AccountSectionViewModel: ObservableObject, Identifiable {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        var id: String { type.rawValue }
        var type: AccountSectionType { fatalError("Implement in subclass")}
    }

    class AccountSectionCollapsableViewModel: AccountSectionViewModel {
        
        var title: String { type.name }
        @Published var isCollapsed: Bool
        
        init(isCollapsed: Bool) {
            
            self.isCollapsed = isCollapsed
            super.init()
        }
    }

    enum AccountSectionType: String, CaseIterable, Codable {
        
        case contacts
        case documents
        case payments
        case security
        
        var name: String {
            
            switch self {
            case .contacts: return "Контакты"
            case .documents: return "Документы"
            case .payments: return "Платежи и переводы"
            case .security: return "Безопасность"
            }
        }
    }
    
    enum Link {
        
        case userDocument(UserDocumentViewModel)
        case fastPaymentSettings(MeToMeSettingView.ViewModel)
    }
    

    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            case userDocument(UserDocumentViewModel)
        }
    }
    
    struct BottomSheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            case inn(UserAccountDocumentInfoView.ViewModel)
        }
    }
    
}

enum UserAccountModelAction {

    struct PullToRefresh: Action {}
    
    struct CloseLink: Action {}
    
    struct ChangeUserName: Action {}
    
    struct AvatarAction: Action {}
    
    struct SettingsAction: Action {}
    
    struct ExitAction: Action {}
    
    struct OpenDocument: Action {
        let type: DocumentCellType
    }
    
    struct OpenFastPayment: Action {}
    
    struct Switch: Action {
        
        let type: AccountCellSwitchView.ViewModel.Kind
        let value: Bool
    }
}
