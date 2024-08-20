//
//  ProductFilterTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 15.04.2024.
//

import XCTest
@testable import ForaBank

final class ProductFilterTests: XCTestCase {
    
    func testCardActiveRule() {
        
        let result = filteredProducts(rules: [ProductData.Filter.CardActiveRule()])
        
        XCTAssertEqual(
            result.map(\.id),
            [11, 13, 21, 23, 31, 33, 41, 43, 151, 152, 153]
        )
    }
    
    func testCardLoanRestrictedRule() {
        
        let result = filteredProducts(rules: [ProductData.Filter.CardLoanRestrictedRule()])
        
        XCTAssertEqual(
            result.map(\.id),
            [11, 12, 13, 21, 22, 23, 151, 152, 153]
        )
    }
    
    func testCardAdditionalSelfRuleRule() {
        
        let result = filteredProducts(rules: [ProductData.Filter.CardAdditionalSelfRule()])
        
        XCTAssertEqual(
            result.map(\.id),
            [11, 12, 13, 21, 22, 23, 31, 32, 33, 41, 42, 43, 151, 152]
        )
    }
    
    func testCardAdditionalSelfAccOwnRuleRule() {
        
        let result = filteredProducts(rules: [ProductData.Filter.CardAdditionalSelfAccOwnRule()])
        
        XCTAssertEqual(
            result.map(\.id),
            [11, 12, 13, 21, 22, 23, 31, 32, 33, 41, 42, 43, 152]
        )
    }
    
    func test_CardCorporateRule_ShouldExcludeCorporateCards() {
        
        let result = filteredProducts(
            products: [
                ProductCardData(id: 1, cardType: .additionalCorporate),
                ProductCardData(id: 2, cardType: .corporate),
                ProductCardData(id: 3, cardType: .individualBusinessman),
                ProductCardData(id: 4, cardType: .individualBusinessmanMain),
                ProductCardData(id: 10, cardType: .main),
                .accountActiveRub,
                .depositActiveRub
            ],
            rules: [ProductData.Filter.CardCorporateRule()]
        )
        
        XCTAssertEqual(
            result.map(\.id),
            [10, 51, 71]
        )
    }
    
    func test_CardCorporateIsIndividualBusinessmanMainRule_ShouldReturnIndividualBusinessmanMainExcludeOtherCorporateCards() {
        
        let result = filteredProducts(
            products: [
                ProductCardData(id: 1, cardType: .additionalCorporate),
                ProductCardData(id: 2, cardType: .corporate),
                ProductCardData(id: 3, cardType: .individualBusinessman),
                ProductCardData(id: 4, cardType: .individualBusinessmanMain)
            ],
            rules: [ProductData.Filter.CardCorporateIsIndividualBusinessmanMainRule()]
        )
        
        XCTAssertEqual(
            result.map(\.id),
            [4]
        )
    }
    
    func testCardActive_LoanRestricted_AdditionalSelf() {
        
        let result = filteredProducts(
            rules: [
                ProductData.Filter.CardActiveRule(),
                ProductData.Filter.CardLoanRestrictedRule(),
                ProductData.Filter.CardAdditionalSelfRule()
            ])
        
        XCTAssertEqual(
            result.map(\.id),
            [11, 13, 21, 23, 151, 152]
        )
    }
    
    func testAccountActiveRule() {
        
        let result = filteredProducts(
            products: .accountProducts,
            rules: [ProductData.Filter.AccountActiveRule()])
        
        XCTAssertEqual(
            result.map(\.id),
            [51, 61]
        )
    }
    
    func testTypeCard_CardActiveRule() {
        
        let result = filteredProducts(
            products: .all,
            rules: [
                ProductData.Filter.ProductTypeRule([.card]),
                ProductData.Filter.CardActiveRule()
            ])
        
        XCTAssertEqual(
            result.map(\.id),
            [11, 13, 21, 23, 31, 33, 41, 43, 151, 152, 153]
        )
    }
    
    func testTypeCard_CardActive_CurrencyRule() {
        
        let result = filteredProducts(
            products: .all,
            rules: [
                ProductData.Filter.ProductTypeRule([.card]),
                ProductData.Filter.CardActiveRule(),
                ProductData.Filter.CurrencyRule([.rub])
            ])
        
        XCTAssertEqual(
            result.map(\.id),
            [11, 13, 31, 33, 151, 152, 153]
        )
    }
    
    func testTypeCard_CardActive_DebitRule() {
        
        let result = filteredProducts(
            products: .all,
            rules: [
                ProductData.Filter.ProductTypeRule([.card]),
                ProductData.Filter.CardActiveRule(),
                ProductData.Filter.DebitRule()
            ])
        
        XCTAssertEqual(
            result.map(\.id),
            [11, 21, 23, 31, 33, 41, 43, 151, 152, 153]
        )
    }
    
