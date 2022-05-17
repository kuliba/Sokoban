//
//  MyProductsViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 10.04.2022.
//

import Combine
import UIKit
import SwiftUI

class MyProductsViewModel: ObservableObject {

    let action: PassthroughSubject<Action, Never> = .init()

    @Published var currencyMenu: MyProductsСurrencyMenuViewModel?
    @Published var sections: [MyProductsSectionViewModel]

    private let model: Model

    let navigationBar: NavigationViewModel
    let totalMoney: MyProductsMoneyViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    init(navigationBar: NavigationViewModel,
         totalMoney: MyProductsMoneyViewModel,
         sections: [MyProductsSectionViewModel]) {

        self.model = .emptyMock
        self.navigationBar = navigationBar
        self.totalMoney = totalMoney
        self.sections = sections
        
        bind()
    }

    init(_ model: Model) {

        self.model = model
        sections = []
        navigationBar = .init()
        totalMoney = .init()

        bind()
    }

    private func bind() {

        model.products
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in

                var sections: [MyProductsSectionViewModel] = []
                let data = data.sorted(by: { $0.key.order < $1.key.order })

                data.forEach { key, value in

                    switch key {
                    case .card:

                        let items = sectionItems(value: value)

                        sections.append(MyProductsSectionViewModel(
                            title: key.pluralName,
                            items: items,
                            isCollapsed: false,
                            isEnabled: true))

                    case .account:

                        let items = sectionItems(value: value)

                        sections.append(MyProductsSectionViewModel(
                            title: key.pluralName,
                            items: items,
                            isCollapsed: false,
                            isEnabled: true))

                    case .deposit:

                        let items = sectionItems(value: value)

                        sections.append(MyProductsSectionViewModel(
                            title: key.pluralName,
                            items: items,
                            isCollapsed: false,
                            isEnabled: true))

                    case .loan:

                        let items = sectionItems(value: value)

                        sections.append(MyProductsSectionViewModel(
                            title: key.pluralName,
                            items: items,
                            isCollapsed: false,
                            isEnabled: true))
                    }
                }

                guard sections.count > 0 else {
                    return
                }
                
                let balance = sections
                    .flatMap { $0.items }
                    .reduce(into: 0.0) { result, item in

                        result += item.balanceRub
                    }

                totalMoney.balance = "\(balance)"
                self.sections = sections

            }.store(in: &bindings)

        action
            .receive(on: DispatchQueue.main)
            .sink { action in

                switch action {
                case _ as MyProductsNavigationItemAction.Back: break
                case _ as MyProductsNavigationItemAction.Add: break
                default:
                    break
                }
            }.store(in: &bindings)

        totalMoney.currencyButton.$isSelected
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isSelected in

                if isSelected {

                    if currencyMenu == nil {

                        let model = MyProductsСurrencyMenuViewModel(items: [
                            .init(icon: .init("Dollar"),
                                  moneySign: "$",
                                  title: "Доллар США",
                                  subtitle: "936 107"),
                            .init(icon: .init("Swiss Franc"),
                                  moneySign: "₣",
                                  title: "Швейцарский франк",
                                  subtitle: "848 207"),
                            .init(icon: .init("Euro"),
                                  moneySign: "$",
                                  title: "ЕВРО",
                                  subtitle: "787 041"),
                            .init(icon: .init("Pound Sterling"),
                                  moneySign: "₣",
                                  title: "Фунт стерлингов",
                                  subtitle: "669 891")
                        ])

                        withAnimation(.easeInOut(duration: 0.3)) {

                            currencyMenu = model
                        }

                        sections
                            .flatMap { $0.items }
                            .forEach { model in
                                withAnimation {
                                    model.state = .normal
                                }
                            }

                        currencyMenu?.action
                            .receive(on: DispatchQueue.main)
                            .sink { [unowned self] action in

                                switch action {
                                case let model as MyProductsСurrencyMenuAction:

                                    updateTotalMoney(model: model)

                                default:
                                    break
                                }
                            }.store(in: &bindings)

                    }
                } else {
                    currencyMenu = nil
                }

            }.store(in: &bindings)

        let items = sections.flatMap { $0.items }

        for item in items {

            item.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in

                    switch action {
                    case _ as MyProductsSectionItemAction.Tap:
                        items
                            .forEach { model in
                                setStateNormal(model)
                            }
                    default:
                        break
                    }
                }.store(in: &bindings)

            item.$state
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] state in

                    switch state {
                    case .leftButton, .rightButton:
                        items
                            .filter { $0.id != item.id }
                            .forEach { model in
                                setStateNormal(model)
                            }
                    default:
                        break
                    }
                }.store(in: &bindings)
        }

        for section in sections {

            section.$isCollapsed
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in

                    sections
                        .flatMap { $0.items }
                        .forEach { model in
                            setStateNormal(model)
                        }

                }.store(in: &bindings)
        }
    }
}

