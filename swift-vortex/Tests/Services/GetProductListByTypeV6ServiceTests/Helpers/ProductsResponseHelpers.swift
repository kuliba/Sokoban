@testable import GetProductListByTypeV6Service

extension ProductsResponse.Product {
    
    init(
        id: Int,
        productType: ProductsResponse.ProductType,
        uniqueProperties: ProductsResponse.UniqueProperties
    ) {
        self.init(
            commonProperties: .init(
                id: id,
                productType: productType,
                productState: [
                    .default,
                    .notVisible
                ],
                order: 0,
                visibility: true,
                number: "40817810623000001135",
                numberMasked: "40817-810-X-ХXXX-0001135",
                accountNumber: "40817810623000001135",
                currency: "RUB",
                mainField: "Текущий",
                additionalField: nil,
                customName: nil,
                productName: "Текущие счета физ.лиц",
                balance: 22601.59,
                balanceRUB: 22601.59,
                openDate: 1596402000000,
                ownerId: 10002053887,
                branchId: 2000,
                allowDebit: true,
                allowCredit: true,
                fontDesignColor: "FFFFFF",
                smallDesignMd5Hash: "9cd404ac011454ad95146de6560dd794",
                mediumDesignMd5Hash: "121b73bb50858e76e33b176686d8e940",
                largeDesignMd5Hash: "2a3bf21fe2b8e28f3944ab0968f6759d",
                xlDesignMd5Hash: "bf552f2c1d4d174decf46b7acd115068",
                smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6",
                background: [
                    "FF3636"
                ]),
            uniqueProperties: uniqueProperties)
    }
}

extension ProductsResponse.UniqueProperties {
   
    static func account() -> Self {
        
        .account(
            ProductsResponse.Account(
                name: "ВСФ",
                externalID: 10002053887,
                dateOpen: 1596402000000,
                status: .notBlocked,
                branchName: #"АКБ "ФОРА-БАНК" (АО)"#,
                detailedRatesUrl: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_Kotelniki_OrekhovoZuevo_Reutov_Tver_tarifi.pdf",
                detailedConditionUrl: "https://www.forabank.ru/dkbo/dkbo.pdf"
            )
        )
    }
    
    static func deposit(
        depositProductID: Int,
        depositID: Int
    ) -> Self {
        
        .deposit(
            ProductsResponse.Deposit(
                depositProductID: depositProductID,
                depositID: depositID,
                interestRate: 7.1,
                accountID: 20000102037,
                creditMinimumAmount: 2000.0,
                minimumBalance: 5000.0,
                endDate: 1709154000000,
                endDateNF: false,
                demandDeposit: false,
                isDebitInterestAvailable: false
            )
        )
    }
    
    static func card(
        cardId: Int,
        cardType: ProductsResponse.CardType
    ) -> Self {
        
        .card(
            ProductsResponse.Card(
                cardID: cardId,
                idParent: nil,
                accountID: 10004177075,
                cardType: cardType,
                statusCard: .active,
                loanBaseParam: ProductsResponse.LoanBaseParam(
                    loanID: 20000059293,
                    clientID: 10002053887,
                    number: "БК-240305/5200/1",
                    currencyID: 2,
                    currencyNumber: 810,
                    currencyCode: "RUB",
                    minimumPayment: 0.0,
                    gracePeriodPayment: 0.0,
                    overduePayment: 0.0,
                    availableExceedLimit: 0.0,
                    ownFunds: 280027.57,
                    debtAmount: -280027.57,
                    totalAvailableAmount: 100000.0,
                    totalDebtAmount: -280027.57
                ),
                statusPC: .active,
                name: "ВСФ",
                validThru: 1790715600000,
                status: .active,
                expireDate: "09/26",
                holderName: "CHALIKYAN GEVORG",
                product: "VISA REWARDS R-5",
                branch: #"АКБ "ФОРА-БАНК" (АО)"#,
                paymentSystemName: "VISA",
                paymentSystemImageMd5Hash: "d7516b59941d5acd06df25a64ea32660"
            )
        )
    }
    
    static func loan() -> Self {
        
        .loan(
            ProductsResponse.Loan(
                currencyNumber: 2,
                bankProductID: 10000000194,
                amount: 500000.0,
                currentInterestRate: 17.5,
                principalDebt: 488423.84,
                defaultPrincipalDebt: nil,
                totalAmountDebt: 488423.84,
                principalDebtAccount: "45507810700001300403",
                settlementAccount: "40817810110010000262",
                settlementAccountId: 20000004912,
                dateLong: 1853182800000,
                strDateLong: "09/28"
            )
        )
    }
}
