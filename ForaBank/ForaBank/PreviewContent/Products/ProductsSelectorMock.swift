//
//  ProductsSelectorMock.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 26.09.2022.
//

extension ProductSelectorView.ViewModel {
    
    static let sample1 = ProductSelectorView.ViewModel(
        .emptyMock,
        content: .product(.sample),
        listViewModel: nil,
        context: .init(
            title: "Откуда",
            direction: .from))
        
    static let sample2 = ProductSelectorView.ViewModel(
        .emptyMock,
        content: .product(.sample),
        listViewModel: .init(
            model: .emptyMock,
            products: [.classicSmall, .accountSmall],
            options: nil),
        context: .init(
            title: "Куда",
            direction: .to))
    
    static let sample3 = ProductSelectorView.ViewModel(
        .emptyMock,
        content: .placeholder(.init()),
        listViewModel: nil,
        context: .init(
            title: "Куда",
            direction: .to))
}
