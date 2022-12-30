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
    
    static let cardProducts = [cardActiveMainDebitOnlyRub,
                               cardBlockedMainRub,
                               cardActiveAddCreditOnlyRub,
                               
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
    
    //FIXME: current realisation of isProductOwner can't be tested
    /*
    func testCardAdditionalRestrictedRule() {
        
        // given
        let products = Self.cardProducts
        let filter = ProductData.Filter(rules: [ProductData.Filter.CardAdditionalNotOwnedRetrictedRule()])
        
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
                                                ProductData.Filter.CardAdditionalNotOwnedRetrictedRule()])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 11)
        XCTAssertEqual(result[1].id, 21)
    }
     */
}

//MARK: - Account

extension ProductFilterTets {
    
    static let accountActiveRub = ProductAccountData(id: 51, currency: .rub)
    static let accountBlockedRub = ProductAccountData(id: 52, currency: .rub, status: .blockedByBank)
    static let accountActiveUsd = ProductAccountData(id: 61, currency: .usd)
    static let accountBlockedUsd = ProductAccountData(id: 62, currency: .usd, status: .blockedByBank)
    
    static let accountProducts = [accountActiveRub,
                                  accountBlockedRub,
 
                                  accountActiveUsd,
                                  accountBlockedUsd]
    
    func testAccountActiveRule() {
        
        // given
        let products = Self.accountProducts
        let filter = ProductData.Filter(rules: [ProductData.Filter.AccountActiveRule()])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 51)
        XCTAssertEqual(result[1].id, 61)
    }
}

//MARK: - Products General

extension ProductFilterTets {
    
    static let depositActiveRub = ProductDepositData(id: 71, currency: .rub)
    static let depositActiveUsd = ProductDepositData(id: 72, currency: .rub)
    
    static let depositProducts = [depositActiveRub,
                                  depositActiveUsd]
    
    static let loanActiveRub = ProductLoanData(id: 81, currency: .rub)
    static let loanActiveUsd = ProductLoanData(id: 82, currency: .usd)
    
    static let loanProducts = [loanActiveRub,
                               loanActiveRub]
    
    func testTypeCard_CardActiveRule() {
        
        // given
        var products = [ProductData]()
        products.append(contentsOf: Self.cardProducts)
        products.append(contentsOf: Self.accountProducts)
        products.append(contentsOf: Self.depositProducts)
        products.append(contentsOf: Self.loanProducts)
        
        let filter = ProductData.Filter(rules: [ProductData.Filter.ProductTypeRule([.card]),
                                                ProductData.Filter.CardActiveRule()])
        
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
    
    func testTypeCard_CardActive_CurrencyRule() {
        
        // given
        var products = [ProductData]()
        products.append(contentsOf: Self.cardProducts)
        products.append(contentsOf: Self.accountProducts)
        products.append(contentsOf: Self.depositProducts)
        products.append(contentsOf: Self.loanProducts)
        
        let filter = ProductData.Filter(rules: [ProductData.Filter.ProductTypeRule([.card]),
                                                ProductData.Filter.CardActiveRule(),
                                                ProductData.Filter.CurrencyRule([.rub])])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].id, 11)
        XCTAssertEqual(result[1].id, 13)
        XCTAssertEqual(result[2].id, 31)
        XCTAssertEqual(result[3].id, 33)
    }
    
    func testTypeCard_CardActive_DebitRule() {
        
        // given
        var products = [ProductData]()
        products.append(contentsOf: Self.cardProducts)
        products.append(contentsOf: Self.accountProducts)
        products.append(contentsOf: Self.depositProducts)
        products.append(contentsOf: Self.loanProducts)
        
        let filter = ProductData.Filter(rules: [ProductData.Filter.ProductTypeRule([.card]),
                                                ProductData.Filter.CardActiveRule(),
                                                ProductData.Filter.DebitRule()])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 7)
        XCTAssertEqual(result[0].id, 11)
        XCTAssertEqual(result[1].id, 21)
        XCTAssertEqual(result[2].id, 23)
        XCTAssertEqual(result[3].id, 31)
        XCTAssertEqual(result[4].id, 33)
        XCTAssertEqual(result[5].id, 41)
        XCTAssertEqual(result[6].id, 43)
    }
    
    func testTypeCard_CardActive_CreditRule() {
        
        // given
        var products = [ProductData]()
        products.append(contentsOf: Self.cardProducts)
        products.append(contentsOf: Self.accountProducts)
        products.append(contentsOf: Self.depositProducts)
        products.append(contentsOf: Self.loanProducts)
        
        let filter = ProductData.Filter(rules: [ProductData.Filter.ProductTypeRule([.card]),
                                                ProductData.Filter.CardActiveRule(),
                                                ProductData.Filter.CreditRule()])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 7)
        XCTAssertEqual(result[0].id, 13)
        XCTAssertEqual(result[1].id, 21)
        XCTAssertEqual(result[2].id, 23)
        XCTAssertEqual(result[3].id, 31)
        XCTAssertEqual(result[4].id, 33)
        XCTAssertEqual(result[5].id, 41)
        XCTAssertEqual(result[6].id, 43)
    }
    
    func testTypeCard_CardActive_ProductRestrictedRule() {
        
        // given
        var products = [ProductData]()
        products.append(contentsOf: Self.cardProducts)
        products.append(contentsOf: Self.accountProducts)
        products.append(contentsOf: Self.depositProducts)
        products.append(contentsOf: Self.loanProducts)
        
        let filter = ProductData.Filter(rules: [ProductData.Filter.ProductTypeRule([.card]),
                                                ProductData.Filter.CardActiveRule(),
                                                ProductData.Filter.ProductRestrictedRule([43])])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 7)
        XCTAssertEqual(result[0].id, 11)
        XCTAssertEqual(result[1].id, 13)
        XCTAssertEqual(result[2].id, 21)
        XCTAssertEqual(result[3].id, 23)
        XCTAssertEqual(result[4].id, 31)
        XCTAssertEqual(result[5].id, 33)
        XCTAssertEqual(result[6].id, 41)
    }
    
    func testTypeCard_CardActive_AllRestrictedRule() {
        
        // given
        var products = [ProductData]()
        products.append(contentsOf: Self.cardProducts)
        products.append(contentsOf: Self.accountProducts)
        products.append(contentsOf: Self.depositProducts)
        products.append(contentsOf: Self.loanProducts)
        
        let filter = ProductData.Filter(rules: [ProductData.Filter.AllRestrictedRule()])
        
        // when
        let result = filter.filterredProducts(products)
        
        //then
        XCTAssertEqual(result.count, 0)
    }
}

