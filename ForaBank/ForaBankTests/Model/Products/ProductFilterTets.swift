//
//  ProductFilterTets.swift
//  ForaBankTests
//
//  Created by Max Gribov on 22.11.2022.
//

import XCTest
@testable import ForaBank

class ProductFilterTets: XCTestCase {}

//MARK: - Card

extension ProductFilterTets {
    
    static let cardActiveMainRub = ProductCardData(id: 11, currency: .rub)
    static let cardBlockedMainRub = ProductCardData(id: 12, currency: .rub, status: .blocked, statusPc: .blockedByBank)
    static let cardActiveAddRub = ProductCardData(id: 13, currency: .rub, isMain: false)
    
    static let cardActiveMainUsd = ProductCardData(id: 21, currency: .usd)
    static let cardBlockedMainUsd = ProductCardData(id: 22, currency: .usd, status: .blocked, statusPc: .blockedByBank)
    static let cardActiveAddUsd = ProductCardData(id: 23, currency: .usd, isMain: false)
    
    static let cardLoanActiveMainRub = ProductCardData(id: 31, currency: .rub, ownerId: 123, loanBaseParam: .init(clientId: 123))
    static let cardLoanBlockedMainRub = ProductCardData(id: 32, currency: .rub, ownerId: 123, status: .blocked, loanBaseParam: .init(clientId: 123), statusPc: .blockedByBank)
    static let cardLoanActiveAddRub = ProductCardData(id: 33, currency: .rub, ownerId: 123, loanBaseParam: .init(clientId: 123), isMain: false)
    
    static let cardLoanActiveMainUsd = ProductCardData(id: 41, currency: .usd, ownerId: 123, loanBaseParam: .init(clientId: 123))
    static let cardLoanBlockedMainUsd = ProductCardData(id: 42, currency: .usd, ownerId: 123, status: .blocked, loanBaseParam: .init(clientId: 123), statusPc: .blockedByBank)
    static let cardLoanActiveAddUsd = ProductCardData(id: 43, currency: .usd, ownerId: 123, loanBaseParam: .init(clientId: 123), isMain: false)
    
    static let cardProducts = [cardActiveMainRub,
                               cardBlockedMainRub,
                               cardActiveAddRub,
                               
                               cardActiveMainUsd,
                               cardBlockedMainUsd,
                               cardActiveAddUsd,
                               
                               cardLoanActiveMainRub,
                               cardLoanBlockedMainRub,
                               cardLoanActiveAddRub,
                               
                               cardLoanActiveMainUsd,
                               cardLoanBlockedMainUsd,
                               cardLoanActiveAddUsd]
    
    func testCardActiveRule() {
        
        // given
        let products = Self.cardProducts
        let filter = ProductData.Filter(rules: [ProductData.Filter.CardActiveRule()])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 8)
        XCTAssertEqual(result[0].id, 11)
        XCTAssertEqual(result[1].id, 13)
        XCTAssertEqual(result[2].id, 21)
        XCTAssertEqual(result[3].id, 23)
        XCTAssertEqual(result[4].id, 31)
        XCTAssertEqual(result[5].id, 33)
        XCTAssertEqual(result[6].id, 41)
        XCTAssertEqual(result[7].id, 43)
    }
    
    func testCardLoanRestrictedRule() {
        
        // given
        let products = Self.cardProducts
        let filter = ProductData.Filter(rules: [ProductData.Filter.CardLoanRestrictedRule()])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 6)
        XCTAssertEqual(result[0].id, 11)
        XCTAssertEqual(result[1].id, 12)
        XCTAssertEqual(result[2].id, 13)
        XCTAssertEqual(result[3].id, 21)
        XCTAssertEqual(result[4].id, 22)
        XCTAssertEqual(result[5].id, 23)
    }
    
    func testCardAdditionalRestrictedRule() {
        
        // given
        let products = Self.cardProducts
        let filter = ProductData.Filter(rules: [ProductData.Filter.CardAdditionalRetrictedRule()])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 8)
        XCTAssertEqual(result[0].id, 11)
        XCTAssertEqual(result[1].id, 12)
        XCTAssertEqual(result[2].id, 21)
        XCTAssertEqual(result[3].id, 22)
        XCTAssertEqual(result[4].id, 31)
        XCTAssertEqual(result[5].id, 32)
        XCTAssertEqual(result[6].id, 41)
        XCTAssertEqual(result[7].id, 42)
    }
    
    func testCardActive_LoanRestricted_AdditionalRestricted() {
        
        // given
        let products = Self.cardProducts
        let filter = ProductData.Filter(rules: [ProductData.Filter.CardActiveRule(),
                                                ProductData.Filter.CardLoanRestrictedRule(),
                                                ProductData.Filter.CardAdditionalRetrictedRule()])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 11)
        XCTAssertEqual(result[1].id, 21)
    }
    
}

private extension ProductCardData {
    
    convenience init(id: Int, currency: Currency, ownerId: Int = 0, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .active, loanBaseParam: ProductCardData.LoanBaseParamInfoData? = nil, statusPc: ProductData.StatusPC = .active, isMain: Bool = true) {
        
        self.init(id: id, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: ownerId, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], accountId: nil, cardId: 0, name: "", validThru: Date(), status: status, expireDate: nil, holderName: nil, product: nil, branch: "", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: loanBaseParam, statusPc: statusPc, isMain: isMain, externalId: nil, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
}

private extension ProductCardData.LoanBaseParamInfoData {
    
    init(clientId: Int) {
        
        self.init(loanId: 0, clientId: clientId, number: "", currencyId: nil, currencyNumber: nil, currencyCode: nil, minimumPayment: nil, gracePeriodPayment: nil, overduePayment: nil, availableExceedLimit: nil, ownFunds: nil, debtAmount: nil, totalAvailableAmount: nil, totalDebtAmount: nil)
    }

}
