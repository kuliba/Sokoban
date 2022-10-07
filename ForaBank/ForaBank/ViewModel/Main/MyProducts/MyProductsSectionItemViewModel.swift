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
    
    let id: ProductData.ID
    
    let title: String
    let subtitle: String?
    
    internal init(id: Int, title: String, subtitle: String?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}

class MyProductsSectionButtonItemViewModel: MyProductsSectionItemViewModel {

    let type: ButtonItemType
    let icon: Image
    
    init(type: ButtonItemType) {
        
        self.type = type
        self.icon = type.icon
        
        super.init(id: Int.random(in: -9000000000 ..< -8000000000), title: type.title, subtitle: type.subtitle)
    }
    
    enum ButtonItemType {
        
        case card
        case deposit
        
        var icon: Image {
            switch self {
            case .card: return .ic24NewCardColor
            case .deposit: return .ic24DepositPlusColor
            }
        }
        
        var title: String {
            switch self {
            case .card:
                return "Хочу карту"
            case .deposit:
                return "Хочу вклад"
            }
        }
        
        var subtitle: String {
            return "Бесплатно"
        }
    }
    
}

class MyProductsSectionProductItemViewModel: MyProductsSectionItemViewModel {
    
    @Published var state: State
    @Published var isMainScreenHidden: Bool
    
    let icon: Image?
    let number: String
    let numberCard: String
    let balance: String
    let paymentSystemIcon: Image?
    let balanceRub: Double
    let dateLong: String?
    let isNeedsActivated: Bool
    
    private var bindings = Set<AnyCancellable>()
    
    init(id: Int,
         icon: Image?,
         title: String,
         subtitle: String? = nil,
         number: String,
         numberCard: String,
         balance: String,
         balanceRub: Double = 0,
         dateLong: String? = nil,
         isNeedsActivated: Bool = false,
         isMainScreenHidden: Bool = false,
         paymentSystemIcon: Image? = nil,
         state: State = .normal) {
        
        self.icon = icon
        self.number = number
        self.numberCard = numberCard
        self.balance = balance
        self.paymentSystemIcon = paymentSystemIcon
        self.balanceRub = balanceRub
        self.dateLong = dateLong
        self.isNeedsActivated = isNeedsActivated
        self.isMainScreenHidden = isMainScreenHidden
        self.state = state
        
        super.init(id: id, title: title, subtitle: subtitle)
        
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
                            
                            let viewModel = ActionButtonViewModel(type: isMainScreenHidden ? .add : .delete) { [weak self] in
                                self?.action.send(MyProductsSectionItemAction.ButtonType.Hidden(productID: id))
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

                                self?.action.send(MyProductsSectionItemAction.ButtonType.Activate(cardID: id, cardNumber: number))
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
                    
                case _ as MyProductsSectionItemAction.ButtonType.Hidden:
                    setNormalStateWithAnimation()
                    
                case _ as MyProductsSectionItemAction.ButtonType.Add:
                    setNormalStateWithAnimation()
                    //TODO: Implementation required
                    
                case _ as MyProductsSectionItemAction.ButtonType.Activate:
                    setNormalStateWithAnimation()
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
    }
}

extension MyProductsSectionProductItemViewModel {

    var currencyBalance: String {
        NumberFormatter.currency(balance: balance)
    }

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

        struct Hidden: Action {

            let productID: ProductData.ID
        }

        struct Activate: Action {

            let cardID: Int
            let cardNumber: String
        }
    }
    
    enum SwipeDirection {
        
        struct Left: Action {}
        struct Right: Action {}
    }
    
    struct Tap: Action {
        let productId: ProductData.ID
    }
    
    struct PlaceholderTap: Action {
        let type: MyProductsSectionButtonItemViewModel.ButtonItemType
    }
    
}

extension MyProductsSectionItemViewModel {

    static let sample1 = MyProductsSectionProductItemViewModel(
        id: 10002585800,
        icon: .init("Multibonus Card"),
        title: "Кредит",
        subtitle: "Дебетовая",
        number: "4444555566661120",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        dateLong: "•  29.08.22",
        paymentSystemIcon: .init("Logo Visa")
    )

    static let sample2 = MyProductsSectionProductItemViewModel(
        id: 10002585801,
        icon: .init("Digital Card"),
        title: "Цифровая",
        subtitle: "Дебетовая",
        number: "4444555566661121",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        paymentSystemIcon: .init("Logo Visa"))

    static let sample3 = MyProductsSectionProductItemViewModel(
        id: 10002585802,
        icon: .init("Salary Card"),
        title: "Зарплатная",
        subtitle: "Дебетовая",
        number: "4444555566661122",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        paymentSystemIcon: .init("Logo Visa"))

    static let sample4 = MyProductsSectionProductItemViewModel(
        id: 10002585803,
        icon: .init("Want Card"),
        title: "Хочу карту",
        subtitle: "Бесплатно",
        number: "4444555566661123",
        numberCard: "•  2953  •",
        balance: "19 547 ₽")

    static let sample5 = MyProductsSectionProductItemViewModel(
        id: 10002585804,
        icon: .init("Classic Card"),
        title: "Classic",
        subtitle: "Дебетовая",
        number: "4444555566661124",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        paymentSystemIcon: .init("Logo Visa"))

    static let sample6 = MyProductsSectionProductItemViewModel(
        id: 10002585805,
        icon: .init("Multibonus Card"),
        title: "Мультибонус",
        subtitle: "Дебетовая",
        number: "4444555566661125",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        paymentSystemIcon: .init("Logo Visa"))

    static let sample7 = MyProductsSectionProductItemViewModel(
        id: 10002585806,
        icon: .init("Multibonus Card"),
        title: "Кредит",
        subtitle: "Дебетовая",
        number: "4444555566661126",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        dateLong: "•  29.08.22",
        paymentSystemIcon: .init("Logo Visa"))

    static let sample8 = MyProductsSectionProductItemViewModel(
        id: 10002585807,
        icon: .init("Digital Card"),
        title: "Цифровая",
        subtitle: "Дебетовая",
        number: "4444555566661127",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        paymentSystemIcon: .init("Logo Visa"),
        state: .leftButton(.init(type: .activate, action: {})))

    static let sample9 = MyProductsSectionProductItemViewModel(
        id: 10002585808,
        icon: .init("Salary Card"),
        title: "Зарплатная",
        subtitle: "Дебетовая",
        number: "4444555566661128",
        numberCard: "•  2953  •",
        balance: "19 547 ₽",
        paymentSystemIcon: .init("Logo Visa"),
        state: .rightButton(.init(type: .add, action: {})))
    
    static let sample10 = MyProductsSectionButtonItemViewModel(type: .card)
    
}
