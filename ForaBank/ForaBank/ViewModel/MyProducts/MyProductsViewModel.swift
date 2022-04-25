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
    
    @Published var currencyMenu: MyProductsСurrencyMenuViewModel?
    
    let sections: [MyProductsSectionViewModel]
    let navigationBar: NavigationViewModel
    let totalMoney: MyProductsMoneyViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    init(navigationBar: NavigationViewModel,
         totalMoney: MyProductsMoneyViewModel,
         sections: [MyProductsSectionViewModel]) {
        
        self.navigationBar = navigationBar
        self.totalMoney = totalMoney
        self.sections = sections
        
        bind(sections: sections)
    }

    private func bind(sections: [MyProductsSectionViewModel]) {

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
}

extension MyProductsViewModel {
    
    struct NavigationViewModel {
        
        let title: String
        let backButton: NavigationButtonViewModel
        let addButton: NavigationButtonViewModel
    }
    
    struct NavigationButtonViewModel {
        
        let icon: Image
        let action: () -> Void
        
        init(icon: Image, action: @escaping () -> Void) {
            
            self.icon = icon
            self.action = action
        }
    }
}

extension MyProductsViewModel {
    
    static let sample = MyProductsViewModel(
        navigationBar: NavigationViewModel(
            title: "Мои продукты",
            backButton: NavigationButtonViewModel(icon: .ic24ChevronLeft, action: {}),
            addButton: NavigationButtonViewModel(icon: .ic24Plus, action: {})),
        totalMoney: .sample,
        sections: [.sample1, .sample2, .sample3, .sample4, .sample5, .sample6]
    )
}
