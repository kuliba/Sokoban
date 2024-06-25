//
//  ProductDataTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 10.08.2023.
//

import XCTest
@testable import ForaBank

class ProductDataTests: XCTestCase {
    
    //MARK: DisplayNumber Helper
    func test_displayNumber_card_shouldReturnNumber() throws {
        
        let sut = makeSUT(
            number: "1234",
            productType: .card
        )

        XCTAssertNoDiff(sut.displayNumber, "1234")
    }
    
    func test_displayNumber_card_shouldReturnNil() throws {
        
        let sut = makeSUT(
            number: nil,
            productType: .card
        )

        XCTAssertNoDiff(sut.displayNumber, nil)
    }
    
    func test_displayNumber_loan_shouldReturnSettlementAccount() throws {
        
        let sut = makeSUT(
            settlementAccount: "1234",
            productType: .loan
        )

        XCTAssertNoDiff(sut.displayNumber, "1234")
    }
    
    func test_displayNumber_deposit_shouldReturnAccountNumber() throws {
        
        let sut = makeSUT(
            accountNumber: "1234",
            productType: .deposit
        )

        XCTAssertNoDiff(sut.displayNumber, "1234")
    }
    
    func test_displayNumber_deposit_shouldReturnNil() throws {
        
        let sut = makeSUT(
            accountNumber: nil,
            productType: .deposit
        )

        XCTAssertNoDiff(sut.displayNumber, nil)
    }
    
    //MARK: DisplayPeriod Helper
    
    func test_displayPeriod_card_shouldReturnExpireDate() throws {
        
        let sut = makeSUT(
            expireDate: "expireDate",
            productType: .card
        )

        XCTAssertNoDiff(sut.displayPeriod, "expireDate")
    }
    
    func test_displayPeriod_card_shouldReturnNil() throws {
        
        let sut = makeSUT(
            expireDate: nil,
            productType: .card
        )

        XCTAssertNoDiff(sut.displayPeriod, nil)
    }
    
    func test_displayPeriod_loan_shouldReturnDateLong() throws {
        
        let sut = makeSUT(
            dateLong: .dateUTC(with: 1),
            productType: .loan
        )

        XCTAssertNoDiff(sut.displayPeriod, "01/70")
    }
   
    func test_displayPeriod_deposit_shouldReturnNil() throws {
        
        let sut = makeSUT(
            productType: .account
        )

        XCTAssertNoDiff(sut.displayPeriod, nil)
    }
    
    //MARK: Display Name Helper
    
    func test_displayName_card_shouldReturnCardName() throws {
        
        let sut = makeSUT(
            customName: "Card",
            productType: .card
        )

        XCTAssertNoDiff(sut.displayName, "Card")
    }
    
    func test_displayName_card_shouldReturnCustomName() throws {
        
        let sut = makeSUT(
            customName: "Card1",
            productType: .card
        )

        XCTAssertNoDiff(sut.displayName, "Card1")
    }
    
    // MARK: - Navigation Bar Name
    
    func test_navigationBarName_shouldReturnCustomName() throws {
        
        let sut = makeSUT(
            additionalField: "AdditionalField", 
            customName: "CustomName",
            mainField: "MainField",
            productType: .card
        )

        XCTAssertNoDiff(sut.navigationBarName, "CustomName")
    }

    func test_navigationBarName_shouldReturnAdditionalField_whenCustomNameIsNil() throws {
        
        let sut = makeSUT(
            additionalField: "AdditionalField", 
            customName: nil,
            mainField: "MainField",
            productType: .card
        )

        XCTAssertNoDiff(sut.navigationBarName, "AdditionalField")
    }

    func test_navigationBarName_shouldReturnMainField_whenCustomNameAndAdditionalFieldAreNil() throws {
        
        let sut = makeSUT(
            additionalField: nil, customName: nil,
            mainField: "MainField",
            productType: .card
        )

        XCTAssertNoDiff(sut.navigationBarName, "MainField")
    }

    
    //MARK: Balance Value Helper
    
    func test_balance_card_shouldReturnBalanceValue() throws {
        
        let sut = makeSUT(
            balance: 10,
            productType: .card
        )

        XCTAssertNoDiff(sut.balanceValue, 10)
    }
    
    func test_balance_card_shouldReturn_0() throws {
        
        let sut = makeSUT(
            balance: 0,
            productType: .card
        )

        XCTAssertNoDiff(sut.balanceValue, 0)
    }
    
    //MARK: Subtitle Helper
    
    func test_subtitle_card_shouldReturnDescription() throws {
        
        let sut = makeSUT(
            additionalField: "Зарплатная",
            productType: .card
        )

        XCTAssertNoDiff(sut.subtitle, "Зарплатная")
    }
    
    func test_subtitle_card_shouldReturnNil() throws {
        
        let sut = makeSUT(
            additionalField: nil,
            productType: .card
        )

        XCTAssertNoDiff(sut.subtitle, nil)
    }
    
    func test_subtitle_deposit_shouldReturnInterestRate() throws {
        
        let sut = makeSUT(
            interestRate: 0,
            productType: .deposit
        )

        XCTAssertNoDiff(sut.subtitle, "Ставка 0.0%")
    }
    
    func test_subtitle_loan_shouldReturnCurrentInterestRate() throws {
        
        let sut = makeSUT(
            currentInterestRate: 0.18,
            productType: .loan
        )

        XCTAssertNoDiff(sut.subtitle, "Ставка 0.18%")
    }
    
    func test_subtitle_account_shouldReturnNil() throws {
        
        let sut = makeSUT(
            productType: .account
        )

        XCTAssertNoDiff(sut.subtitle, nil)
    }
    
