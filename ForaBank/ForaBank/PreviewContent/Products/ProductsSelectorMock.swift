//
//  ProductsSelectorMock.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 26.09.2022.
//

extension ProductSelectorView.ViewModel {
    
    static let sample1 = ProductSelectorView.ViewModel(
        .emptyMock,
        content: .product(.sample1),
        listViewModel: nil,
        context: .init(
            title: "Откуда",
            direction: .from, filter: .generalFrom))
        
    static let sample2: ProductSelectorView.ViewModel = .init(
        .emptyMock,
        content: .product(.sample2),
        listViewModel: .init(
            products: [.classicSmall, .accountSmall],
            selector: .init(
                options: [
                    .init(id: "CARD", name: ProductType.card.pluralName),
                    .init(id: "ACCOUNT", name: ProductType.account.pluralName)
                ],
                selected: "CARD", style: .productsSmall),
            selectedProductId: 10,
            filter: .generalFrom, model: .emptyMock),
        context: .init(title: "Куда", direction: .to, filter: .generalFrom))
    
    static let sample3: ProductSelectorView.ViewModel = .init(.emptyMock, context: .init(title: "Куда", direction: .to, filter: .generalFrom))
}