    func testTypeCard_CardActive_CreditRule() {
        
        let result = filteredProducts(
            products: .all,
            rules: [
                ProductData.Filter.ProductTypeRule([.card]),
                ProductData.Filter.CardActiveRule(),
                ProductData.Filter.CreditRule()
            ])
        
        XCTAssertEqual(
            result.map(\.id),
            [13, 21, 23, 31, 33, 41, 43]
        )
    }
    
    func testTypeCard_CardActive_ProductRestrictedRule() {
        
        let result = filteredProducts(
            products: .all,
            rules: [
                ProductData.Filter.ProductTypeRule([.card]),
                ProductData.Filter.CardActiveRule(),
                ProductData.Filter.ProductRestrictedRule([43])
            ])
        
        XCTAssertEqual(
            result.map(\.id),
            [11, 13, 21, 23, 31, 33, 41, 151, 152, 153]
        )
    }
    
    func testTypeCard_CardActive_AllRestrictedRule() {
        
        let result = filteredProducts(
            products: .all,
            rules: [ProductData.Filter.AllRestrictedRule()])
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func testFilteredProductTypes() {
        
        let result = filteredProductsType(
            products: [
                .cardActiveAddUsd,
                .accountActiveRub,
                .depositActiveRub,
                .loanActiveRub],
            rules: [ProductData.Filter.ProductTypeRule([.card, .account])])
        
        // then
        XCTAssertEqual(result, [.card, .account])
    }
    
    func testFilteredProductTypes_Currency() {
        
        let result = filteredProductsType(
            products: [
                .cardActiveAddUsd,
                .accountActiveRub,
                .depositActiveRub,
                .loanActiveRub],
            rules: [ProductData.Filter.ProductTypeRule([.card, .account]), ProductData.Filter.CurrencyRule([.usd])])
        
        XCTAssertEqual(result, [.card])
    }
    
    // MARK: - Helpers
    
    private func filteredProducts(
        products: [ProductData] = .cardProducts,
        rules: [ProductDataFilterRule]
    ) -> [ProductData] {
        
        let filter = ProductData.Filter(rules: rules)
        
        return filter.filteredProducts(products)
    }
    
    private func filteredProductsType(
        products: [ProductData],
        rules: [ProductDataFilterRule]
    ) -> [ProductType] {
        
        let filter = ProductData.Filter(rules: rules)
        
        return filter.filteredProductsTypes(products)
    }
}

private extension ProductCardData {
    
    convenience init(id: Int, currency: Currency, ownerId: Int = 0, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .active, loanBaseParam: ProductCardData.LoanBaseParamInfoData? = nil, statusPc: ProductData.StatusPC = .active, isMain: Bool = true, cardType: ProductCardData.CardType = .main) {
        
        self.init(id: id, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: ownerId, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], accountId: nil, cardId: 0, name: "", validThru: Date(), status: status, expireDate: nil, holderName: nil, product: nil, branch: "", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: loanBaseParam, statusPc: statusPc, isMain: isMain, externalId: nil, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "", cardType: cardType)
    }
    
    convenience init(id: Int, currency: Currency = .rub, ownerId: Int = 0, allowCredit: Bool = true, allowDebit: Bool = true, cardType: ProductCardData.CardType) {
        
        self.init(id: id, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: ownerId, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], accountId: nil, cardId: 0, name: "", validThru: Date(), status: .active, expireDate: nil, holderName: nil, product: nil, branch: "", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: .active, isMain: nil, externalId: nil, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "", cardType: cardType)
    }
}

private extension ProductCardData.LoanBaseParamInfoData {
    
    init(clientId: Int) {
        
        self.init(loanId: 0, clientId: clientId, number: "", currencyId: nil, currencyNumber: nil, currencyCode: nil, minimumPayment: nil, gracePeriodPayment: nil, overduePayment: nil, availableExceedLimit: nil, ownFunds: nil, debtAmount: nil, totalAvailableAmount: nil, totalDebtAmount: nil)
    }
}

private extension ProductAccountData {
    
    convenience init(id: Int, currency: Currency, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .notBlocked) {
        
        self.init(id: id, productType: .account, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 0, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], externalId: 0, name: "", dateOpen: Date(), status: status, branchName: nil, miniStatement: [], order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "", detailedRatesUrl: "", detailedConditionUrl: "")
    }
}

private extension ProductDepositData {
    
    convenience init(id: Int, currency: Currency, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .active) {
        
        self.init(id: id, productType: .account, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 0, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], depositProductId: 0, depositId: 0, interestRate: 0, accountId: 0, creditMinimumAmount: 0, minimumBalance: 0, endDate: nil, endDateNf: true, isDemandDeposit: true, isDebitInterestAvailable: false, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
}

private extension ProductLoanData {
    
