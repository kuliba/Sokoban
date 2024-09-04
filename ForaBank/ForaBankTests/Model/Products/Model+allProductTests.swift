//
//  Model+allProductTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 17.04.2024.
//

import XCTest
@testable import ForaBank

final class Model_allProductTests: XCTestCase {

    func test_allProductsWithAdditionalCards_shouldReturnSortedArray() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 1),
                makeAccountProduct(id: 2),
            ],
            .card: [
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
           ],
        ])
        
        let products = sut.allProducts
        
        XCTAssertNoDiff(products.map(\.id), [3, 12, 7, 11, 45, 5, 6, 4, 8, 9, 1, 2])
    }
    
    func test_allProductsWithoutAdditionalCards_shouldReturnSortedArray() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 1),
                makeAccountProduct(id: 2),
            ],
            .card: [
                makeCardProduct(id: 3),
                makeCardProduct(id: 4),
                makeCardProduct(id: 5),
                makeCardProduct(id: 6),
                makeCardProduct(id: 7),
                makeCardProduct(id: 8),
            ],
        ])
        
        let products = sut.allProducts
        
        XCTAssertNoDiff(products.map(\.id), [3, 4, 5, 6, 7, 8, 1, 2])
    }

    // MARK: test cardsTypes
    
    func test_cardsTypes_productsWithCards_shouldReturnArrayOfCardTypes() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 1),
                makeAccountProduct(id: 2),
            ],
            .card: [
                makeCardProduct(cardType: .additionalOther),
                makeCardProduct(cardType: .main),
                makeCardProduct(cardType: .additionalSelf),
                makeCardProduct(cardType: .main),
                makeCardProduct(cardType: .additionalOther),
                makeCardProduct(cardType: .additionalSelfAccOwn),
                makeCardProduct(cardType: .additionalSelfAccOwn),
                makeCardProduct(cardType: .regular),
                makeCardProduct(cardType: .additionalSelf),
                makeCardProduct(cardType: .additionalOther),
                makeCardProduct(cardType: .regular),
            ],
        ])
        
        let products = sut.cardsTypes
        
        XCTAssertNoDiff(products, [.additionalOther, .main, .additionalSelf, .additionalSelfAccOwn, .regular])
    }
    
    func test_cardsTypes_productsWithOutCards_shouldReturnEmptyArray() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 1),
                makeAccountProduct(id: 2),
            ]
        ])
        
        let products = sut.cardsTypes
        
        XCTAssertNoDiff(products, [])
    }
    
    func test_onlyCorporateCards_productsWithoutCards_shouldReturnFalse() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 1),
                makeAccountProduct(id: 2),
            ]
        ])
                
        XCTAssertFalse(sut.onlyCorporateCards)
    }

    // MARK: - test onlyCorporateCards
    
    func test_onlyCorporateCards_productsWithOnlyIndividualCards_shouldReturnFalse() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 1),
                makeAccountProduct(id: 2),
            ],
            .card: [
                makeCardProduct(cardType: .main),
                makeCardProduct(cardType: .regular),
                makeCardProduct(cardType: .additionalSelf)
            ]
        ])
                
        XCTAssertFalse(sut.onlyCorporateCards)
    }

    func test_onlyCorporateCards_productsWithIndividualAndCorporateCards_shouldReturnFalse() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 1),
                makeAccountProduct(id: 2),
            ],
            .card: [
                makeCardProduct(cardType: .main),
                makeCardProduct(cardType: .regular),
                makeCardProduct(cardType: .additionalSelf),
                makeCardProduct(cardType: .individualBusinessman),
            ]
        ])
                
        XCTAssertFalse(sut.onlyCorporateCards)
    }
    
    func test_onlyCorporateCards_productsEmpty_shouldReturnFalse() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [],
            .card: [],
            .deposit: [],
            .loan: []
        ])
                
        XCTAssertFalse(sut.onlyCorporateCards)
    }
    
    func test_onlyCorporateCards_productsIndividualAndCorporateCardsWithoutActiveProduct_shouldReturnTrue() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .card: [
                makeCardProduct(cardType: .main, status: .blockedUnlockAvailable),
                makeCardProduct(cardType: .regular, status: .blockedUnlockAvailable),
                makeCardProduct(cardType: .additionalSelf, status: .blockedUnlockAvailable),
                makeCardProduct(cardType: .individualBusinessman),
            ]
        ])
                
        XCTAssertTrue(sut.onlyCorporateCards)
    }
    
    func test_onlyCorporateCards_productsOnlyIndividualCardsWithoutActiveProduct_shouldReturnFalse() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .card: [
                makeCardProduct(cardType: .main, status: .blockedUnlockAvailable),
                makeCardProduct(cardType: .regular, status: .blockedUnlockAvailable),
                makeCardProduct(cardType: .additionalSelf, status: .blockedUnlockAvailable)
            ]
        ])
                
        XCTAssertFalse(sut.onlyCorporateCards)
    }

    func test_onlyCorporateCards_productsOnlyCorporateCards_shouldReturnTrue() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .card: [
                makeCardProduct(cardType: .individualBusinessman),
                makeCardProduct(cardType: .corporate)
            ]
        ])
                
        XCTAssertTrue(sut.onlyCorporateCards)
    }
    
    func test_onlyCorporateCards_productsCorporateCardsWithNotDemandDeposits_shouldReturnTrue() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .deposit: [
                .depositActiveRubNotDemand,
            ],
            .card: [
                makeCardProduct(cardType: .corporate),
                makeCardProduct(cardType: .individualBusinessmanMain)
            ]
        ])
                
        XCTAssertTrue(sut.onlyCorporateCards)
    }

    func test_onlyCorporateCards_productsCorporateCardsWithDemandDeposits_shouldReturnFalse() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .deposit: [
                .depositActiveRubDemand,
            ],
            .card: [
                makeCardProduct(cardType: .corporate),
                makeCardProduct(cardType: .individualBusinessmanMain)
            ]
        ])
                
        XCTAssertFalse(sut.onlyCorporateCards)
    }

    func test_onlyCorporateCards_productsCorporateCardsWithRubAccount_shouldReturnFalse() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 2, currency: "RUB")
            ],
            .card: [                
                makeCardProduct(cardType: .additionalCorporate, status: .active)
            ]
        ])
                
        XCTAssertFalse(sut.onlyCorporateCards)
    }
    
    func test_onlyCorporateCards_productsCorporateCardsWithOnlyCurrencyAccount_shouldReturnTrue() {
        
        let sut = makeSUT()
        sut.changeProducts(to: [
            .card: [
                makeCardProduct(cardType: .additionalCorporate, status: .active)
            ],
            .account: [
                makeAccountProduct(id: 2, currency: "USD")
            ]
        ])
                
        XCTAssertTrue(sut.onlyCorporateCards)
    }

    // MARK: - Helpers
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut: Model = .mockWithEmptyExcept()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeCardProduct(
        cardType: ProductCardData.CardType,
        status: ProductCardData.StatusCard = .active
    ) -> ProductCardData {
        
        .init(
            id: 1,
            productType: .card,
            number: "1111",
            numberMasked: "****",
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
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
            extraLargeDesign: .test,
            largeDesign: .test,
            mediumDesign: .test,
            smallDesign: .test,
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
            statusCard: status, 
            cardType: cardType,
            idParent: nil
        )
    }
}

