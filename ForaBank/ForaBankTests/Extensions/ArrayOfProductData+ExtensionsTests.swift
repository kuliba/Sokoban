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
        
        let products = makeProductsWithBalance(productsInfo: [
            // 10 rub
            .init(id: 3, parentID: nil, cardType: .main, status: .active, balanceRub: 10),
            .init(id: 5, parentID: 3, cardType: .additionalSelf, status: .active, balanceRub: 10),
            .init(id: 12, parentID: 3, cardType: .additionalSelfAccOwn, status: .active, balanceRub: 10),
            .init(id: 7, parentID: 3, cardType: .additionalOther, status: .active, balanceRub: 10),
            .init(id: 11, parentID: 3, cardType: .additionalSelf, status: .active, balanceRub: 10),
            // 20 rub
            .init(id: 6, parentID: nil, cardType: .main, status: .active, balanceRub: 20),
            .init(id: 4, parentID: 6, cardType: .additionalSelf, status: .active, balanceRub: 20),
            // 20 rub
            .init(id: 8, parentID: nil, cardType: .main, status: .active, balanceRub: 20),
            // 30 rub
            .init(id: 9, parentID: 34, cardType: .additionalSelf, status: .active, balanceRub: 30),
            // 10 rub
            .init(id: 99, parentID: 134, cardType: .additionalSelfAccOwn, status: .active, balanceRub: 10),
            // 0 rub
            .init(id: 48, parentID: 90, cardType: .additionalOther, status: .active, balanceRub: 100),
            // 20 rub
            .init(id: 49, parentID: nil, cardType: .main, status: .active, balanceRub: 0),
            .init(id: 50, parentID: 49, cardType: .additionalSelf, status: .active, balanceRub: 20),
            .init(id: 51, parentID: 49, cardType: .additionalOther, status: .active, balanceRub: 20),
            // 20 rub
            .init(id: 59, parentID: nil, cardType: .main, status: .active, balanceRub: nil),
            .init(id: 60, parentID: 59, cardType: .additionalSelf, status: .active, balanceRub: 20),
            .init(id: 61, parentID: 59, cardType: .additionalOther, status: .active, balanceRub: 20),
            // corporate cards
            // 10 rub
            .init(id: 53, cardType: .individualBusinessman, balanceRub: 10),
            .init(id: 55, parentID: 53, cardType: .additionalCorporate, balanceRub: 10),
            .init(id: 512, parentID: 53, cardType: .additionalCorporate, balanceRub: 10),
            // 20 rub
            .init(id: 56, cardType: .individualBusinessmanMain, balanceRub: 20),
            .init(id: 54, parentID: 56, cardType: .additionalCorporate, balanceRub: 20),
            // 20 rub
            .init(id: 510, cardType: .corporate, balanceRub: 20),
            // 50 rub
            .init(id: 511, cardType: .additionalCorporate, balanceRub: 50),
        ])
        
        XCTAssertNoDiff(products.balanceRub(), 230)
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
    
    private func makeProductsWithBalance(
        productsInfo: [ProductDataHelper]
    ) -> [ProductData] {
        
        return productsInfo.map {
            makeCardProduct(
                id: $0.id,
                parentID: $0.parentID,
                cardType: $0.cardType,
                status: $0.status,
                balanceRub: $0.balanceRub)
        }
    }
    
    func makeCardProduct(
        id: Int,
        parentID: Int? = nil,
        cardType: ProductCardData.CardType = .main,
        status: ProductData.Status = .active,
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
            status: status,
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

    private struct ProductDataHelper {
        
        let id: Int
        let parentID: Int?
        let cardType: ProductCardData.CardType
        let status: ProductData.Status
        let balanceRub: Double?
        
        init(
            id: Int,
            parentID: Int? = nil,
            cardType: ProductCardData.CardType = .main,
            status: ProductData.Status = .active,
            balanceRub: Double?
        ) {
            self.id = id
            self.parentID = parentID
            self.cardType = cardType
            self.status = status
            self.balanceRub = balanceRub
        }
    }
}
