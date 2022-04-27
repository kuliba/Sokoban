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
    let title: String
    let subtitle: String
    let numberCard: String
    let balance: String
    let paymentSystemIcon: Image?
    let balanceRub: Double
    let dateLong: String
    
    private var bindings = Set<AnyCancellable>()
    
    init(id: String = UUID().uuidString,
         icon: Image,
         title: String,
         subtitle: String,
         numberCard: String,
         balance: String,
         balanceRub: Double = 0,
         dateLong: String = "",
         paymentSystemIcon: Image? = nil,
         state: State = .normal) {
        
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.numberCard = numberCard
        self.balance = balance
        self.paymentSystemIcon = paymentSystemIcon
        self.balanceRub = balanceRub
        self.dateLong = dateLong
        self.state = state
        
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
        title: "Кредит",
        subtitle: "Дебетовая",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        dateLong: "•  29.08.22",
        paymentSystemIcon: .init("Logo Visa")
    )

    static let sample2 = MyProductsSectionItemViewModel(
        icon: .init("Digital Card"),
        title: "Цифровая",
        subtitle: "Дебетовая",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        paymentSystemIcon: .init("Logo Visa"),
        state: .leftButton(.init(type: .activate, action: {}))
    )

    static let sample3 = MyProductsSectionItemViewModel(
        icon: .init("Salary Card"),
        title: "Зарплатная",
        subtitle: "Дебетовая",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        paymentSystemIcon: .init("Logo Visa"),
        state: .rightButton(.init(type: .add, action: {}))
    )

    static let sample4 = MyProductsSectionItemViewModel(
        icon: .init("Want Card"),
        title: "Хочу карту",
        subtitle: "Бесплатно",
        numberCard: "•  2953  •",
        balance: "19 547 ₽"
    )

    static let sample5 = MyProductsSectionItemViewModel(
        icon: .init("Classic Card"),
        title: "Classic",
        subtitle: "Дебетовая",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        paymentSystemIcon: .init("Logo Visa")
    )

    static let sample6 = MyProductsSectionItemViewModel(
        icon: .init("Multibonus Card"),
        title: "Мультибонус",
        subtitle: "Дебетовая",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        paymentSystemIcon: .init("Logo Visa")
    )
}
