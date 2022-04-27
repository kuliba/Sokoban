//
//  MainViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation
import Combine
import SwiftUI

class MainViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()

    lazy var userAccountButton: UserAccountButtonViewModel = UserAccountButtonViewModel(logo: .ic12LogoForaColor, avatar: nil, name: "Александр", action: { [weak self] in self?.action.send(MainViewModelAction.ButtonTapped.UserAccount())})
    @Published var navButtonsRight: [NavBarButtonViewModel]
    @Published var sections: [MainSectionViewModel]
    @Published var isRefreshing: Bool
    
    private var bindings = Set<AnyCancellable>()
    
    init(navButtonsRight: [NavBarButtonViewModel], sections: [MainSectionViewModel], isRefreshing: Bool) {
        
        self.navButtonsRight = navButtonsRight
        self.sections = sections
        self.isRefreshing = isRefreshing
    }
}

extension MainViewModel {
    
    class UserAccountButtonViewModel: ObservableObject {
        
        @Published var logo: Image
        @Published var avatar: Image?
        @Published var name: String
        let action: () -> Void
        
        init(logo: Image, avatar: Image?, name: String, action: @escaping () -> Void) {
            
            self.logo = logo
            self.avatar = avatar
            self.name = name
            self.action = action
        }
    }
    
    struct NavBarButtonViewModel: Identifiable {
        
        let id: UUID = UUID()
        let icon: Image
        let action: () -> Void
    }
}

enum MainViewModelAction {

    enum ButtonTapped {
        
        struct UserAccount: Action {}
    }
}

