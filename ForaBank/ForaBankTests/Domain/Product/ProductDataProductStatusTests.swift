//
//  ProductDataProductStatusTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 17.05.2024.
//

import XCTest
@testable import ForaBank

final class ProductDataProductStatusTests: XCTestCase {

    // MARK: - test productStatus

    // MARK: - for card
    
    func test_productStatus_active_visibility_shouldReturnActive() {
        
        let sut = makeSUT(productType: .card, status: .active, visibility: true)
        
        XCTAssertNoDiff(sut.productStatus, .active)
    }
    
    func test_productStatus_active_notVisibility_shouldReturnNotVisible() {
        
        let sut = makeSUT(productType: .card, status: .active, visibility: false)
        
        XCTAssertNoDiff(sut.productStatus, .notVisible)
    }

    func test_productStatus_blockedUnlockAvailable_visibility_shouldReturnBlocked() {
        
        let sut = makeSUT(productType: .card, status: .blockedUnlockAvailable, visibility: true)
        
        XCTAssertNoDiff(sut.productStatus, .blocked)
    }
    
    func test_productStatus_blockedUnlockAvailable_notVisibility_shouldReturnBlockedNotVisible() {
        
        let sut = makeSUT(productType: .card, status: .blockedUnlockAvailable, visibility: false)
        
        XCTAssertNoDiff(sut.productStatus, .blockedNotVisible)
    }

    func test_productStatus_blockedUnlockNotAvailable_visibility_shouldReturnBlocked() {
        
        let sut = makeSUT(productType: .card, status: .blockedUnlockNotAvailable, visibility: true)
        
        XCTAssertNoDiff(sut.productStatus, .blocked)
    }
    
    func test_productStatus_blockedUnlockNotAvailable_notVisibility_shouldReturnBlockedNotVisible() {
        
        let sut = makeSUT(productType: .card, status: .blockedUnlockNotAvailable, visibility: false)
        
        XCTAssertNoDiff(sut.productStatus, .blockedNotVisible)
    }

    func test_productStatus_notActive_visibility_shouldReturnActive() {
        
        let sut = makeSUT(productType: .card, status: .notActivated, visibility: true)
        
        XCTAssertNoDiff(sut.productStatus, .notActive)
    }
    
    func test_productStatus_notActive_notVisibility_shouldReturnNotVisible() {
        
        let sut = makeSUT(productType: .card, status: .notActivated, visibility: false)
        
        XCTAssertNoDiff(sut.productStatus, .notActive)
    }
    
    // MARK: - for account

    func test_account_productStatus_visibility_shouldReturnActive() {
        
        let sut = makeSUT(productType: .account, visibility: true)
        
        XCTAssertNoDiff(sut.productStatus, .active)
    }
    
    func test_account_productStatus_notVisibility_shouldReturnNotVisible() {
        
        let sut = makeSUT(productType: .account, visibility: false)
        
        XCTAssertNoDiff(sut.productStatus, .notVisible)
    }
    
    // MARK: - for deposit

    func test_deposit_productStatus_visibility_shouldReturnActive() {
        
        let sut = makeSUT(productType: .deposit, visibility: true)
        
        XCTAssertNoDiff(sut.productStatus, .active)
    }
    
    func test_deposit_productStatus_notVisibility_shouldReturnNotVisible() {
        
        let sut = makeSUT(productType: .deposit, visibility: false)
        
        XCTAssertNoDiff(sut.productStatus, .notVisible)
    }

    // MARK: - for loan

    func test_loan_productStatus_visibility_shouldReturnActive() {
        
        let sut = makeSUT(productType: .loan, visibility: true)
        
        XCTAssertNoDiff(sut.productStatus, .active)
    }
    
    func test_loan_productStatus_notVisibility_shouldReturnNotVisible() {
        
        let sut = makeSUT(productType: .loan, visibility: false)
        
        XCTAssertNoDiff(sut.productStatus, .notVisible)
    }

    func makeSUT(
        productType: ProductType = .card,
        status: ProductCardData.StatusCard? = nil,
        visibility: Bool = true
    ) -> ProductData {
        
        switch productType {
        case .card:
            return ProductCardData.init(
                id: 1,
                productType: productType,
                number: "1111",
                numberMasked: "****",
                accountNumber: nil,
                balance: nil,
                balanceRub: 10,
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
                visibility: visibility,
                smallDesignMd5hash: "",
                smallBackgroundDesignHash: "",
                statusCard: status,
                cardType: .main,
                idParent: nil
            )
            
        case .account:
            return ProductAccountData(
                id: 20,
                productType: .account,
                number: nil,
                numberMasked: nil,
                accountNumber: nil,
                balance: 10,
                balanceRub: nil,
                currency: "RUB",
                mainField: "Acc",
                additionalField: nil,
                customName: nil,
                productName: "Acc",
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
                externalId: 0,
                name: "",
                dateOpen: Date(),
                status: .active,
                branchName: nil,
                miniStatement: [],
                order: 0,
                visibility: visibility,
                smallDesignMd5hash: "",
                smallBackgroundDesignHash: "",
                detailedRatesUrl: "",
                detailedConditionUrl: ""
            )
            
        case .deposit:
            return ProductDepositData(
                id: 30,
                productType: .deposit,
                number: "11",
                numberMasked: nil,
                accountNumber: nil,
                balance: 10,
                balanceRub: nil,
                currency: "RUB",
                mainField: "Dep",
                additionalField: nil,
                customName: nil,
                productName: "Dep",
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
                depositProductId: 0,
                depositId: 0,
                interestRate: 0,
                accountId: 1,
                creditMinimumAmount: 0,
                minimumBalance: 0,
                endDate: .dateUTC(with: 1),
                endDateNf: false,
                isDemandDeposit: true,
                isDebitInterestAvailable: true,
                order: 0,
                visibility: visibility,
                smallDesignMd5hash: "",
                smallBackgroundDesignHash: ""
            )
        case .loan:
            return ProductLoanData(
                id: 40,
                productType: .loan,
                number: "1",
                numberMasked: nil,
                accountNumber: nil,
                balance: 10,
                balanceRub: nil,
                currency: "RUB",
                mainField: "Loan",
                additionalField: nil,
                customName: nil,
                productName: "Loan",
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
                currencyNumber: 0,
                bankProductId: 0,
                amount: 500,
                currentInterestRate: 1,
                principalDebt: 0,
                defaultPrincipalDebt: 0,
                totalAmountDebt: 0,
                principalDebtAccount: "1234",
                settlementAccount: "settlementAccount",
                settlementAccountId: 2,
                dateLong: .dateUTC(with: 1),
                strDateLong: "",
                order: 0,
                visibility: visibility,
                smallDesignMd5hash: "",
                smallBackgroundDesignHash: ""
            )
        }
    }
}
