//
//  MyProductsViewModelTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 06.06.2024.
//

import XCTest
@testable import ForaBank

final class MyProductsViewModelTests: XCTestCase {
    
    // MARK: - test updateViewModel

    func test_updateViewModel_sectionsEmpty_shouldCreateSections() {
        
        let reorderCards: [ProductData] = makeCards(ids: 1, 2, 3)
        
        let sut = makeSUT(initialProducts: [], reorderProducts: reorderCards)
        
        XCTAssertNoDiff(sut.itemsID, [1, 2, 3])
    }
        
    func test_updateViewModel_sectionsWithUpdate_shouldUpdateOrderItemsInSections() {
        
        let initialCards: [ProductData] = makeCards(ids: 1, 2, 3)
        let reorderCards: [ProductData] = makeCards(ids: 1, 3, 2)
        
        let sut = makeSUT(initialProducts: initialCards, reorderProducts: reorderCards)
        
        XCTAssertNoDiff(sut.itemsID, [1, 3, 2])
    }

    func test_updateViewModel_sectionsWithoutUpdate_shouldNotUpdateOrderItemsInSections() {
        
        let initialCards: [ProductData] = makeCards(ids: 1, 3, 2)
        
        let sut = makeSUT(initialProducts: initialCards, reorderProducts: initialCards)
        
        XCTAssertNoDiff(sut.itemsID, [1, 3, 2])
    }
    
    func test_tapOpenCard_onlyCorporateCards_shouldNotChangeLink() {
        
        let sut = makeSUT(
            productType: .card,
            initialProducts: [
                makeCardProduct(id: 1, cardType: .individualBusinessman),
                makeCardProduct(id: 2, cardType: .corporate)])
                
        XCTAssertNil(sut.link)

        sut.openCard()

        XCTAssertNil(sut.link)
    }

    func test_tapOpenCard_notOnlyCorporateCards_shouldChangeLinkToOpenCard() {
        
        let sut = makeSUT(
            productType: .card,
            initialProducts: [
                makeCardProduct(id: 1, cardType: .individualBusinessman),
                makeCardProduct(id: 2, cardType: .corporate),
                makeCardProduct(id: 3, cardType: .main, isMain: true)
            ])
                
        XCTAssertNil(sut.link)

        sut.openCard()

        XCTAssertNoDiff(sut.link?.case, .openCard)
    }
    
    // MARK: - Helpers
    
    typealias SUT = MyProductsViewModel
    
    private func makeSUT(
        productType: ProductType = .card,
        initialProducts: [ProductData] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let model: Model = .mockWithEmptyExcept()
        model.currencyList.value.append(.rub)
        model.products.value = [productType: initialProducts]
        
        let sut = MyProductsViewModel.init(
            model,
            makeProductProfileViewModel: { _,_,_,_   in nil },
            openOrderSticker: {},
            makeMyProductsViewFactory: .init(makeInformerDataUpdateFailure: { return nil }))
        
        trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return sut
    }
    
    private func makeSUT(
        productType: ProductType = .card,
        initialProducts: [ProductData] = [],
        reorderProducts: [ProductData] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> [MyProductsSectionViewModel] {
        
        let model: Model = .mockWithEmptyExcept()
        model.currencyList.value.append(.rub)
        model.products.value = [productType: reorderProducts]
        let sections: [MyProductsSectionViewModel] = makeSections(productType: productType, model: model, products: initialProducts).compactMap { $0 }
        
        let sut = MyProductsViewModel.updateViewModel(
            with: [productType: reorderProducts],
            sections: sections,
            productsOpening: .init(),
            settingsProductsSections: .init(collapsed: [:]),
            model: model)
        
        // TODO: restore memory leaks tracking after MyProductsSectionViewModel fix
        //trackForMemoryLeaks(model, file: file, line: line)
        
        return sut
    }
    
    private func makeSections(
        productType: ProductType = .card,
        model: Model,
        products: [ProductData] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> [MyProductsSectionViewModel?] {
        
        model.products.value = [productType: products]
        
        let sut: [MyProductsSectionViewModel?] = [
                .init(productType: productType, products: products, settings: .init(collapsed: [:]), model: model)
        ]
        
        // TODO: restore memory leaks tracking after MyProductsSectionViewModel fix
        //trackForMemoryLeaks(model, file: file, line: line)

        return sut
    }
        
    private func makeCards(ids: Int...) -> [ProductData] {

      ids.map { makeCardProduct(id: $0) }
    }
}

private extension Array where Element == MyProductsSectionViewModel {
    
    var itemsID: [ProductData.ID] {
        
        self.first?.itemsId ?? []
    }
}

private extension MyProductsViewModel.Link {
    
    var `case`: Case? {
        
        switch self {
        case .openCard: return .openCard
        default:        return .other
        }
    }
    
    enum Case: Equatable {
        
        case openCard
        case other
    }
}
