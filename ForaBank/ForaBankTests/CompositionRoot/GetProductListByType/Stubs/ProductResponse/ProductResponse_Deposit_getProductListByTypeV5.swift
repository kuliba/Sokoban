@testable import GetProductListByTypeService

public extension Array where Element == ProductResponse.Product {
    
    static let depositStubs: Self = [.depositStub1, .depositStub2, .depositStub3, .depositStub4]
}

extension ProductResponse.Product {
    
    static let depositStub1: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 20000058973,
            productType: .deposit,
            productState: [
                .default,
                .notVisible
            ],
            order: 0,
            visibility: true,
            number: "00081_224RUB0000/24",
            numberMasked: "00081_224RUB0000/24",
            accountNumber: "42303810900005605046",
            currency: "RUB",
            mainField: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
            additionalField: nil,
            customName: nil,
            productName: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
            balance: 5000.0,
            balanceRUB: 5000.0,
            openDate: 1706475600000,
            ownerId: 10002053887,
            branchId: 2000,
            allowDebit: false,
            allowCredit: false,
            fontDesignColor: "3D3D45",
            smallDesignMd5Hash: "9cd404ac011454ad95146de6560dd794",
            mediumDesignMd5Hash: "121b73bb50858e76e33b176686d8e940",
            largeDesignMd5Hash: "2a3bf21fe2b8e28f3944ab0968f6759d",
            xlDesignMd5Hash: "bf552f2c1d4d174decf46b7acd115068",
            smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6",
            background: [
                "FF3636"
            ]
        ),
        uniqueProperties: .deposit(
            ProductResponse.Deposit(
                depositProductID: 10000003006,
                depositID: 20000058973,
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
    )
    
    static let depositStub2: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 20000058906,
            productType: .deposit,
            productState: [
                .default,
                .notVisible
            ],
            order: 1,
            visibility: true,
            number: "00054_224RUB0000/24",
            numberMasked: "00054_224RUB0000/24",
            accountNumber: "42303810700005605039",
            currency: "RUB",
            mainField: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
            additionalField: nil,
            customName: nil,
            productName: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
            balance: 5000.0,
            balanceRUB: 5000.0,
            openDate: 1706043600000,
            ownerId: 10002053887,
            branchId: 2000,
            allowDebit: false,
            allowCredit: false,
            fontDesignColor: "3D3D45",
            smallDesignMd5Hash: "9cd404ac011454ad95146de6560dd794",
            mediumDesignMd5Hash: "121b73bb50858e76e33b176686d8e940",
            largeDesignMd5Hash: "2a3bf21fe2b8e28f3944ab0968f6759d",
            xlDesignMd5Hash: "bf552f2c1d4d174decf46b7acd115068",
            smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6",
            background: [
                "FF3636"
            ]
        ),
        uniqueProperties: .deposit(
            ProductResponse.Deposit(
                depositProductID: 10000003006,
                depositID: 20000058906,
                interestRate: 7.1,
                accountID: 20000101933,
                creditMinimumAmount: 2000.0,
                minimumBalance: 5000.0,
                endDate: 1708722000000,
                endDateNF: false,
                demandDeposit: false,
                isDebitInterestAvailable: false
            )
        )
    )
    
    static let depositStub3: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 20000058836,
            productType: .deposit,
            productState: [
                .default,
                .notVisible
            ],
            order: 2,
            visibility: true,
            number: "00008_305RUB5200/24",
            numberMasked: "00008_305RUB5200/24",
            accountNumber: "42304810652000000605",
            currency: "RUB",
            mainField: "ФОРА ХИТ",
            additionalField: nil,
            customName: nil,
            productName: "ФОРА ХИТ",
            balance: 10001.0,
            balanceRUB: 10001.0,
            openDate: 1705525200000,
            ownerId: 10002053887,
            branchId: 10000260261,
            allowDebit: true,
            allowCredit: true,
            fontDesignColor: "3D3D45",
            smallDesignMd5Hash: "9cd404ac011454ad95146de6560dd794",
            mediumDesignMd5Hash: "121b73bb50858e76e33b176686d8e940",
            largeDesignMd5Hash: "2a3bf21fe2b8e28f3944ab0968f6759d",
            xlDesignMd5Hash: "bf552f2c1d4d174decf46b7acd115068",
            smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6",
            background: [
                "FF3636"
            ]
        ),
        uniqueProperties: .deposit(
            ProductResponse.Deposit(
                depositProductID: 10000003792,
                depositID: 20000058836,
                interestRate: 12.2,
                accountID: 20000101822,
                creditMinimumAmount: 5000.0,
                minimumBalance: 10000.0,
                endDate: 1715893200000,
                endDateNF: false,
                demandDeposit: false,
                isDebitInterestAvailable: true
            )
        )
    )
    
    static let depositStub4: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 20000058832,
            productType: .deposit,
            productState: [
                .default,
                .notVisible
            ],
            order: 3,
            visibility: true,
            number: "00032_224RUB5200/24",
            numberMasked: "00032_224RUB5200/24",
            accountNumber: "42301810452000001467",
            currency: "RUB",
            mainField: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
            additionalField: nil,
            customName: nil,
            productName: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
            balance: 5030.09,
            balanceRUB: 5030.09,
            openDate: 1705525200000,
            ownerId: 10002053887,
            branchId: 10000260261,
            allowDebit: false,
            allowCredit: false,
            fontDesignColor: "3D3D45",
            smallDesignMd5Hash: "9cd404ac011454ad95146de6560dd794",
            mediumDesignMd5Hash: "121b73bb50858e76e33b176686d8e940",
            largeDesignMd5Hash: "2a3bf21fe2b8e28f3944ab0968f6759d",
            xlDesignMd5Hash: "bf552f2c1d4d174decf46b7acd115068",
            smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6",
            background: [
                "FF3636"
            ]
        ),
        uniqueProperties: .deposit(
            ProductResponse.Deposit(
                depositProductID: 10000003006,
                depositID: 20000058832,
                interestRate: 0.01,
                accountID: 20000102599,
                creditMinimumAmount: 2000.0,
                minimumBalance: 5000.0,
                endDate: nil,
                endDateNF: true,
                demandDeposit: false,
                isDebitInterestAvailable: false
            )
        )
    )
    
    static let depositStub5: Self = .init(
        commonProperties: ProductResponse.CommonProperties(
            id: 20000058830,
            productType: .deposit,
            productState: [
                .default,
                .notVisible
            ],
            order: 4,
            visibility: true,
            number: "00030_224RUB0000/24",
            numberMasked: "00030_224RUB0000/24",
            accountNumber: "42303810800005605036",
            currency: "RUB",
            mainField: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
            additionalField: nil,
            customName: nil,
            productName: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
            balance: 5000.0,
            balanceRUB: 5000.0,
            openDate: 1705438800000,
            ownerId: 10002053887,
            branchId: 2000,
            allowDebit: false,
            allowCredit: false,
            fontDesignColor: "3D3D45",
            smallDesignMd5Hash: "9cd404ac011454ad95146de6560dd794",
            mediumDesignMd5Hash: "121b73bb50858e76e33b176686d8e940",
            largeDesignMd5Hash: "2a3bf21fe2b8e28f3944ab0968f6759d",
            xlDesignMd5Hash: "bf552f2c1d4d174decf46b7acd115068",
            smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6",
            background: [
                "FF3636"
            ]
        ),
        uniqueProperties: .deposit(
            ProductResponse.Deposit(
                depositProductID: 10000003006,
                depositID: 20000058830,
                interestRate: 7.1,
                accountID: 20000101813,
                creditMinimumAmount: 2000.0,
                minimumBalance: 5000.0,
                endDate: 1708117200000,
                endDateNF: false,
                demandDeposit: false,
                isDebitInterestAvailable: false
            )
        )
    )
    
}
