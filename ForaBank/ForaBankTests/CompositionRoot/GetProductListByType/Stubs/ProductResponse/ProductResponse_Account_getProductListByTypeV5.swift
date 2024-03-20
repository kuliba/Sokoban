@testable import GetProductListByTypeService

public extension Array where Element == ProductResponse.Product {
    
    static let accountStubs: Self = [.accountStub1, .accountStub2, .accountStub3, .accountStub4, .accountStub5]
}

extension ProductResponse.Product {
    
    static let accountStub1: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 10003827714,
            productType: .account,
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
            mainField: "Текущий счет",
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
            smallDesignMd5Hash: "ec5a921eec37d035b2495b5b9377ff28",
            mediumDesignMd5Hash: "b5815f4c1bb9e5df4ec66391b14090b7",
            largeDesignMd5Hash: "1dbcf5c8a72a84c8266eabac8d893ce9",
            xlDesignMd5Hash: "7fba4466c7ee71554a80f2ffa24bd139",
            smallBackgroundDesignHash: "db289aa034c96e9762404cf162e47b47",
            background: [
                "6D6D6D"
            ]
        ),
        uniqueProperties: .account(
            ProductResponse.Account(
                name: "ВСФ",
                externalID: 10002053887,
                dateOpen: 1596402000000,
                status: .notBlocked,
                branchName: #"АКБ "ФОРА-БАНК" (АО)"#,
                detailedRatesUrl: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_Kotelniki_OrekhovoZuevo_Reutov_Tver_tarifi.pdf",
                detailedConditionUrl: "https://www.forabank.ru/dkbo/dkbo.pdf"
            )
        )
    )
    
    static let accountStub2: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 20000102036,
            productType: .account,
            productState: [
                .default,
                .notVisible
            ],
            order: 1,
            visibility: true,
            number: "40817810300000500072",
            numberMasked: "40817-810-X-ХXXX-0500072",
            accountNumber: "40817810300000500072",
            currency: "RUB",
            mainField: "Текущий счет",
            additionalField: nil,
            customName: nil,
            productName: "Текущие счета физ.лиц",
            balance: 0.0,
            balanceRUB: 0.0,
            openDate: 1706475600000,
            ownerId: 10002053887,
            branchId: 2000,
            allowDebit: true,
            allowCredit: false,
            fontDesignColor: "FFFFFF",
            smallDesignMd5Hash: "ec5a921eec37d035b2495b5b9377ff28",
            mediumDesignMd5Hash: "b5815f4c1bb9e5df4ec66391b14090b7",
            largeDesignMd5Hash: "1dbcf5c8a72a84c8266eabac8d893ce9",
            xlDesignMd5Hash: "7fba4466c7ee71554a80f2ffa24bd139",
            smallBackgroundDesignHash: "db289aa034c96e9762404cf162e47b47",
            background: [
                "6D6D6D"
            ]
        ),
        uniqueProperties: .account(
            ProductResponse.Account(
                name: "ВСФ",
                externalID: 10002053887,
                dateOpen: 1706475600000,
                status: .blockedCredit,
                branchName: #"АКБ "ФОРА-БАНК" (АО)"#,
                detailedRatesUrl: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_Kotelniki_OrekhovoZuevo_Reutov_Tver_tarifi.pdf",
                detailedConditionUrl: "https://www.forabank.ru/dkbo/dkbo.pdf"
            )
        )
    )
    
    static let accountStub3: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 20000102186,
            productType: .account,
            productState: [
                .default,
                .notVisible
            ],
            order: 2,
            visibility: true,
            number: "40817810252000002974",
            numberMasked: "40817-810-X-ХXXX-0002974",
            accountNumber: "40817810252000002974",
            currency: "RUB",
            mainField: "Текущий счет",
            additionalField: nil,
            customName: nil,
            productName: "Текущие счета физ.лиц",
            balance: 0.0,
            balanceRUB: 0.0,
            openDate: 1707253200000,
            ownerId: 10002053887,
            branchId: 2000,
            allowDebit: true,
            allowCredit: true,
            fontDesignColor: "FFFFFF",
            smallDesignMd5Hash: "ec5a921eec37d035b2495b5b9377ff28",
            mediumDesignMd5Hash: "b5815f4c1bb9e5df4ec66391b14090b7",
            largeDesignMd5Hash: "1dbcf5c8a72a84c8266eabac8d893ce9",
            xlDesignMd5Hash: "7fba4466c7ee71554a80f2ffa24bd139",
            smallBackgroundDesignHash: "db289aa034c96e9762404cf162e47b47",
            background: [
                "6D6D6D"
            ]
        ),
        uniqueProperties: .account(
            ProductResponse.Account(
                name: "ВСФ",
                externalID: 10002053887,
                dateOpen: 1707253200000,
                status: .notBlocked,
                branchName: #"АКБ "ФОРА-БАНК" (АО)"#,
                detailedRatesUrl: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_Kotelniki_OrekhovoZuevo_Reutov_Tver_tarifi.pdf",
                detailedConditionUrl: "https://www.forabank.ru/dkbo/dkbo.pdf"
            )
        )
    )
    
    static let accountStub4: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 20000101514,
            productType: .account,
            productState: [
                .default,
                .notVisible
            ],
            order: 3,
            visibility: true,
            number: "40817156300000000003",
            numberMasked: "40817-156-X-ХXXX-0000003",
            accountNumber: "40817156300000000003",
            currency: "CNY",
            mainField: "Текущий счет",
            additionalField: nil,
            customName: nil,
            productName: "Текущие счета физ.лиц",
            balance: 18.38,
            balanceRUB: 227.62,
            openDate: 1702501200000,
            ownerId: 10002053887,
            branchId: 2000,
            allowDebit: true,
            allowCredit: false,
            fontDesignColor: "FFFFFF",
            smallDesignMd5Hash: "584b6307307375bf820181405100e0d3",
            mediumDesignMd5Hash: "52ae2bf86d9a803125a80dc77d8ed892",
            largeDesignMd5Hash: "7db2b18c9d5df0d3dcb99bdc64565b9f",
            xlDesignMd5Hash: "fb41c5f33149c7dedaa53494fdbab748",
            smallBackgroundDesignHash: "db289aa034c96e9762404cf162e47b47",
            background: [
                "6D6D6D"
            ]
        ),
        uniqueProperties: .account(
            ProductResponse.Account(
                name: "ВСФ",
                externalID: 10002053887,
                dateOpen: 1702501200000,
                status: .blockedCredit,
                branchName: #"АКБ "ФОРА-БАНК" (АО)"#,
                detailedRatesUrl: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_Kotelniki_OrekhovoZuevo_Reutov_Tver_tarifi.pdf",
                detailedConditionUrl: "https://www.forabank.ru/dkbo/dkbo.pdf"
            )
        )
    )
    
    static let accountStub5: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 20000101441,
            productType: .account,
            productState: [
                .default,
                .notVisible
            ],
            order: 4,
            visibility: true,
            number: "40817051852000000012",
            numberMasked: "40817-051-X-ХXXX-0000012",
            accountNumber: "40817051852000000012",
            currency: "AMD",
            mainField: "Текущий счет",
            additionalField: nil,
            customName: nil,
            productName: "Текущие счета физ.лиц",
            balance: 0.01,
            balanceRUB: 0.0,
            openDate: 1701291600000,
            ownerId: 10002053887,
            branchId: 2000,
            allowDebit: true,
            allowCredit: false,
            fontDesignColor: "FFFFFF",
            smallDesignMd5Hash: "0383c56d99c0c4fca9c2fa9b7c7eb5b4",
            mediumDesignMd5Hash: "0c071e5d3489f7c02d1f699fd6e79520",
            largeDesignMd5Hash: "40fb23c57740512faf3154e63dc1a77a",
            xlDesignMd5Hash: "8d77efbed5f9594e5102232eba46931e",
            smallBackgroundDesignHash: "db289aa034c96e9762404cf162e47b47",
            background: [
                "6D6D6D"
            ]
        ),
        uniqueProperties: .account(
            ProductResponse.Account(
                name: "ВСФ",
                externalID: 10002053887,
                dateOpen: 1701291600000,
                status: .blockedCredit,
                branchName: #"АКБ "ФОРА-БАНК" (АО)"#,
                detailedRatesUrl: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_Kotelniki_OrekhovoZuevo_Reutov_Tver_tarifi.pdf",
                detailedConditionUrl: "https://www.forabank.ru/dkbo/dkbo.pdf"
            )
        )
    )
}
