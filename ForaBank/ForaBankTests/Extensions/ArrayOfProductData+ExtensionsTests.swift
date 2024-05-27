//
//  ArrayOfProductData+ExtensionsTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 19.04.2024.
//

import XCTest
@testable import ForaBank

final class ArrayOfProductData_ExtensionsTests: XCTestCase {

    func test_groupingByParentID_shouldReturnDictionary() {
        
        let groupedByParentID = makeProducts().groupingByParentID()
        
        XCTAssertNoDiff( 
            groupedByParentID.mapValues { $0.map(\.id)},
            [3:  [12, 7, 11, 45, 5],
             6:  [4],
             34: [9]
            ])
    }
    
    func test_groupingCards_shouldReturnDictionary() {
        
        let groupingCards = makeProducts().groupingCards()

        XCTAssertNoDiff(
            groupingCards.mapValues { $0.map(\.id)},
            [3:  [3, 12, 7, 11, 45, 5],
             6:  [4, 6],
             8:  [8],
             34: [9]
            ])
    }
    
    func test_productsWithoutAdditional_shouldReturnArray() {
        
        let productsWithoutAdditional = makeProducts().productsWithoutAdditional()
        
        XCTAssertNoDiff(
            productsWithoutAdditional.map(\.id),
            [1, 2, 3, 6, 8])
    }
    
    func test_cardsWithoutAdditional_shouldReturnArray() {
        
        let productsWithoutAdditional = makeProducts().cardsWithoutAdditional()
        
        XCTAssertNoDiff(
            productsWithoutAdditional.map(\.id),
            [3, 6, 8])
    }
    
    func test_productsWithoutCards_shouldReturnArray() {
        
        let productsWithoutCards = makeProducts().productsWithoutCards()
        
        XCTAssertNoDiff(
            productsWithoutCards.map(\.id),
            [1, 2])
    }
    
    func test_groupingAndSortedProducts_shouldReturnArray() {
        
        let groupingAndSortedProducts = makeProducts().groupingAndSortedProducts()
        
        XCTAssertNoDiff(
            groupingAndSortedProducts.map(\.id),
            [3, 12, 7, 11, 45, 5, 6, 4, 8, 9, 1, 2])
    }
    
    func test_uniqueProductIDs_shouldReturnArray() {
        
        let uniqueProductIDs = makeProducts().uniqueProductIDs()
        
        XCTAssertNoDiff(
            uniqueProductIDs,
            [1, 2, 3, 6, 8, 34])
    }
    
    func test_balanceRub() {
        
        let products = makeProductsWithBalance()
        
        XCTAssertNoDiff(products.balanceRub(), 130)
    }

    // MARK: - Helpers
    
    func makeProducts() -> [ProductData] {
        return [
            makeAccountProduct(id: 1),
            makeAccountProduct(id: 2),
            makeCardProduct(id: 5, parentID: 3, order: 10),
            makeCardProduct(id: 3),
            makeCardProduct(id: 4, parentID: 6),
            makeCardProduct(id: 6),
            makeCardProduct(id: 12, parentID: 3, order: 0),
            makeCardProduct(id: 7, parentID: 3, order: 0),
            makeCardProduct(id: 11, parentID: 3, order: 0),
            makeCardProduct(id: 8),
            makeCardProduct(id: 9, parentID: 34),
            makeCardProduct(id: 45, parentID: 3, order: 1)
        ]
    }
    
    func makeProductsWithBalance() -> [ProductData] {
        return [
            makeCardProduct(id: 5, parentID: 3, cardType: .additionalSelf, balanceRub: 10),
            makeCardProduct(id: 3, balanceRub: 10),
            makeCardProduct(id: 4, parentID: 6, cardType: .additionalSelf, balanceRub: 20),
            makeCardProduct(id: 6, balanceRub: 20),
            makeCardProduct(id: 12, parentID: 3, cardType: .additionalSelfAccOwn, balanceRub: 10),
            makeCardProduct(id: 7, parentID: 3, cardType: .additionalOther, balanceRub: 10),
            makeCardProduct(id: 11, parentID: 3, cardType: .additionalSelf, balanceRub: 10),
            makeCardProduct(id: 8, balanceRub: 20),
            makeCardProduct(id: 9, parentID: 34, cardType: .additionalSelf, balanceRub: 40),
            makeCardProduct(id: 45, parentID: 3, balanceRub: 10),
            makeCardProduct(id: 48, parentID: 90, cardType: .additionalOther, balanceRub: 100),
            makeCardProduct(id: 49, parentID: nil, cardType: .main, balanceRub: 0),
            makeCardProduct(id: 50, parentID: 49, cardType: .additionalSelf, balanceRub: 20),
            makeCardProduct(id: 51, parentID: 49, cardType: .additionalOther, balanceRub: 20),
            makeCardProduct(id: 59, parentID: nil, cardType: .main, balanceRub: nil),
            makeCardProduct(id: 60, parentID: 59, cardType: .additionalSelf, balanceRub: 20),
            makeCardProduct(id: 61, parentID: 59, cardType: .additionalOther, balanceRub: 20)

        ]
    }
    
    func makeCardProduct(
        id: Int,
        parentID: Int? = nil,
        cardType: ProductCardData.CardType = .main,
        balanceRub: Double?
    ) -> ProductCardData {
        
        .init(
            id: id,
            productType: .card,
            number: "1111",
            numberMasked: "****",
            accountNumber: nil,
            balance: nil,
            balanceRub: balanceRub,
            currency: "RUB",
            mainField: "Card",
            additionalField: nil,
            customName: nil,
            productName: "Card",
            openDate: nil,
            ownerId: 0,
            branchId: 0,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: .init(description: ""),
            largeDesign: .init(description: ""),
            mediumDesign: .init(description: ""),
            smallDesign: .init(description: ""),
            fontDesignColor: .init(description: ""),
            background: [],
            accountId: nil,
            cardId: 0,
            name: "CARD",
            validThru: Date(),
            status: .active,
            expireDate: "01/01/01",
            holderName: "Иванов",
            product: nil,
            branch: "",
            miniStatement: nil,
            paymentSystemName: nil,
            paymentSystemImage: nil,
            loanBaseParam: nil,
            statusPc: nil,
            isMain: nil,
            externalId: nil,
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "",
            cardType: cardType, 
            idParent: parentID
        )
    }

}
