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
                makeCardProduct(id: 3),
                makeCardProduct(id: 4, idParent: 6),
                makeCardProduct(id: 5, idParent: 3),
                makeCardProduct(id: 6),
                makeCardProduct(id: 7, idParent: 3),
                makeCardProduct(id: 8),
                makeCardProduct(id: 9, idParent: 34),
            ],
        ])
        
        let products = sut.allProducts
        
        XCTAssertNoDiff(products.map(\.id), [3, 5, 7, 6, 4, 8, 9, 1, 2])
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

    
    // MARK: - Helpers
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut: Model = .mockWithEmptyExcept()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

extension XCTestCase {

    func makeAccountProduct(
        id: Int
    ) -> ProductAccountData {
        
        .init(
            id: id,
            productType: .account,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "RUB",
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
        idParent: Int? = nil,
        isMain: Bool? = nil
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
            isMain: isMain,
            externalId: nil,
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "",
            idParent: idParent
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