//MARK: - Types

extension ProductFilterTets {
    
    func testFilteredProductTypes() {
        
        // griven
        let products = [Self.cardActiveAddUsd, Self.accountActiveRub, Self.depositActiveRub, Self.loanActiveRub]
        let filter = ProductData.Filter(rules: [ProductData.Filter.ProductTypeRule([.card, .account])])
        
        // when
        let result = filter.filterredProductsTypes(products)
        
        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .card)
        XCTAssertEqual(result[1], .account)
    }
    
    func testFilteredProductTypes_Currency() {
        
        // griven
        let products = [Self.cardActiveAddUsd, Self.accountActiveRub, Self.depositActiveRub, Self.loanActiveRub]
        let filter = ProductData.Filter(rules: [ProductData.Filter.ProductTypeRule([.card, .account]), ProductData.Filter.CurrencyRule([.usd])])
        
        // when
        let result = filter.filterredProductsTypes(products)
        
        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], .card)
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

private extension ProductAccountData {
    
    convenience init(id: Int, currency: Currency, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .notBlocked) {
        
        self.init(id: id, productType: .account, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 0, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], externalId: 0, name: "", dateOpen: Date(), status: status, branchName: nil, miniStatement: [], order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "", detailedRatesUrl: "", detailedConditionUrl: "")
    }
}

private extension ProductDepositData {
    
    convenience init(id: Int, currency: Currency, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .active) {
        
        self.init(id: id, productType: .account, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 0, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], depositProductId: 0, depositId: 0, interestRate: 0, accountId: 0, creditMinimumAmount: 0, minimumBalance: 0, endDate: nil, endDateNf: true, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
}

private extension ProductLoanData {
    
    convenience init(id: Int, currency: Currency, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .active) {
        
        self.init(id: id, productType: .account, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 0, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], currencyNumber: 0, bankProductId: 0, amount: 0, currentInterestRate: 0, principalDebt: 0, defaultPrincipalDebt: nil, totalAmountDebt: nil, principalDebtAccount: "", settlementAccount: "", settlementAccountId: 0, dateLong: Date(), strDateLong: "", order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
}
