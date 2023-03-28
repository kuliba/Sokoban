//
//  ProductsSelectorMock.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 26.09.2022.
//

extension ProductSelectorView.ViewModel {
    
    static let sampleMe2MeCollapsed = ProductSelectorView.ViewModel(
        .emptyMock,
        content: .product(.sample1),
        productCarouselViewModel: nil,
        context: .init(
            title: "Откуда",
            direction: .from, style: .me2me, filter: .generalFrom))
        
    static let sample2: ProductSelectorView.ViewModel = .init(
        .emptyMock,
        content: .product(.sample2),
        productCarouselViewModel: .sampleProductsSmall,
        context: .init(title: "Куда", direction: .to, style: .me2me, filter: .generalFrom))
    
    static let sample3: ProductSelectorView.ViewModel = .init(.emptyMock, context: .init(title: "Куда", direction: .to, style: .me2me, filter: .generalFrom))
    
    static let sampleRegularCollapsed = ProductSelectorView.ViewModel(
        .emptyMock,
        content: .product(.sampleRegular),
        productCarouselViewModel: nil,
        context: .init(
            title: "Счет списания",
            direction: .from, style: .regular, filter: .generalFrom))
}
