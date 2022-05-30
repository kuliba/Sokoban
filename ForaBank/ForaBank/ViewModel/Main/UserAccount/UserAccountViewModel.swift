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
    
    let navigationBar: NavigationViewModel
    
    @Published var avatar: AvatarViewModel
    @Published var sections: [AccountSectionViewModel]
    @Published var exitButton: AccountCellFullButtonView.ViewModel
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(model: Model, navigationBar: UserAccountViewModel.NavigationViewModel, avatar: AvatarViewModel, sections: [AccountSectionViewModel]) {
        
        self.model = model
        self.navigationBar = navigationBar
        self.avatar = avatar
        self.sections = sections
        
        self.exitButton = .init(
            icon: .ic24LogOut,
            content: "Выход из приложения",
            action: {
                print("Exit action")
            })
        
    }
    
    init(model: Model, clientInfo: ClientInfoData) {
        
        //TODO: fill viewModel with ClientInfoData
        
        self.model = model
        self.navigationBar = .init(
            title: "Профиль",
            backButton: .init(icon: .ic24ChevronLeft, action: {
                print("back")
            }),
            rightButton: .init(icon: .ic24Settings, action: {
                print("right")
            }))
        self.avatar = .init(
            image: nil,
            action: {
                print("Open peacker")
            })
        
        self.exitButton = .init(
            icon: .ic24LogOut,
            content: "Выход из приложения",
            action: {
                print("Exit action")
            })
        
        self.sections = []
        
        bind()
        model.action.send(ModelAction.ClientInfo.Fetch.Request())
    }
        
    func bind() {
        
        model.clientInfo
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientInfo in
                
                guard let clientInfo = clientInfo else { return }
                
                createSections(userData: clientInfo)

            }.store(in: &bindings)
        
    }
    
    func createSections(userData: ClientInfoData) {
        
        var accountContactsItems = [
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
            )]
        
        if let email = userData.email {
            accountContactsItems.append(AccountCellInfoView.ViewModel(
                icon: .ic24Mail,
                content: email,
                title: "Электронная почта"
            ))
        }
        
        var accountDocuments: [AccountCellDefaultViewModel] = [
            DocumentCellView.ViewModel(
                itemType: .passport,
                content: userData.pasportNumber,
                action: {
                    print("Open Паспорт")
                    self.link = .userDocument(UserDocumentViewModel(
                        model: self.model, itemType: .passport,
                        navigationBar: .init(
                            title: DocumentCellType.passport.title,
                            backButton: .init(icon: .ic24ChevronLeft, action: {
                                self.link = nil
                            }),
                            rightButton: .init(icon: .ic24Share, action: {
                                print("right")
                            }))))
                    
                })
        ]
        
        if let userInn = userData.INN {
            accountDocuments.append(DocumentCellView.ViewModel(
                itemType: .inn,
                content: userInn,
                action: {
                    print("Open ИНН")
                })
            )
        }
        
        accountDocuments.append(DocumentCellView.ViewModel(
            itemType: .adressPass,
            content: userData.address,
            action: {
                print("Open Адрес регистрации")
//                let pass = UserDocumentViewModel(model: self.model, itemType: .adressPass)
                self.link = .userDocument(UserDocumentViewModel(
                    model: self.model, itemType: .adressPass,
                    navigationBar: .init(
                        title: DocumentCellType.adressPass.title,
                        backButton: .init(icon: .ic24ChevronLeft, action: {
                            self.link = nil
                        }),
                        rightButton: .init(icon: .ic24Share, action: {
                            print("right")
                        })
                    ))
                )
            })
        )
        
        if let addressResidential = userData.addressResidential {
            accountDocuments.append(DocumentCellView.ViewModel(
                itemType: .adress,
                content: addressResidential,
                action: {
                    print("Open Адрес проживания")
                    self.link = .userDocument(UserDocumentViewModel(
                        model: self.model, itemType: .adress,
                        navigationBar: .init(
                            title: DocumentCellType.adress.title,
                            backButton: .init(icon: .ic24ChevronLeft, action: {
                                self.link = nil
                            }),
                            rightButton: .init(icon: .ic24Share, action: {
                                print("right")
                            })
                        ))
                    )
                })
            )
        }
        
        
        self.sections = [
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
        let backButton: NavigationButtonViewModel
        let rightButton: NavigationButtonViewModel
        
        struct NavigationButtonViewModel {
            
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
}

extension UserAccountViewModel.NavigationViewModel {
    
    static let sample = UserAccountViewModel.NavigationViewModel(
        title: "Профиль",
        backButton: .init(icon: .ic24ChevronLeft, action: {
            print("back")
        }),
        rightButton: .init(icon: .ic24Settings, action: {
            print("right")
        }))
}