    convenience init(id: Int, currency: Currency, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .active) {
        
        self.init(id: id, productType: .account, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 0, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], currencyNumber: 0, bankProductId: 0, amount: 0, currentInterestRate: 0, principalDebt: 0, defaultPrincipalDebt: nil, totalAmountDebt: nil, principalDebtAccount: "", settlementAccount: "", settlementAccountId: 0, dateLong: Date(), strDateLong: "", order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
}

//MARK: - Card

extension ProductData {
    
    static let cardActiveMainDebitOnlyRub = ProductCardData(id: 11, currency: .rub, allowCredit: false)
    static let cardBlockedMainRub = ProductCardData(id: 12, currency: .rub, status: .blocked, statusPc: .blockedByBank)
    static let cardActiveAddCreditOnlyRub = ProductCardData(id: 13, currency: .rub, allowDebit: false, isMain: false)
    
    static let cardActiveMainUsd = ProductCardData(id: 21, currency: .usd)
    static let cardBlockedMainUsd = ProductCardData(id: 22, currency: .usd, status: .blocked, statusPc: .blockedByBank)
    static let cardActiveAddUsd = ProductCardData(id: 23, currency: .usd, isMain: false)
    
    static let cardLoanActiveMainRub = ProductCardData(id: 31, currency: .rub, ownerId: 123, loanBaseParam: .init(clientId: 123))
    static let cardLoanBlockedMainRub = ProductCardData(id: 32, currency: .rub, ownerId: 123, status: .blocked, loanBaseParam: .init(clientId: 123), statusPc: .blockedByBank)
    static let cardLoanActiveAddRub = ProductCardData(id: 33, currency: .rub, ownerId: 123, loanBaseParam: .init(clientId: 123), isMain: false)
    
    static let cardLoanActiveMainUsd = ProductCardData(id: 41, currency: .usd, ownerId: 123, loanBaseParam: .init(clientId: 123))
    static let cardLoanBlockedMainUsd = ProductCardData(id: 42, currency: .usd, ownerId: 123, status: .blocked, loanBaseParam: .init(clientId: 123), statusPc: .blockedByBank)
    static let cardLoanActiveAddUsd = ProductCardData(id: 43, currency: .usd, ownerId: 123, loanBaseParam: .init(clientId: 123), isMain: false)
    
    static let cardAdditionalSelfDebitOnlyRub = ProductCardData(id: 151, currency: .rub, allowCredit: false, cardType: .additionalSelf)
    static let cardAdditionalSelfAccOwnDebitOnlyRub = ProductCardData(id: 152, currency: .rub, allowCredit: false, cardType: .additionalSelfAccOwn)
    static let cardAdditionalOtherDebitOnlyRub = ProductCardData(id: 153, currency: .rub, allowCredit: false, cardType: .additionalOther)
}

extension Array where Element == ProductData {
    
    static let cardProducts: Self = [
        .cardActiveMainDebitOnlyRub,
        .cardBlockedMainRub,
        .cardActiveAddCreditOnlyRub,
        
        .cardActiveMainUsd,
        .cardBlockedMainUsd,
        .cardActiveAddUsd,
        
        .cardLoanActiveMainRub,
        .cardLoanBlockedMainRub,
        .cardLoanActiveAddRub,
        
        .cardLoanActiveMainUsd,
        .cardLoanBlockedMainUsd,
        .cardLoanActiveAddUsd,
        
        .cardAdditionalSelfDebitOnlyRub,
        .cardAdditionalSelfAccOwnDebitOnlyRub,
        .cardAdditionalOtherDebitOnlyRub
    ]
}

//MARK: - Account

extension ProductData {
    
    static let accountActiveRub = ProductAccountData(id: 51, currency: .rub)
    static let accountBlockedRub = ProductAccountData(id: 52, currency: .rub, status: .blockedByBank)
    static let accountActiveUsd = ProductAccountData(id: 61, currency: .usd)
    static let accountBlockedUsd = ProductAccountData(id: 62, currency: .usd, status: .blockedByBank)
}

extension Array where Element == ProductData {
    
    static let accountProducts: Self = [
        .accountActiveRub,
        .accountBlockedRub,
        .accountActiveUsd,
        .accountBlockedUsd
    ]
}

//MARK: - Deposit

extension ProductData {
    
    static let depositActiveRub = ProductDepositData(id: 71, currency: .rub)
    static let depositActiveUsd = ProductDepositData(id: 72, currency: .rub)
}

extension Array where Element == ProductData {
    
    static let depositProducts: Self = [
        .depositActiveRub,
        .depositActiveUsd]
}

//MARK: - Loan

extension ProductData {
    
    static let loanActiveRub = ProductLoanData(id: 81, currency: .rub)
    static let loanActiveUsd = ProductLoanData(id: 82, currency: .usd)
}

extension Array where Element == ProductData {
    
    static let loanProducts: Self = [
        .loanActiveRub,
        .loanActiveRub]
}

extension Array where Element == ProductData {
    
    static let all: Self = .accountProducts + .cardProducts + .loanProducts + .depositProducts
}
