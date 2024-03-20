@testable import GetProductListByTypeService

public extension Array where Element == ProductResponse.Product {
    
    static let loanStubs: Self = [.loanStub1, .loanStub2, .loanStub3]
}

extension ProductResponse.Product {
    
    static let loanStub1: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 20000002425,
            productType: .loan,
            productState: [
                .default,
                .notVisible
            ],
            order: 0,
            visibility: true,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            currency: "RUB",
            mainField: "Сотрудник",
            additionalField: nil,
            customName: nil,
            productName: "Ф_ПотКред",
            balance: nil,
            balanceRUB: nil,
            openDate: nil,
            ownerId: 10002053887,
            branchId: nil,
            allowDebit: false,
            allowCredit: false,
            fontDesignColor: "FFFFFF",
            smallDesignMd5Hash: "adb37ee92357dd56154bff6b64d0db38",
            mediumDesignMd5Hash: "222b894a9b71b974392b7ee22ae26571",
            largeDesignMd5Hash: "a782dc8aac4f1442cb1a8e605b21f337",
            xlDesignMd5Hash: "6a68356ece01dec7819ced110e136ecf",
            smallBackgroundDesignHash: "4e303667d389d73fbe6c7bbf647bbc83",
            background: [
                "80CBC3"
            ]
        ),
        uniqueProperties: .loan(
            ProductResponse.Loan(
                currencyNumber: 2,
                bankProductID: 10000000194,
                amount: 500000.0,
                currentInterestRate: 17.5,
                principalDebt: 488423.84,
                defaultPrincipalDebt: nil,
                totalAmountDebt: 488423.84,
                principalDebtAccount: "45507810110016288296",
                settlementAccount: "40817810110010000262",
                settlementAccountId: 20000004912,
                dateLong: 1853182800000,
                strDateLong: "09/28"
            )
        )
    )
    
    static let loanStub2: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 10002699472,
            productType: .loan,
            productState: [
                .default,
                .notVisible
            ],
            order: 1,
            visibility: true,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            currency: "RUB",
            mainField: "Премиум",
            additionalField: nil,
            customName: nil,
            productName: "Ф_ПотКред",
            balance: nil,
            balanceRUB: nil,
            openDate: nil,
            ownerId: 10002053887,
            branchId: nil,
            allowDebit: false,
            allowCredit: false,
            fontDesignColor: "FFFFFF",
            smallDesignMd5Hash: "adb37ee92357dd56154bff6b64d0db38",
            mediumDesignMd5Hash: "222b894a9b71b974392b7ee22ae26571",
            largeDesignMd5Hash: "a782dc8aac4f1442cb1a8e605b21f337",
            xlDesignMd5Hash: "6a68356ece01dec7819ced110e136ecf",
            smallBackgroundDesignHash: "4e303667d389d73fbe6c7bbf647bbc83",
            background: [
                "80CBC3"
            ]
        ),
        uniqueProperties: .loan(
            ProductResponse.Loan(
                currencyNumber: 2,
                bankProductID: 10000000210,
                amount: 300000.0,
                currentInterestRate: 17.9,
                principalDebt: 178178.96,
                defaultPrincipalDebt: nil,
                totalAmountDebt: 178178.96,
                principalDebtAccount: "45706810616000000000",
                settlementAccount: "40820810016000000002",
                settlementAccountId: 10003812590,
                dateLong: 1750021200000,
                strDateLong: "06/25"
            )
        )
    )
    
    static let loanStub3: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 10002156052,
            productType: .loan,
            productState: [
                .default,
                .notVisible
            ],
            order: 2,
            visibility: true,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            currency: "RUB",
            mainField: "Ипотечный",
            additionalField: "Ипотечный кредит",
            customName: nil,
            productName: "Ф_ИпКред",
            balance: nil,
            balanceRUB: nil,
            openDate: nil,
            ownerId: 10002053887,
            branchId: nil,
            allowDebit: false,
            allowCredit: false,
            fontDesignColor: "FFFFFF",
            smallDesignMd5Hash: "1deea13bf04c558bd34229fed46846a2",
            mediumDesignMd5Hash: "dc3c8f68537620342d2bd4916f9e6a4e",
            largeDesignMd5Hash: "01cf528baad8c71edc4db7535fe6bdc4",
            xlDesignMd5Hash: "8c77f670a3381f28f6b7483468514b54",
            smallBackgroundDesignHash: "75b3d3cc00c325e970874da5cae8bc86",
            background: [
                "FF9636"
            ]
        ),
        uniqueProperties: .loan(
            ProductResponse.Loan(
                currencyNumber: 2,
                bankProductID: 10000000131,
                amount: 7000000.0,
                currentInterestRate: 8.14,
                principalDebt: 5798499.75,
                defaultPrincipalDebt: nil,
                totalAmountDebt: 5798499.75,
                principalDebtAccount: "45507810700001300403",
                settlementAccount: "40817810623000001135",
                settlementAccountId: 10003827714,
                dateLong: 2390590800000,
                strDateLong: "10/45"
            )
        )
    )
}
