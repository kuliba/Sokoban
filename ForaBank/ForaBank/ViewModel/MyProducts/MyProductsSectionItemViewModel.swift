//
//  MyProductsSectionItemViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 17.04.2022.
//

import Foundation
import Combine
import SwiftUI

class MyProductsSectionItemViewModel: ObservableObject, Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var state: State
    
    let id: String
    let icon: Image
    let paymentSystemIcon: Image
    let balance: String
    let subtitle: String
    let cardType: CardType
    
    private var bindings = Set<AnyCancellable>()
    
    init(id: String = UUID().uuidString,
         icon: Image,
         paymentSystemIcon: Image,
         balance: String,
         subtitle: String,
         state: State,
         cardType: CardType) {
        
        self.id = id
        self.icon = icon
        self.paymentSystemIcon = paymentSystemIcon
        self.balance = balance
        self.subtitle = subtitle
        self.state = state
        self.cardType = cardType
        
        bind()
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as MyProductsSectionItemAction.SwipeDirection.Left:
                    switch self.state {
                    case .normal:
                        withAnimation(.easeInOut(duration: 0.3)) {
                            
                            let viewModel = ActionButtonViewModel(type: .delete) { [weak self] in
                                self?.action.send(MyProductsSectionItemAction.ButtonType.Delete())
                            }
                            
                            self.state = .rightButton(viewModel)
                            
                        }
                    case .leftButton:
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.state = .normal
                        }
                    default:
                        break
                    }
                    
                case _ as MyProductsSectionItemAction.SwipeDirection.Right:
                    switch self.state {
                    case .normal:
                        withAnimation(.easeInOut(duration: 0.3)) {
                            
                            let viewModel = ActionButtonViewModel(type: .activate) { [weak self] in
                                self?.action.send(MyProductsSectionItemAction.ButtonType.Activate())
                            }
                            
                            self.state = .leftButton(viewModel)
                        }
                    case .rightButton:
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.state = .normal
                        }
                    default:
                        break
                    }
                    
                case _ as MyProductsSectionItemAction.ButtonType.Delete:
                    setNormalStateWithAnimation()
                    //TODO: Implementation required
                    
                case _ as MyProductsSectionItemAction.ButtonType.Add:
                    setNormalStateWithAnimation()
                    //TODO: Implementation required
                    
                case _ as MyProductsSectionItemAction.ButtonType.Activate:
                    setNormalStateWithAnimation()
                    //TODO: Implementation required
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
    }
}

extension MyProductsSectionItemViewModel {
    
    enum State {
        
        case normal
        case leftButton(ActionButtonViewModel)
        case rightButton(ActionButtonViewModel)
    }
    
    struct ActionButtonViewModel {
        
        let type: ActionButtonType
        let action: () -> Void
    }
    
    enum ActionButtonType {
        
        case activate
        case add
        case delete
        
        var icon: String? {
            
            switch self {
            case .activate: return "Activate Button Action"
            default: return nil
            }
        }
        
        var title: String {
            
            switch self {
            case .activate: return "Активировать"
            case .add: return "Добавить на главный"
            case .delete: return "Удалить с главного экрана"
            }
        }
        
        var color: Color {
            
            switch self {
            case .activate: return .systemColorActive
            case .add: return .textSecondary
            case .delete: return .textSecondary
            }
        }
    }
    
    enum CardType {
        
        case multibonus
        case digital
        case salary
        case wantCard
        case classic
        case credit
        
        var name: String {
            
            switch self {
            case .multibonus: return "Мультибонус"
            case .digital: return "Цифровая"
            case .salary: return "Зарплатная"
            case .wantCard: return "Хочу карту"
            case .classic: return " Classic"
            case .credit: return "Кредит"
            }
        }
    }
    
    private func setNormalStateWithAnimation() {
        
        withAnimation {
            self.state = .normal
        }
    }
}

enum MyProductsSectionItemAction {
    
    enum ButtonType {
        
        struct Add: Action {}
        struct Delete: Action {}
        struct Activate: Action {}
    }
    
    enum SwipeDirection {
        
        struct Left: Action {}
        struct Right: Action {}
    }
    
    struct Tap: Action {}
}

extension MyProductsSectionItemViewModel {
    
    static let sample1 = MyProductsSectionItemViewModel(
        icon: .init("Multibonus Card"),
        paymentSystemIcon: .init("Logo Visa"),
        balance: "19 547 ₽",
        subtitle: "• 2953 • Дебетовая",
        state: .normal,
        cardType: .multibonus
    )
    
    static let sample2 =  MyProductsSectionItemViewModel(
        icon: .init("Digital Card"),
        paymentSystemIcon: .init("Logo Visa"),
        balance: "19 547 ₽",
        subtitle: "• 2953 • Дебетовая",
        state: .leftButton(.init(type: .activate, action: {})),
        cardType: .digital
    )
    
    static let sample3 =  MyProductsSectionItemViewModel(
        icon: .init("Salary Card"),
        paymentSystemIcon: .init("Logo Visa"),
        balance: "19 547 ₽",
        subtitle: "• 2953 • Дебетовая",
        state: .rightButton(.init(type: .add, action: {})),
        cardType: .salary
    )
    
    static let sample4 =  MyProductsSectionItemViewModel(
        icon: .init("Want Card"),
        paymentSystemIcon: .init(""),
        balance: "19 547 ₽",
        subtitle: "• 2953 • Бесплатно",
        state: .normal,
        cardType: .wantCard
    )
    
    static let sample5 =  MyProductsSectionItemViewModel(
        icon: .init("Classic Card"),
        paymentSystemIcon: .init("Logo Visa"),
        balance: "19 547 ₽",
        subtitle: "• 2953 • Дебетовая",
        state: .normal,
        cardType: .classic
    )
    
    static let sample6 =  MyProductsSectionItemViewModel(
        icon: .init("Multibonus Card"),
        paymentSystemIcon: .init("Logo Visa"),
        balance: "19 547 ₽",
        subtitle: "• 2953 • Дебетовая",
        state: .normal,
        cardType: .credit
    )
}
