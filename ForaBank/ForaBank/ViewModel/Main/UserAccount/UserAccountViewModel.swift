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
    
    let navigationBar: NavigationBarView.ViewModel
    
    @Published var avatar: AvatarViewModel?
    @Published var sections: [AccountSectionViewModel]
    @Published var exitButton: AccountCellFullButtonView.ViewModel? = nil
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
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
    
    init(model: Model, clientInfo: ClientInfoData, dismissAction: @escaping () -> Void) {
        
        //TODO: fill viewModel with ClientInfoData
        
        self.model = model
        sections = []
        navigationBar = .init(
            title: "Профиль",
            leftButtons: [
                .init(icon: .ic24ChevronLeft, action: {
                    dismissAction()
                })
            ]
        )
        
        avatar = .init(
            image: nil,
            action: {
                self.openPeackerAction()
            })
        
        exitButton = .init(
            icon: .ic24LogOut,
            content: "Выход из приложения",
            action: {
                self.exitAction()
            })
        
        navigationBar.rightButtons = [
            .init(icon: .ic24Settings, action: {
                self.settingsAction()
            })]
        
        bind()
        model.action.send(ModelAction.ClientInfo.Fetch.Request())
    }
        
    func bind() {
        
        model.clientInfo
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientInfo in
                
                guard let clientInfo = clientInfo else { return }
                
                sections = createSections(userData: clientInfo)

            }.store(in: &bindings)
        
    }
    
    func settingsAction() {
        
    }
    
    func openPeackerAction() {
        
    }
    
    func exitAction() {
        
    }
    
    func createSections(userData: ClientInfoData) -> [AccountSectionViewModel] {
        
        let accountContactsItems = [
            AccountCellButtonView.ViewModel(
                icon: .ic24User,
                content: userData.firstName,
                title: "Имя",
                button: .init(icon: .ic24Edit2, action: {
                    print("Open Изменить Имя")
                } )
            ),
            
            AccountCellInfoView.ViewModel(
                icon: .ic24Smartphone,
                content: userData.phone,
                title: "Телефон"
            ),
            
            AccountCellInfoView.ViewModel(
                icon: .ic24Mail,
                content: userData.email ?? "",
                title: "Электронная почта"
            )
        ]
                
        var accountDocuments: [AccountCellDefaultViewModel] = [
            DocumentCellView.ViewModel(
                itemType: .passport,
                content: userData.pasportNumber,
                action: {
                    
                    self.link = .userDocument(UserDocumentViewModel(
                        clientInfo: userData, itemType: .passport, dismissAction: {
                            self.link = nil
                            self.isLinkActive = false
                        }
                    ))
                })
        ]
        
        if let userInn = userData.INN {
            accountDocuments.append(DocumentCellView.ViewModel(
                itemType: .inn,
                content: userInn,
                action: {
                    print("Open ИНН")
                    
                    let button = ButtonSimpleView.ViewModel(
                        title: "Скопировать",
                        style: .gray,
                        action: {
//                            button.title = "Скопировано"
//                            button.style = .inactive
                            print("Скопировано")
                        }
                    )
                    
                    let innViewModel = UserAccountDocumentInfoView.ViewModel(
                        itemType: .inn,
                        content: userInn
                    )
                    
                    self.sheet = .init(sheetType: .inn(innViewModel))
                    
                })
            )
        }
        
        accountDocuments.append(DocumentCellView.ViewModel(
            itemType: .adressPass,
            content: userData.address,
            action: {
                print("Open Адрес регистрации")
                                
                self.sheet = .init(sheetType: .inn(.init(
                    itemType: .adressPass,
                    content: userData.address
                )))
            })
        )
        
        if let addressResidential = userData.addressResidential {
            accountDocuments.append(DocumentCellView.ViewModel(
                itemType: .adress,
                content: addressResidential,
                action: {
                    print("Open Адрес проживания")
                    self.sheet = .init(sheetType: .inn(.init(
                        itemType: .adressPass,
                        content: userData.address
                    )))
                })
            )
        }
        
        return [
            UserAccountContactsView.ViewModel(
                items: accountContactsItems,
                isCollapsed: false),
            
            UserAccountDocumentsView.ViewModel(
                items: accountDocuments,
                isCollapsed: false),
            
            UserAccountPaymentsView.ViewModel(
                items: [
                    AccountCellButtonView.ViewModel(
                        icon: Image("sbp-logo"),
                        content: "Система быстрых платежей",
                        button: .init(icon: .ic24ChevronRight, action: {
                            print("Open Система быстрых платежей")
                        }))
                ],
                isCollapsed: false),
            
            UserAccountSecurityView.ViewModel(
                items: [
                    AccountCellSwitchView.ViewModel(
                        content: "Вход по Face ID",
                        icon: .ic24FaceId),
                    
                    AccountCellSwitchView.ViewModel(
                        content: "Push-уведомления",
                        icon: .ic24Bell)],
                isCollapsed: false)
        ]
    }
    
}


extension UserAccountViewModel {
    
    struct NavigationViewModel {
        
        let title: String
        let backButton: ButtonViewModel
        let settingsButton: ButtonViewModel
        
        struct ButtonViewModel {
            
            let icon: Image
            let action: () -> Void
            
            init(icon: Image, action: @escaping () -> Void) {
                
                self.icon = icon
                self.action = action
            }
        }
    }
    
    class AvatarViewModel: ObservableObject {
        
        @Published var image: Image?
        let action: () -> Void
        
        internal init(image: Image?, action: @escaping () -> Void) {
            self.image = image
            self.action = action
        }
    }
    
    class AccountSectionViewModel: ObservableObject, Identifiable {
        
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
    }
    

    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            case inn(UserAccountDocumentInfoView.ViewModel)
            case button
        }
    }
}

extension UserAccountViewModel.NavigationViewModel {
    
    static let sample = UserAccountViewModel.NavigationViewModel(
        title: "Профиль",
        backButton: .init(icon: .ic24ChevronLeft, action: {
            print("back")
        }),
        settingsButton: .init(icon: .ic24Settings, action: {
            print("right")
        }))
}
