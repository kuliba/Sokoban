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

    let navigationBar: NavigationBarView.ViewModel
    let totalMoney: MyProductsMoneyViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    init(navigationBar: NavigationBarView.ViewModel,
         totalMoney: MyProductsMoneyViewModel,
         sections: [MyProductsSectionViewModel]) {

        self.model = .emptyMock
        self.navigationBar = navigationBar
        self.totalMoney = totalMoney
        self.sections = sections
        
        bind()
    }

    init(_ model: Model, dismissAction: @escaping () -> Void) {

        self.model = model
        sections = []
        
        navigationBar = .init(title: "Мои продукты",
                              leftButtons: [ NavigationBarView.ViewModel.BackButtonViewModel
                                .init(icon: .ic24ChevronLeft, action: dismissAction) ],
                              background: .barsTabbar)
        totalMoney = .init()
        
        bind()
    }

    private func bind() {

        model.products
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] products in

                var sections: [MyProductsSectionViewModel] = []
                let productsSorted = products.sorted(by: { $0.key.order < $1.key.order })

                productsSorted.forEach { key, value in

                    switch key {
                    case .card:

                        let activatedCards = value.filter { isActivatedCard($0) && !isBlockedCards($0) }
                        var items = sectionItems(value: activatedCards)
                        items.append(MyProductsSectionButtonItemViewModel(type: .card))
                        sections.append(MyProductsSectionViewModel(productType: key, items: items))

                        let notActivatedCards = value.filter { isNotActivatedCard($0) }
                        if !notActivatedCards.isEmpty {
                            
                            let notActivatedSection = MyProductsSectionViewModel(
                                id: MyProductsSectionViewModel.notAcivatedSectionId, title: "Неактивированные продукты",
                                items: sectionItems(value: notActivatedCards),
                                isCollapsed: false,
                                isEnabled: true)
                            sections.append(notActivatedSection)
                            
                        }
                        
                        let blockedCards = value.filter { isBlockedCards($0) }
                        if blockedCards.isEmpty { return }
                        
                        let blockedSection = MyProductsSectionViewModel(
                            id: MyProductsSectionViewModel.blockedSectionId, title: "Заблокированные продукты",
                            items: sectionItems(value: blockedCards),
                            isCollapsed: false,
                            isEnabled: true)
                        
                        sections.append(blockedSection)
                        
                    case .account:

                        let items = sectionItems(value: value)
                        sections.append(MyProductsSectionViewModel(productType: key, items: items))

                    case .deposit:

                        var items = sectionItems(value: value)
                        items.append(MyProductsSectionButtonItemViewModel(type: .deposit))
                        sections.append(MyProductsSectionViewModel(productType: key, items: items))
                        
                    case .loan:

                        let items = sectionItems(value: value)
                        sections.append(MyProductsSectionViewModel(productType: key, items: items))
                    }
                }

                if !sections.contains(where: { $0.id == ProductType.deposit.rawValue }) {
                    
                    let items = [MyProductsSectionButtonItemViewModel(type: .deposit)]
                    sections.append(MyProductsSectionViewModel(productType: .deposit, items: items))
                }
                
                if !sections.contains(where: { $0.id == ProductType.card.rawValue }) {
                    
                    let items = [MyProductsSectionButtonItemViewModel(type: .card)]
                    sections.append(MyProductsSectionViewModel(productType: .card, items: items))
                }
                
                var sortedSections = [MyProductsSectionViewModel]()
                
                for type in ProductType.allCases {
                    
                    guard let section = sections.first(where: { $0.id == type.rawValue }) else { continue }
                    sortedSections.append(section)
                }
                
                if let notAcivatedSection = sections.first(where: { $0.id == MyProductsSectionViewModel.notAcivatedSectionId }) {
                    sortedSections.insert(notAcivatedSection, at: 0)
                }
                
                if let notAcivatedSection = sections.first(where: { $0.id == MyProductsSectionViewModel.blockedSectionId }) {
                    sortedSections.append(notAcivatedSection)
                }
                
                
                let balance = products.values
                    .flatMap({ $0 })
                    .reduce(into: 0.0) { result, item in
                        result += item.balanceRub ?? 0
                        
                    }
                
                totalMoney.updateBalance(balance: balance)
                
                update(sortedSections, with: model.settingsProductsSections)
                
                self.sections = sortedSections
                bind(sections)

            }.store(in: &bindings)

        model.productsHidden
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] productsHidden in

                let items = sections.flatMap { $0.items }
                for item in items {
                    switch item {
                        
                    case let item as MyProductsSectionProductItemViewModel:
                        
                        if model.productsHidden.value.contains(item.id) {
                            item.isMainScreenHidden = true
                        } else {
                            item.isMainScreenHidden = false
                        }
                    
                    default: break
                    }
                }
            }.store(in: &bindings)

        $sections
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] sections in

                let items = sections.flatMap { $0.items }

                for item in items {

                    switch item {
                        
                    case let item as MyProductsSectionProductItemViewModel:
                    
                    item.action
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] action in

                            switch action {
                            case let payload as MyProductsSectionItemAction.ButtonType.Activate:

                                let modelAction = ModelAction.Products.ActivateCard.Request(cardID: payload.cardID, cardNumber: payload.cardNumber)

                                model.action.send(modelAction)

                            case let payload as MyProductsSectionItemAction.ButtonType.Hidden:

                                model.action.send(ModelAction.Settings.UpdateProductsHidden(productID: payload.productID))

                            case let payload as MyProductsSectionItemAction.Tap:
                                items.forEach { model in
                                    
                                    setStateNormal(model)
                                }
                                self.action.send(MyProductsViewModelAction.Tapped.Product(productId: payload.productId))
                                
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
                        
                        
                    case let item as MyProductsSectionButtonItemViewModel:
                        item.action
                            .receive(on: DispatchQueue.main)
                            .sink { [unowned self] action in

                                switch action {
                                case let payload as MyProductsSectionItemAction.PlaceholderTap:
                                    switch payload.type {
                                    case .card:
                                        let url = URL(string: "https://promo.forabank.ru/")!
                                        UIApplication.shared.open(url)
                                        
                                    case .deposit:
                                        self.action.send(MyProductsViewModelAction.Tapped.OpenDeposit())
                                    }
                                    
                                default:
                                    break
                                }
                                
                            }.store(in: &bindings)
                        
                    default: break
                    }
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
            }.store(in: &bindings)
    }
    
    private func bind(_ sections: [MyProductsSectionViewModel]) {
        
        for section in sections {
            
            section.$isCollapsed
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isCollapsed in
            
                    var settings = model.settingsProductsSections
                    settings.update(sectionType: section.id, isCollapsed: isCollapsed)
                    model.settingsProductsSectionsUpdate(settings)
            
                }.store(in: &bindings)
        }
    }
    
    private func update(_ sections: [MyProductsSectionViewModel],
                        with settings: ProductsSectionsSettings) {
        
        for section in sections {
            
            if let isCollapsed = settings.collapsed[section.id] {
                
                section.isCollapsed = isCollapsed
                
            } else {
                
                section.isCollapsed = false
            }
        }
    }
    
}

