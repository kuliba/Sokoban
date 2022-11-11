//
//  ProductModelTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 14.04.2022.
//

import XCTest
@testable import ForaBank

class ProductModelTests: XCTestCase {

    //MARK: - Products data
    
    func testReduceProducts_New_Type_Not_Empty() throws {

        //given
        let existing: ProductsData = [.card : [Self.sampleCard]]
        
        // when
        let result = Model.reduce(products: existing, with: [Self.sampleAccount], for: .account)
        
        // then
        XCTAssertNotNil(result[.card])
        XCTAssertEqual(result[.card]?.count, 1)
        XCTAssertEqual(result[.card]?.first, Self.sampleCard)
        
        XCTAssertNotNil(result[.account])
        XCTAssertEqual(result[.account]?.count, 1)
        XCTAssertEqual(result[.account]?.first, Self.sampleAccount)
        
        XCTAssertNil(result[.deposit])
        XCTAssertNil(result[.loan])
    }
    
    func testReduceProducts_New_Type_Empty() throws {

        //given
        let existing: ProductsData = [.card : [Self.sampleCard]]
        
        // when
        let result = Model.reduce(products: existing, with: [], for: .account)
        
        // then
        XCTAssertEqual(existing, result)
    }
    
    func testReduceProducts_Existing_Type_Not_Empty_Add() throws {

        //given
        let existing: ProductsData = [.card : [Self.sampleCard]]
        
        // when
        let result = Model.reduce(products: existing, with: [Self.sampleCard, Self.sampleCardTwo], for: .card)
        
        // then
        XCTAssertNotNil(result[.card])
        XCTAssertEqual(result[.card]?.count, 2)
        XCTAssertEqual(result[.card]?[0], Self.sampleCard)
        XCTAssertEqual(result[.card]?[1], Self.sampleCardTwo)

        XCTAssertNil(result[.account])
        XCTAssertNil(result[.deposit])
        XCTAssertNil(result[.loan])
    }
    
    func testReduceProducts_Existing_Type_Not_Empty_Replace() throws {

        //given
        let existing: ProductsData = [.card : [Self.sampleCard]]
        
        // when
        let result = Model.reduce(products: existing, with: [Self.sampleCardTwo], for: .card)
        
        // then
        XCTAssertNotNil(result[.card])
        XCTAssertEqual(result[.card]?.count, 1)
        XCTAssertEqual(result[.card]?.first, Self.sampleCardTwo)

        XCTAssertNil(result[.account])
        XCTAssertNil(result[.deposit])
        XCTAssertNil(result[.loan])
    }
    
    func testReduceProducts_Existing_Type_Empty() throws {

        //given
        let existing: ProductsData = [.card : [Self.sampleCard]]
        
        // when
        let result = Model.reduce(products: existing, with: [], for: .card)
        
        // then
        XCTAssertNil(result[.card])
        XCTAssertNil(result[.account])
        XCTAssertNil(result[.deposit])
        XCTAssertNil(result[.loan])
    }
    
    func testReduceProducts_Existing_Type_Not_Empty_Replace_Wrong_Type() throws {

        //given
        let existing: ProductsData = [.card : [Self.sampleCard]]
        
        // when
        let result = Model.reduce(products: existing, with: [Self.sampleAccount], for: .card)
        
        // then
        XCTAssertEqual(existing, result)
    }
    
    //MARK: - Dynamic parameter
    
    func testReduceProductsParam_Existing() throws {

        //given
        let product = Self.sampleCard
        let existing: ProductsData = [.card : [product]]
        
        // when
        let params = ProductDynamicParamsData(balance: 100, balanceRub: 100, customName: "Custom Name")
        let result = Model.reduce(products: existing, with: params, productId: product.id)
        
        // then
        XCTAssertNotNil(result[.card])
        XCTAssertEqual(result[.card]?.count, 1)
        XCTAssertNotNil(result[.card]?.first?.balance)
        XCTAssertEqual(result[.card]!.first!.balance!, 100, accuracy: .ulpOfOne)
        XCTAssertNotNil(result[.card]?.first?.balanceRub)
        XCTAssertEqual(result[.card]!.first!.balanceRub!, 100, accuracy: .ulpOfOne)
        XCTAssertEqual(result[.card]?.first?.customName, "Custom Name")

        XCTAssertNil(result[.account])
        XCTAssertNil(result[.deposit])
        XCTAssertNil(result[.loan])
    }
    
    func testReduceProductsParam_Not_Existed() throws {

        //given
        let product = Self.sampleCard
        let existing: ProductsData = [.card : [product]]
        
        // when
        let params = ProductDynamicParamsData(balance: 100, balanceRub: 100, customName: "Custom Name")
        let result = Model.reduce(products: existing, with: params, productId: 123)
        
        // then
        XCTAssertEqual(existing, result)
    }
    
    //MARK: - Dynamic parameters
    