extension MyProductsViewModel {

    private func updateTotalMoney(model: MyProductsСurrencyMenuAction) {

        deselectedCurrencyButton()

        totalMoney.balance = model.subtitle
        totalMoney.currencyButton.title = model.moneySign

    }

    private func setStateNormal(_ model: MyProductsSectionItemViewModel) {

        deselectedCurrencyButton()

        withAnimation {
            model.state = .normal
        }

    }

    private func deselectedCurrencyButton() {

        guard totalMoney.currencyButton.isSelected else {
            return
        }

        totalMoney.currencyButton.isSelected.toggle()
    }

    private func sectionItems(value: [ProductData]) -> [MyProductsSectionItemViewModel] {

        return value.compactMap { viewModel(data: $0) }
    }

    private func viewModel(data: ProductData) -> MyProductsSectionItemViewModel? {

        switch data.productType {
        case .card: return productCardModel(data: data)
        case .account: return productAccountModel(data: data)
        case .deposit: return productDepositModel(data: data)
        case .loan: return productLoanModel(data: data)
        }
    }

    private func productCardModel(data: ProductData) -> MyProductsSectionItemViewModel? {

        guard
            let icon = data.smallDesign.image,
            let balance = data.balance,
            let balanceRub = data.balanceRub,
            let subtitle = data.additionalField,
            let numberCard = data.numberMasked else {
                return nil
            }

        return MyProductsSectionItemViewModel(
            icon: icon,
            title: data.mainField,
            subtitle: subtitle,
            numberCard: numberCard.count > 0 ? "•  \(numberCard.suffix(4))  •" : numberCard,
            balance: "\(balance)",
            balanceRub: balanceRub)
    }

    private func productAccountModel(data: ProductData) -> MyProductsSectionItemViewModel? {

        guard
            let icon = data.smallDesign.image,
            let balance = data.balance,
            let balanceRub = data.balanceRub,
            let numberCard = data.numberMasked else {
                return nil
            }

        return MyProductsSectionItemViewModel(
            icon: icon,
            title: data.mainField,
            numberCard: numberCard.count > 0 ? "•  \(numberCard.suffix(4))  •" : numberCard,
            balance: "\(balance)",
            balanceRub: balanceRub)
    }

    private func productDepositModel(data: ProductData) -> MyProductsSectionItemViewModel? {

        guard
            let icon = data.smallDesign.image,
            let balance = data.balance,
            let balanceRub = data.balanceRub,
            let numberCard = data.numberMasked else {
                return nil
            }

        return MyProductsSectionItemViewModel(
            icon: icon,
            title: data.mainField,
            numberCard: numberCard.count > 0 ? "•  \(numberCard.suffix(4))  •" : numberCard,
            balance: "\(balance)",
            balanceRub: balanceRub)
    }

    private func productLoanModel(data: ProductData) -> MyProductsSectionItemViewModel? {

        guard
            let icon = data.smallDesign.image,
            let balance = data.balance,
            let balanceRub = data.balanceRub,
            let subtitle = data.additionalField,
            let numberCard = data.numberMasked,
            let loanData = data as? ProductLoanData else {
                return nil
            }

        return MyProductsSectionItemViewModel(
            icon: icon,
            title: data.mainField,
            subtitle: subtitle,
            numberCard: numberCard.count > 0 ? "•  \(numberCard.suffix(4))  •" : numberCard,
            balance: "\(balance)",
            balanceRub: balanceRub,
            dateLong: "•  \(DateFormatter.shortDate.string(from: loanData.dateLong))")
    }
}

extension MyProductsViewModel {
    
    struct NavigationViewModel {

        let title: String
        let backButton: NavigationButtonViewModel
        let addButton: NavigationButtonViewModel

        init() {
            
            title = "Мои продукты"
            backButton = .init(icon: .ic24ChevronLeft)
            addButton = .init(icon: .ic24Plus)
        }

        init(title: String,
             backButton: NavigationButtonViewModel,
             addButton: NavigationButtonViewModel) {

            self.title = title
            self.backButton = backButton
            self.addButton = addButton
        }
    }
    
    struct NavigationButtonViewModel {
        
        let icon: Image
    }
}

enum MyProductsNavigationItemAction {

    struct Back: Action {}
    struct Add: Action {}
}

extension MyProductsViewModel {
    
    static let sample = MyProductsViewModel(
        navigationBar: NavigationViewModel(
            title: "Мои продукты",
            backButton: NavigationButtonViewModel(icon: .ic24ChevronLeft),
            addButton: NavigationButtonViewModel(icon: .ic24Plus)),
        totalMoney: .sample1,
        sections: [.sample1, .sample2, .sample3, .sample4, .sample5, .sample6]
    )
}
