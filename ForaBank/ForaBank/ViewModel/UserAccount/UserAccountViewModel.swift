//
//  UserAccountViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 18.04.2022.
//

import Foundation
import SwiftUI

class UserAccountViewModel: ObservableObject {
    
    let navigationBar: NavigationViewModel
    
    @Published var avatar: AvatarViewModel
    @Published var sections: [AccountSectionViewModel]
    @Published var exitButton: AccountCellFullButtonView.ViewModel
    
    private let model: Model
    
    internal init(model: Model, navigationBar: UserAccountViewModel.NavigationViewModel, avatar: AvatarViewModel, sections: [AccountSectionViewModel]) {
        
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