    func testReduceProductsParams_List() throws {
             
        //given
        let productCard = Self.sampleCard
        let productAcc = Self.sampleAccount
        let productDep = Self.sampleDeposit
        let existing: ProductsData = [.card : [productCard], .account: [productAcc], .deposit: [productDep]]
        
        // when
        let params: ProductsDynamicParams = [.init(id: productCard.id, type: .card, dynamicParams: .init(balance: 200, balanceRub: 200, customName: "Custom Card")), .init(id: productDep.id, type: .deposit, dynamicParams: .init(balance: 300, balanceRub: 300, customName: "Custom Dep"))]
        let result = Model.reduce(products: existing, with: params)
        
        // then
        XCTAssertNotNil(result[.card])
        XCTAssertEqual(result[.card]?.count, 1)
        XCTAssertNotNil(result[.card]?.first?.balance)
        XCTAssertEqual(result[.card]!.first!.balance!, 200, accuracy: .ulpOfOne)
        XCTAssertNotNil(result[.card]?.first?.balanceRub)
        XCTAssertEqual(result[.card]!.first!.balanceRub!, 200, accuracy: .ulpOfOne)
        XCTAssertEqual(result[.card]?.first?.customName, "Custom Card")
        
        XCTAssertNotNil(result[.account])
        XCTAssertEqual(result[.account]?.count, 1)
        XCTAssertEqual(result[.account]?.first, productAcc)
        
        XCTAssertNotNil(result[.deposit])
        XCTAssertEqual(result[.deposit]?.count, 1)
        XCTAssertNotNil(result[.deposit]?.first?.balance)
        XCTAssertEqual(result[.deposit]!.first!.balance!, 300, accuracy: .ulpOfOne)
        XCTAssertNotNil(result[.deposit]?.first?.balanceRub)
        XCTAssertEqual(result[.deposit]!.first!.balanceRub!, 300, accuracy: .ulpOfOne)
        XCTAssertEqual(result[.deposit]?.first?.customName, "Custom Dep")
        
        XCTAssertNil(result[.loan])
    }
    
    func testReduceProductsParams_List_Not_Existed() throws {
             
        //given
        let productCard = Self.sampleCard
        let productAcc = Self.sampleAccount
        let productDep = Self.sampleDeposit
        let existing: ProductsData = [.card : [productCard], .account: [productAcc], .deposit: [productDep]]
        
        // when
        let params: ProductsDynamicParams = [.init(id: 500, type: .card, dynamicParams: .init(balance: 200, balanceRub: 200, customName: "Custom Card")), .init(id: 700, type: .deposit, dynamicParams: .init(balance: 300, balanceRub: 300, customName: "Custom Dep"))]
        let result = Model.reduce(products: existing, with: params)
        
        // then
        XCTAssertEqual(existing, result)
    }
    
    //MARK: - Activate card
    
    func testReduceProducts_Activate_Card_Existing() throws {

        //given
        let product = Self.sampleCard
        let existing: ProductsData = [.card : [product]]
        
        // when
        let result = Model.reduce(products: existing, cardID: product.id)
        
        // then
        XCTAssertNotNil(result[.card])
        XCTAssertEqual(result[.card]?.count, 1)
        XCTAssertEqual(result[.card]?.first?.id, product.id)
        XCTAssertTrue(product.isActivated)

        XCTAssertNil(result[.account])
        XCTAssertNil(result[.deposit])
        XCTAssertNil(result[.loan])
    }
}

fileprivate extension ProductModelTests {
    
    static let sampleCard = ProductCardData(id: 10, productType: .loan, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "Card", additionalField: nil, customName: nil, productName: "Card", openDate: nil, ownerId: 0, branchId: 0, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], accountId: nil, cardId: 0, name: "CARD", validThru: Date(), status: .active, expireDate: nil, holderName: nil, product: nil, branch: "", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: nil, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    
    static let sampleCardTwo = ProductCardData(id: 11, productType: .loan, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "Card", additionalField: nil, customName: nil, productName: "Card", openDate: nil, ownerId: 0, branchId: 0, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], accountId: nil, cardId: 0, name: "CARD", validThru: Date(), status: .active, expireDate: nil, holderName: nil, product: nil, branch: "", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: nil, order: 1, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    
    static let sampleAccount = ProductAccountData(id: 20, productType: .loan, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "Acc", additionalField: nil, customName: nil, productName: "Acc", openDate: nil, ownerId: 0, branchId: 0, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], externalId: 0, name: "", dateOpen: Date(), status: .active, branchName: nil, miniStatement: [], order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    
    static let sampleDeposit = ProductDepositData(id: 30, productType: .loan, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "Dep", additionalField: nil, customName: nil, productName: "Dep", openDate: nil, ownerId: 0, branchId: 0, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], depositProductId: 0, depositId: 0, interestRate: 0, accountId: 0, creditMinimumAmount: 0, minimumBalance: 0, endDate: nil, endDateNf: nil, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    
    static let sampleLoan = ProductLoanData(id: 40, productType: .loan, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "Loan", additionalField: nil, customName: nil, productName: "Loan", openDate: nil, ownerId: 0, branchId: 0, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], currencyNumber: 0, bankProductId: 0, amount: 500, currentInterestRate: 0.18, principalDebt: 0, defaultPrincipalDebt: 0, totalAmountDebt: 0, principalDebtAccount: "1234", settlementAccount: "1234", settlementAccountId: 2, dateLong: Date(), strDateLong: "", order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
}
