//
//  MyProductsSectionViewModelTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import XCTest
@testable import ForaBank

final class MyProductsSectionViewModelTests: XCTestCase {
    
    func test_myProductsSection_shouldSetAmountFormatter() {
        
        let myProductsSection = makeSUT()
        
        myProductsSection.update(with: loanProduct(amount: 123.45))
        
        XCTAssertNoDiff(myProductsSection.balance, "123,45 ₽")
    }
}

extension MyProductsSectionViewModelTests {
    
    func makeSUT(
    ) -> MyProductsSectionItemViewModel {
        
        let model = Model.emptyMock
        model.currencyList.value.append(.rub)
        
        return .init(
            productData: loanProduct(),
            model: model
        )
    }
    
    func loanProduct(
        amount: Double = 10
    ) -> ProductLoanData {
        .init(
            id: 1,
            productType: .loan,
            number: "number",
            numberMasked: "numberMasked",
            accountNumber: "accountNumber",
            balance: 10,
            balanceRub: 10,
            currency: "RUB",
            mainField: "mainField",
            additionalField: "additionalField",
            customName: "customName",
            productName: "productName",
            openDate: Date(),
            ownerId: 1,
            branchId: 1,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: .test,
            largeDesign: .test,
            mediumDesign: .test,
            smallDesign: .test,
            fontDesignColor: .init(description: ""),
            background: [.init(description: "")],
            currencyNumber: 2,
            bankProductId: 1,
            amount: amount,
            currentInterestRate: 10,
            principalDebt: 10,
            defaultPrincipalDebt: 10,
            totalAmountDebt: amount,
            principalDebtAccount: "principalDebtAccount",
            settlementAccount: "settlementAccount",
            settlementAccountId: 1,
            dateLong: Date(),
            strDateLong: "strDateLong",
            order: 1,
            visibility: true,
            smallDesignMd5hash: "smallDesignMd5hash",
            smallBackgroundDesignHash: "smallBackgroundDesignHash"
        )
    }
}
