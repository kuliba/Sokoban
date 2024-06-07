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
        
        let initialCards: [ProductData] = makeCards(ids: 1, 2, 3)
        let sections: [MyProductsSectionViewModel] = []
        
        let sut = makeSUT(products: initialCards, sections: sections)
        
        XCTAssertNoDiff(sut.itemsID, initialCards.uniqueProductIDs())
    }
    
    func test_updateViewModel_sectionsWithUpdate_shouldUpdateOrderItemsInSections() throws {
        
        let initialCards: [ProductData] = makeCards(ids: 1, 2, 3)
        let reorderCards: [ProductData] = makeCards(ids: 1, 3, 2)

        let sections = try makeSections(products: initialCards)
        
        let sut = makeSUT(products: reorderCards, sections: sections)
        
        XCTAssertNoDiff(sut.itemsID, reorderCards.uniqueProductIDs())
    }

    func test_updateViewModel_sectionsWithoutUpdate_shouldNotUpdateOrderItemsInSections() throws {
        
        let initialCards: [ProductData] = makeCards(ids: 1, 3, 2)

        let sections = try makeSections(products: initialCards)
        
        let sut = makeSUT(products: initialCards, sections: sections)
        
        XCTAssertNoDiff(sut.itemsID, initialCards.uniqueProductIDs())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        productType: ProductType = .card,
        products: [ProductData] = [],
        sections: [MyProductsSectionViewModel],
        file: StaticString = #file,
        line: UInt = #line
    ) -> [MyProductsSectionViewModel] {
        
        let model = Model.emptyMock
        model.currencyList.value.append(.rub)
        model.products.value = [productType: products]
        
        let sut = MyProductsViewModel.updateViewModel(
            with: [productType: products],
            sections: sections,
            productsOpening: .init(),
            settingsProductsSections: .init(collapsed: [:]),
            model: model)
        
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return sut
    }
    
    private func makeSections(
        productType: ProductType = .card,
        products: [ProductData] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> [MyProductsSectionViewModel] {
        
        let model = Model.emptyMock
        model.currencyList.value.append(.rub)
        model.products.value = [productType: products]
        
        let sut: [MyProductsSectionViewModel] = try [
            XCTUnwrap(.init(productType: .card, products: products, settings: .init(collapsed: [:]), model: model))
        ]
        
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
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
