//
//  AuthConfirmViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 09.02.2022.
//

import Foundation
import SwiftUI
import Combine

class AuthConfirmViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    lazy var navigationBar: NavigationBarViewModel = {
        NavigationBarViewModel(action: { [weak self] in
            self?.action.send(AuthConfirmViewModelAction.Dismiss())
        })
    }()
    
    var code: CodeViewModel
    @Published var info: InfoViewModel?
    
    init(code: CodeViewModel, info: InfoViewModel?) {
        
        self.code = code
        self.info = info
    }
}

extension AuthConfirmViewModel {
    
    struct NavigationBarViewModel {
        
        let title = "Вход"
        let backButton: BackButtonViewModel
        
        struct BackButtonViewModel {
            let icon = Image("back_button")
            let action: () -> Void
        }
        
        init(action: @escaping () -> Void) {
            
            self.backButton = BackButtonViewModel(action: action)
        }
    }
    
    class CodeViewModel: ObservableObject {
        
        let title = "Введите код из сообщения"
        @Published var code: [String?] = [nil, nil, nil, nil, nil, nil]
        
    }
    
    class InfoViewModel: ObservableObject {
        
        var title: String
        @Published var subtitle: String?
        @Published var state: State
        
        init(title: String, subtitle: String? = nil, state: State) {
            
            self.title = title
            self.subtitle = subtitle
            self.state = state
        }
        
        init(phoneNumber: String, subtitle: String? = nil, state: State) {
            
            self.title = "Код отправлен на " + phoneNumber
            self.subtitle = subtitle
            self.state = state
        }
        
        enum State {
            
            case timer(TimerViewModel)
            case button(RepeatButtonViewModel)
        }
        
        struct TimerViewModel {
            
            let value: String
        }
        
        struct RepeatButtonViewModel {
            
            let title = "Отправить повторно"
            let action: () -> Void
        }
    }
}

enum AuthConfirmViewModelAction {
    
    struct Dismiss: Action {}
    struct SendAgain: Action {}
    struct ConfirmCode: Action {
        
        let code: String
    }
}

//MARK: - Samples

extension AuthConfirmViewModel {
    
    static let sampleConfirm: AuthConfirmViewModel = {
        
        let codeViewModel = CodeViewModel()
        
        let infoViewModel = InfoViewModel(phoneNumber: "+7 ... ... 54 13", subtitle: nil, state: .timer(.init(value: "00:59")))
        
        let viewModel = AuthConfirmViewModel(code: codeViewModel, info: infoViewModel)
        
        return viewModel
    }()
}