extension MyProductsViewModel {

    private func setStateNormal(_ model: MyProductsSectionItemViewModel) {
        if let model = model as? MyProductsSectionProductItemViewModel {
            withAnimation {
                model.state = .normal
            }
        }
    }

    private func sectionItems(value: [ProductData]) -> [MyProductsSectionItemViewModel] {

        return value.compactMap { viewModel(data: $0) }
    }

    private func viewModel(data: ProductData) -> MyProductsSectionItemViewModel? {
        
        let icon = ProductView.ViewModel.backgroundImage(with: data, size: .small)
        let name = ProductView.ViewModel.name(product: data, style: .main)
        let subtitle = createSubtitle(from: data)
        let number = "• \(data.displayNumber ?? "")"
        let balance = balanceFormatted(product: data)
        let balanceRub = data.balanceRub ?? 0
        let dateLong = dateLong(from: data)
        let activated = isActivatedCard(data)
        let paymentSystemIcon = paymentSystemIcon(from: data)
        
        return MyProductsSectionProductItemViewModel(
            id: data.id,
            icon: icon,
            title: name,
            subtitle: subtitle,
            number: number,
            numberCard: number,
            balance: balance,
            balanceRub: balanceRub,
            dateLong: dateLong,
            isNeedsActivated: activated,
            paymentSystemIcon: paymentSystemIcon)
    }

    private func balanceFormatted(product: ProductData) -> String {
        
        switch product {
            
        case let loanProduct as ProductLoanData:
            
            if let balance = loanProduct.totalAmountDebt {

               return model.amountFormatted(amount: balance, currencyCode: product.currency, style: .clipped) ?? String(balance)

            } else {

              return "Ошибка"

            }

        default:
            return model.amountFormatted(amount: product.balanceValue, currencyCode: product.currency, style: .clipped) ?? String(product.balanceValue)
        }
    }
    
    private func createSubtitle(from data: ProductData) -> String? {
        
        switch data {
            
        case let cardProduct as ProductCardData:
            guard let subtitle = cardProduct.additionalField else { return nil }
            return "• \(subtitle)"
            
        case let depositProduct as ProductDepositData:
            let subtitle = depositProduct.interestRate
            return "• Ставка \(subtitle)%"
            
        case let loanProduct as ProductLoanData:
            let subtitle = loanProduct.currentInterestRate
            return "• Ставка \(subtitle)%"
            
        default: return nil
        }
    }
    
    private func paymentSystemIcon(from data: ProductData) -> Image? {
        
        guard let cardData = data as? ProductCardData else { return nil }
        return cardData.paymentSystemImage?.image
    }
    
    private func dateLong(from data: ProductData) -> String? {
        
        switch data {
            
        case let depositProduct as ProductDepositData:
            guard let endDate = depositProduct.endDate else { return nil }
            return "• \(DateFormatter.shortDate.string(from: endDate))"
            
        case let loanProduct as ProductLoanData:
            return "• \(DateFormatter.shortDate.string(from: loanProduct.dateLong))"
            
        default: return nil
        }
    }
    
    private func isActivatedCard(_ item: ProductData) -> Bool {

        guard let item = item as? ProductCardData, item.isActivated else {
            return false
        }
        return true
    }

    private func isNotActivatedCard(_ item: ProductData) -> Bool {

        guard let item = item as? ProductCardData, item.isNotActivated else {
            return false
        }
        return true
    }

    private func isBlockedCards(_ item: ProductData) -> Bool {

        guard let item = item as? ProductCardData, item.isBlocked else {
            return false
        }
        return true
    }
}

enum MyProductsViewModelAction {
    
    enum Tapped {
    
        struct Product: Action {
            
            let productId: ProductData.ID
        }
        
        struct OpenDeposit: Action {}
    }
}

extension MyProductsViewModel {
    
    static let sample = MyProductsViewModel(
        navigationBar: .init(
            title: "Мои продукты",
            leftButtons: [NavigationBarView.ViewModel.BackButtonViewModel(icon: .ic24ChevronLeft, action: {})],
            rightButtons: [.init(icon: .ic24Plus, action: { })],
            background: .barsTabbar),
        totalMoney: .sample1,
        sections: [.sample1, .sample2, .sample3, .sample4, .sample5, .sample6]
    )
}
