//
//  ProductModelActivateTests.swift
//  ForaBankTests
//
//  Created by Pavel Samsonov on 24.05.2022.
//

import XCTest
@testable import ForaBank

class ProductModelActivateTests: XCTestCase {

    func testProductCardData_Activate_Reduce() throws {

        // given

        let date = Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000))
        let background: [ColorData] = [.init(description: "FFBB36")]
        let cardID = 10002585802

        let activateCard = ProductCardData(id: 10002585801, productType: .card, number: "4444555566661121", numberMasked: "4444-XXXX-XXXX-1121", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639851, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, accountId: nil, cardId: 0, name: "ВСФ", validThru: date, status: .active, expireDate: nil, holderName: nil, product: nil, branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [.init(account: "string", date: date, amount: 0, currency: "string", purpose: "string")], paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: .active, isMain: nil, externalId: 10000788533)

        let notActivateCard = ProductCardData(id: cardID, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000002", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639852, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, accountId: nil, cardId: 0, name: "ВСФ", validThru: date, status: .notBlocked, expireDate: nil, holderName: nil, product: nil, branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [.init(account: "string", date: date, amount: 0, currency: "string", purpose: "string")], paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: .notActivated, isMain: nil, externalId: 10000788533)

        var productsData = ProductsData()
        productsData[.card] = [activateCard, notActivateCard]

        // when

        let result = Model.reduce(products: productsData, cardID: cardID)
        let productCards = result[.card]

        // then

        XCTAssertNotNil(productCards)
        XCTAssertEqual(productCards!.count, 2)
        XCTAssertEqual(productCards![0], activateCard)
        XCTAssertEqual((productCards![1] as! ProductCardData).status, .active)
        XCTAssertEqual((productCards![1] as! ProductCardData).statusPc, .active)
    }
}
