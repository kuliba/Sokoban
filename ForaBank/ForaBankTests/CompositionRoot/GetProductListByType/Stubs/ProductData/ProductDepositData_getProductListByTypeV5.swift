@testable import ForaBank
import Foundation

public extension Array where Element == ProductData {
    
    static let depositStubs: Self = [.depositStub1, .depositStub2, .depositStub3, .depositStub4, .depositStub5]
}

extension ProductData {
    
    static let depositStub1 = ProductData(
        id: 20000058973,
        productType: .deposit,
        number: "00081_224RUB0000/24",
        numberMasked: "00081_224RUB0000/24",
        accountNumber: "42303810900005605046",
        balance: 5000.0,
        balanceRub: 5000.0,
        currency: "RUB",
        mainField: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
        additionalField: nil,
        customName: nil,
        productName: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
        openDate: Date.dateUTC(with: 1706475600000),
        ownerId: 10002053887,
        branchId: 2000,
        allowCredit: false,
        allowDebit: false,
        extraLargeDesign: SVGImageData(description: "bf552f2c1d4d174decf46b7acd115068"),
        largeDesign: SVGImageData(description: "2a3bf21fe2b8e28f3944ab0968f6759d"),
        mediumDesign: SVGImageData(description: "121b73bb50858e76e33b176686d8e940"),
        smallDesign: SVGImageData(description: "9cd404ac011454ad95146de6560dd794"),
        fontDesignColor: ColorData(description: "3D3D45"),
        background: [
            ColorData(description: "FF3636")
        ],
        order: 0,
        isVisible: true,
        smallDesignMd5hash: "9cd404ac011454ad95146de6560dd794",
        smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6"
    )
    
    static let depositStub2 = ProductData(
        id: 20000058906,
        productType: .deposit,
        number: "00054_224RUB0000/24",
        numberMasked: "00054_224RUB0000/24",
        accountNumber: "42303810700005605039",
        balance: 5000.0,
        balanceRub: 5000.0,
        currency: "RUB",
        mainField: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
        additionalField: nil,
        customName: nil,
        productName: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
        openDate: Date.dateUTC(with: 1706043600000),
        ownerId: 10002053887,
        branchId: 2000,
        allowCredit: false,
        allowDebit: false,
        extraLargeDesign: SVGImageData(description: "bf552f2c1d4d174decf46b7acd115068"),
        largeDesign: SVGImageData(description: "2a3bf21fe2b8e28f3944ab0968f6759d"),
        mediumDesign: SVGImageData(description: "121b73bb50858e76e33b176686d8e940"),
        smallDesign: SVGImageData(description: "9cd404ac011454ad95146de6560dd794"),
        fontDesignColor: ColorData(description: "3D3D45"),
        background: [
            ColorData(description: "FF3636")
        ],
        order: 1,
        isVisible: true,
        smallDesignMd5hash: "9cd404ac011454ad95146de6560dd794",
        smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6"
    )
    
    static let depositStub3 = ProductData(
        id: 20000058836,
        productType: .deposit,
        number: "00008_305RUB5200/24",
        numberMasked: "00008_305RUB5200/24",
        accountNumber: "42304810652000000605",
        balance: 10001.0,
        balanceRub: 10001.0,
        currency: "RUB",
        mainField: "ФОРА ХИТ",
        additionalField: nil,
        customName: nil,
        productName: "ФОРА ХИТ",
        openDate: Date.dateUTC(with: 1705525200000),
        ownerId: 10002053887,
        branchId: 10000260261,
        allowCredit: true,
        allowDebit: true,
        extraLargeDesign: SVGImageData(description: "bf552f2c1d4d174decf46b7acd115068"),
        largeDesign: SVGImageData(description: "2a3bf21fe2b8e28f3944ab0968f6759d"),
        mediumDesign: SVGImageData(description: "121b73bb50858e76e33b176686d8e940"),
        smallDesign: SVGImageData(description: "9cd404ac011454ad95146de6560dd794"),
        fontDesignColor: ColorData(description: "3D3D45"),
        background: [
            ColorData(description: "FF3636")
        ],
        order: 2,
        isVisible: true,
        smallDesignMd5hash: "9cd404ac011454ad95146de6560dd794",
        smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6"
    )
    
    static let depositStub4 = ProductData(
        id: 20000058832,
        productType: .deposit,
        number: "00032_224RUB5200/24",
        numberMasked: "00032_224RUB5200/24",
        accountNumber: "42301810452000001467",
        balance: 5030.09,
        balanceRub: 5030.09,
        currency: "RUB",
        mainField: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
        additionalField: nil,
        customName: nil,
        productName: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
        openDate: Date.dateUTC(with: 1705525200000),
        ownerId: 10002053887,
        branchId: 10000260261,
        allowCredit: false,
        allowDebit: false,
        extraLargeDesign: SVGImageData(description: "bf552f2c1d4d174decf46b7acd115068"),
        largeDesign: SVGImageData(description: "2a3bf21fe2b8e28f3944ab0968f6759d"),
        mediumDesign: SVGImageData(description: "121b73bb50858e76e33b176686d8e940"),
        smallDesign: SVGImageData(description: "9cd404ac011454ad95146de6560dd794"),
        fontDesignColor: ColorData(description: "3D3D45"),
        background: [
            ColorData(description: "FF3636")
        ],
        order: 3,
        isVisible: true,
        smallDesignMd5hash: "9cd404ac011454ad95146de6560dd794",
        smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6"
    )
    
    static let depositStub5 = ProductData(
        id: 20000058830,
        productType: .deposit,
        number: "00030_224RUB0000/24",
        numberMasked: "00030_224RUB0000/24",
        accountNumber: "42303810800005605036",
        balance: 5000.0,
        balanceRub: 5000.0,
        currency: "RUB",
        mainField: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
        additionalField: nil,
        customName: nil,
        productName: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
        openDate: Date.dateUTC(with: 1705438800000),
        ownerId: 10002053887,
        branchId: 2000,
        allowCredit: false,
        allowDebit: false,
        extraLargeDesign: SVGImageData(description: "bf552f2c1d4d174decf46b7acd115068"),
        largeDesign: SVGImageData(description: "2a3bf21fe2b8e28f3944ab0968f6759d"),
        mediumDesign: SVGImageData(description: "121b73bb50858e76e33b176686d8e940"),
        smallDesign: SVGImageData(description: "9cd404ac011454ad95146de6560dd794"),
        fontDesignColor: ColorData(description: "3D3D45"),
        background: [
            ColorData(description: "FF3636")
        ],
        order: 4,
        isVisible: true,
        smallDesignMd5hash: "9cd404ac011454ad95146de6560dd794",
        smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6"
    )
}
