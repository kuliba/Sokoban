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
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    
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
        navigationBar = NavigationBarView.ViewModel(
            title: "Мои продукты",
            leftButtons: [NavigationBarView.ViewModel.BackButtonViewModel(icon: .ic24ChevronLeft, action: dismissAction)],
            background: .barsTabbar)
        totalMoney = .init()
        navigationBar.rightButtons = [.init(icon: .ic24Plus, action: { [weak self] in
            self?.action.send(MyProductsViewModelAction.Add())
        })]
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

                        let activatedCards = value.filter { isActivatedCard($0) }

                        sections.append(MyProductsSectionViewModel(
                            title: key.pluralName,
                            items: sectionItems(value: activatedCards),
                            isCollapsed: false,
                            isEnabled: true))

                        let notActivatedCards = value.filter { isNotActivatedCard($0) }

                        if notActivatedCards.isEmpty { return }

                        let notActivatedSection = MyProductsSectionViewModel(
                            title: "Неактивированные продукты",
                            items: sectionItems(value: notActivatedCards),
                            isCollapsed: false,
                            isEnabled: true)

                        sections.insert(notActivatedSection, at: 0)

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

                if let blockedCards = blockedCards(data) {

                    let blockedSection = MyProductsSectionViewModel(
                        title: "Заблокированные продукты",
                        items: sectionItems(value: blockedCards),
                        isCollapsed: false,
                        isEnabled: true)

                    sections.append(blockedSection)
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
            .sink { [unowned self] action in

                switch action {
                    
                case _ as MyProductsViewModelAction.CloseAction.Link:
                    link = nil
                    
                default:
                    break
                }
            }.store(in: &bindings)

        model.productsHidden
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] productsHidden in

                let items = sections.flatMap { $0.items }

                for item in items {

                    if model.productsHidden.value.contains(item.id) {
                        item.isMainScreenHidden = true
                    } else {
                        item.isMainScreenHidden = false
                    }
                }
            }.store(in: &bindings)

        $sections
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] sections in

                let items = sections.flatMap { $0.items }

                for item in items {

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
                                guard let prooduct = model.products.value.values.flatMap({ $0 }).first(where: { $0.id == payload.productId }),
                                      let productProfileViewModel = ProductProfileViewModel(model, product: prooduct, dismissAction: { [weak self] in
                                          self?.action.send(MyProductsViewModelAction.CloseAction.Link())
                                      }) else { return }
                                link = .productProfile(productProfileViewModel)
                                
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
            }.store(in: &bindings)
    }
    
    enum Link {
        
        case productProfile(ProductProfileViewModel)
    }
}

extension MyProductsViewModel {

    private func setStateNormal(_ model: MyProductsSectionItemViewModel) {

        withAnimation {
            model.state = .normal
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
        let balance = ProductView.ViewModel.balanceFormatted(product: data, style: .profile, model: model)
        let balanceRub = data.balanceRub ?? 0
        let dateLong = dateLong(from: data)
        let activated = isActivatedCard(data)
        let paymentSystemIcon = paymentSystemIcon(from: data)
        
        return MyProductsSectionItemViewModel(
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

    private func createSubtitle(from data: ProductData) -> String? {
        
        guard let subtitle = data.additionalField else { return nil }
        return "• \(subtitle)"
    }
    
    private func paymentSystemIcon(from data: ProductData) -> Image? {
        
        guard let cardData = data as? ProductCardData else { return nil }
        return cardData.paymentSystemImage?.image
    }
    
    private func dateLong(from data: ProductData) -> String? {
        
        guard let loanData = data as? ProductLoanData else { return nil }
        return "• \(DateFormatter.shortDate.string(from: loanData.dateLong))"
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

    private func blockedCards(_ data: [Dictionary<ProductType, [ProductData]>.Element]) -> [ProductData]? {

        let data = data.first(where: { $0.key == .card })

        let filterred = data?.value.filter { item in

            guard let item = item as? ProductCardData, item.isBlocked else {
                return false
            }
            return true
        }

        guard let blockedCards = filterred, !blockedCards.isEmpty else {
            return nil
        }

        return blockedCards
    }
}

enum MyProductsViewModelAction {

    struct Back: Action {}
    
    struct Add: Action {}
    
    enum CloseAction {
     
        struct Link: Action {}
        
        struct Sheet: Action {}
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
