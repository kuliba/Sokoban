//
//  MyProductsSectionViewModelTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 20.05.2024.
//

import XCTest
@testable import ForaBank

final class MyProductsSectionViewModelTests: XCTestCase {

    func test_countCards() {
        
        let sut = makeSUT(products: makeAnyCards())
        
        XCTAssertNoDiff(sut.countCards(), 5)
    }
    
    // MARK: - Helpers

    private func makeSUT(
        productType: ProductType = .card,
        products: [ProductData] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> MyProductsSectionViewModel {
        
        let model = Model.emptyMock
        model.currencyList.value.append(.rub)
        model.products.value = [productType: products]
        
        var itemsVM: [MyProductsSectionViewModel.ItemViewModel] = []
        var groupingCards: Array.Products = [:]
        var itemsID: [ProductData.ID] = []
        if products.count > 0 {
            itemsVM = products.map { .item(.init(productData: $0, model: model)) }
            if productType == .card {
                groupingCards = products.groupingCards()
                itemsID = products.uniqueProductIDs()
            }
        }

        let sut = MyProductsSectionViewModel.init(
            id: productType.rawValue,
            title: productType.pluralName,
            items: itemsVM,
            groupingCards: groupingCards,
            itemsId: itemsID,
            isCollapsed: false,
            model: model)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)

        return sut
    }
    
    private func makeAnyCards() -> [ProductData] {
        let product1 = makeCardProduct(id: 10, parentID: 2)
        let product2 = makeCardProduct(id: 2)
        let product3 = makeCardProduct(id: 20, parentID: 3)
        let product4 = makeCardProduct(id: 21, parentID: 3)

        return [product1, product2, product3, product4]
    }
}
