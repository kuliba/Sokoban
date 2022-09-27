//
//  ProductsSelectorMock.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 26.09.2022.
//

extension ProductSelectorView.ViewModel {
    
    static let sample1 = ProductSelectorView.ViewModel(
        model: .emptyMock,
        productViewModel: .init(
            id: 10002585801,
            cardIcon: .init("Platinum Card"),
            paymentIcon: .init("Platinum Logo"),
            name: "Platinum",
            balance: "2,71 млн ₽",
            numberCard: "2953",
            description: "Все включено"),
        context: .init(
            title: "Откуда",
            isDividerHiddable: true,
            isAdditionalProducts: true))
    
    static let sample2 = ProductSelectorView.ViewModel(
        model: .emptyMock,
        productViewModel: .init(
            id: 10002585802,
            cardIcon: .init("Platinum Card"),
            paymentIcon: .init("Platinum Logo"),
            name: "Platinum",
            balance: "2,71 млн ₽",
            numberCard: "2953",
            description: "Все включено",
            isCollapsed: false),
        listViewModel: .init(
            model: .emptyMock,
            products: [.classicSmall, .accountSmall],
            options: nil),
        context: .init(title: "Куда"))
    
    static let sample3 = ProductSelectorView.ViewModel(
        model: .emptyMock,
        productViewModel: .init(
            id: 10002585803,
            cardIcon: .init("RUB Account"),
            name: "Текущий счет",
            balance: "0 $",
            numberCard: "",
            description: "Валютный",
            isCollapsed: false),
        listViewModel: .init(
            model: .emptyMock,
            products: [.classicSmall, .accountSmall],
            options: nil),
        context: .init(
            title: "Куда",
            isDividerHiddable: true))
}