    //MARK: Description Helper
    
    func test_description_card_shouldReturnDescription() throws {
        
        let sut = makeSUT(
            productType: .card
        )

        XCTAssertNoDiff(sut.description, ["1234", "Зарплатная"])
    }
    
    func test_description_deposit_shouldReturnDescription() throws {
        
        let sut = makeSUT(
            interestRate: 0,
            endDate: .dateUTC(with: 1),
            accountNumber: "1234",
            productType: .deposit
        )

        XCTAssertNoDiff(sut.description, [
            "1234",
            "Ставка 0.0%",
            "01.01.70"
        ])
    }
    
    //MARK: Date Long String Helper

    func test_dateLongString_deposit_shouldReturnFormattedDate() throws {
        
        let sut = makeSUT(
            endDate: .dateUTC(with: 1),
            accountNumber: nil,
            productType: .deposit
        )

        XCTAssertNoDiff(sut.dateLongString, "01.01.70")
    }
    
    func test_dateLongString_deposit_shouldReturnNil() throws {
        
        let sut = makeSUT(
            endDate: nil,
            productType: .deposit
        )

        XCTAssertNoDiff(sut.dateLongString, nil)
    }
    
    func test_dateLongString_loan_shouldReturnFormattedString() throws {
        
        let sut = makeSUT(
            productType: .loan
        )

        XCTAssertNoDiff(sut.dateLongString, "01.01.70")
    }
    
    func test_dateLongString_card_shouldReturnNil() throws {
        
        let sut = makeSUT(
            productType: .card
        )

        XCTAssertNoDiff(sut.dateLongString, nil)
    }
    
    //MARK: AdditionalAccountId
    
    func test_additionalAccountId_card_shouldReturn_1() throws {
        
        let sut = makeSUT(
            productType: .card
        )

        XCTAssertNoDiff(sut.additionalAccountId, 1)
    }
    
    func test_additionalAccountId_deposit_shouldReturn_1() throws {
        
        let sut = makeSUT(
            productType: .deposit
        )

        XCTAssertNoDiff(sut.additionalAccountId, 1)
    }
    
    func test_additionalAccountId_loan_shouldReturnNil() throws {
        
        let sut = makeSUT(
            productType: .loan
        )

        XCTAssertNoDiff(sut.additionalAccountId, nil)
    }
    
    //MARK: Currency Value Helper
    
    func test_currencyValue_shouldReturnRub() throws {
        
        let sut = makeSUT(
            productType: .card
        )

        XCTAssertNoDiff(sut.currencyValue, .rub)
    }
}

extension ProductDataTests {
    
    func makeSUT(
        currentInterestRate: Double = 0.18,
        interestRate: Double = 0,
        settlementAccount: String = "1234",
        accountId: Int = 1,
        additionalField: String? = "Зарплатная",
        balance: Double? = nil,
        customName: String? = nil,
        mainField: String = "Card",
        dateLong: Date = .dateUTC(with: 1),
        endDate: Date? = .dateUTC(with: 1),
        accountNumber: String? = "1234",
        number: String? = "1234",
        expireDate: String? = "expireDate",
        productType: ProductType
    ) -> ProductData {
        
        switch productType {
            
        case .card:
            return ProductCardData(
                id: 10,
                productType: .loan,
                number: number,
                numberMasked: nil,
                accountNumber: accountNumber,
                balance: balance,
                balanceRub: nil,
                currency: "RUB",
                mainField: mainField,
                additionalField: additionalField,
                customName: customName,
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
                accountId: accountId,
                cardId: 0,
                name: "CARD",
                validThru: Date(),
                status: .active,
                expireDate: expireDate,
                holderName: nil,
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
                smallBackgroundDesignHash: ""
            )
        case .account:
            return ProductAccountData(
                id: 20,
                productType: .account,
                number: number,
                numberMasked: nil,
                accountNumber: accountNumber,
                balance: balance,
                balanceRub: nil,
                currency: "RUB",
                mainField: "Acc",
                additionalField: additionalField,
                customName: customName,
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
                visibility: true,
                smallDesignMd5hash: "",
                smallBackgroundDesignHash: "",
                detailedRatesUrl: "",
                detailedConditionUrl: ""
            )
            
        case .deposit:
            return ProductDepositData(
                id: 30,
                productType: .deposit,
                number: number,
                numberMasked: nil,
                accountNumber: accountNumber,
                balance: balance,
                balanceRub: nil,
                currency: "RUB",
                mainField: "Dep",
                additionalField: additionalField,
                customName: customName,
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
                interestRate: interestRate,
                accountId: accountId,
                creditMinimumAmount: 0,
                minimumBalance: 0,
                endDate: endDate,
                endDateNf: false,
                isDemandDeposit: true,
                isDebitInterestAvailable: true,
                order: 0,
                visibility: true,
                smallDesignMd5hash: "",
                smallBackgroundDesignHash: ""
            )
        case .loan:
            return ProductLoanData(
                id: 40,
                productType: .loan,
                number: number,
                numberMasked: nil,
                accountNumber: accountNumber,
                balance: balance,
                balanceRub: nil,
                currency: "RUB",
                mainField: "Loan",
                additionalField: additionalField,
                customName: customName,
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
                currentInterestRate: currentInterestRate,
                principalDebt: 0,
                defaultPrincipalDebt: 0,
                totalAmountDebt: 0,
                principalDebtAccount: "1234",
                settlementAccount: settlementAccount,
                settlementAccountId: 2,
                dateLong: dateLong,
                strDateLong: "",
                order: 0,
                visibility: true,
                smallDesignMd5hash: "",
                smallBackgroundDesignHash: ""
            )
        }
    }
}
