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
    
    // MARK: - Helpers
    
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
