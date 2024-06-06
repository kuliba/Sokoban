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
        
        let initialCards: [ProductData] = makeAnyCards123()
        let sections: [MyProductsSectionViewModel] = []
        
        let sut = makeSUT(products: initialCards, sections: sections)
        
        XCTAssertNotEqual(sut.first?.id, sections.first?.id)
        XCTAssertNoDiff(sut.itemsID, initialCards.uniqueProductIDs())
    }
    
    func test_updateViewModel_sectionsWithUpdate_shouldUpdateSections() throws {
        
        let initialCards: [ProductData] = makeAnyCards123()
        let reorderCards: [ProductData] = makeAnyCards132()

        let sections = try makeSections(products: initialCards)
        
        let sut = makeSUT(products: reorderCards, sections: sections)
        
        XCTAssertNoDiff(sut.first?.id, sections.first?.id)
        XCTAssertNoDiff(sections.itemsID, initialCards.uniqueProductIDs())
        XCTAssertNoDiff(sut.itemsID, reorderCards.uniqueProductIDs())
    }

    func test_updateViewModel_sectionsWithoutUpdate_shouldNotUpdateSections() throws {
        
        let initialCards: [ProductData] = makeAnyCards132()

        let sections = try makeSections(products: initialCards)
        
        let sut = makeSUT(products: initialCards, sections: sections)
        
        XCTAssertNoDiff(sut.first?.id, sections.first?.id)
        XCTAssertNoDiff(sections.itemsID, initialCards.uniqueProductIDs())
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
    
    private func makeAnyCards123() -> [ProductData] {
        let product1 = makeCardProduct(id: 1, parentID: 2)
        let product2 = makeCardProduct(id: 2)
        let product3 = makeCardProduct(id: 3, parentID: 3)

        return [product1, product2, product3]
    }
    
    private func makeAnyCards132() -> [ProductData] {
        let product1 = makeCardProduct(id: 1, parentID: 2)
        let product2 = makeCardProduct(id: 2)
        let product3 = makeCardProduct(id: 3, parentID: 3)

        return [product1, product3, product2]
    }
}

private extension Array where Element == MyProductsSectionViewModel {
    
    var itemsID: [ProductData.ID] {
        
        self.first?.itemsId ?? []
    }
}