extension XCTestCase {

    func makeAccountProduct(
        id: Int,
        currency: String = "RUB"
    ) -> ProductAccountData {
        
        .init(
            id: id,
            productType: .account,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: currency,
            mainField: "Account",
            additionalField: nil,
            customName: nil,
            productName: "Account",
            openDate: nil,
            ownerId: 0,
            branchId: 0,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: anySVGImageData(),
            largeDesign: anySVGImageData(),
            mediumDesign: anySVGImageData(),
            smallDesign: anySVGImageData(),
            fontDesignColor: anyColorData(),
            background: [],
            externalId: 0,
            name: "Ivanov",
            dateOpen: .distantPast,
            status: .active,
            branchName: nil,
            miniStatement: [],
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "",
            detailedRatesUrl: "",
            detailedConditionUrl: ""
        )
    }

    func makeCardProduct(
        id: Int,
        parentID: Int? = nil,
        order: Int = 0
    ) -> ProductCardData {
        
        .init(
            id: id,
            productType: .card,
            number: "1111",
            numberMasked: "****",
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
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
            extraLargeDesign: anySVGImageData(),
            largeDesign: anySVGImageData(),
            mediumDesign: anySVGImageData(),
            smallDesign: anySVGImageData(),
            fontDesignColor: anyColorData(),
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
            order: order,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "",
            idParent: parentID
        )
    }

    private func anySVGImageData(
        description: String = ""
    ) -> SVGImageData {
        
        .init(description: description)
    }
    
    private func anyColorData(
        description: String = ""
    ) -> ColorData {
        
        .init(description: description)
    }
}
