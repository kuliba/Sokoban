@testable import ForaBank
import Foundation

extension ServerCommands.ProductController.GetProductListByType.Response.List {
    
    static let card: Self = ServerCommands.ProductController.GetProductListByType.Response.List(
        serial: "a573caa2b73271cf22d69ee59065083f",
        productList:
            [
                ProductData(
                    id: 10000184510,
                    productType: .card,
                    number: "4656260144018016",
                    numberMasked: "4656-XXXX-XXXX-8016",
                    accountNumber: "40817810952005000640",
                    balance: 280027.57,
                    balanceRub: 280027.57,
                    currency: "RUB",
                    mainField: "Gold",
                    additionalField: "Миг",
                    customName: "reg0тесттесттесттестте",
                    productName: "VISA REWARDS R-5",
                    openDate: Date.dateUTC(with: 1631048400000),
                    ownerId: 10002053887,
                    branchId: 2000,
                    allowCredit: true,
                    allowDebit: true,
                    extraLargeDesign: SVGImageData(description: "e383a49e15aeec6d9c51ee6f4897ad16"),
                    largeDesign: SVGImageData(description: "b7fd0a13ae9bb8b70b0dd92082ce91f6"),
                    mediumDesign: SVGImageData(description: "98cbe7f6396bed6004dd01e2f7c37db2"),
                    smallDesign: SVGImageData(description: "7e7beff3d0827be85b8259135643bf62"),
                    fontDesignColor: ColorData(description: "FFFFFF"),
                    background: [
                        ColorData(description: "FFBB36")
                    ],
                    order: 0,
                    isVisible: true,
                    smallDesignMd5hash: "7e7beff3d0827be85b8259135643bf62",
                    smallBackgroundDesignHash: "b0c85ac844ee9758af64ad2c066d5191"
                ),
                ProductData(
                    id: 10000184511,
                    productType: .card,
                    number: "4656260144018008",
                    numberMasked: "4656-XXXX-XXXX-8008",
                    accountNumber: "40817810552005000639",
                    balance: 37203.52,
                    balanceRub: 37203.52,
                    currency: "RUB",
                    mainField: "Gold",
                    additionalField: "Миг",
                    customName: "reg1",
                    productName: "VISA REWARDS R-5",
                    openDate: Date.dateUTC(with: 1631048400000),
                    ownerId: 10002053887,
                    branchId: 2000,
                    allowCredit: true,
                    allowDebit: true,
                    extraLargeDesign: SVGImageData(description: "e383a49e15aeec6d9c51ee6f4897ad16"),
                    largeDesign: SVGImageData(description: "b7fd0a13ae9bb8b70b0dd92082ce91f6"),
                    mediumDesign: SVGImageData(description: "98cbe7f6396bed6004dd01e2f7c37db2"),
                    smallDesign: SVGImageData(description: "7e7beff3d0827be85b8259135643bf62"),
                    fontDesignColor: ColorData(description: "FFFFFF"),
                    background: [
                        ColorData(description: "FFBB36")
                    ],
                    order: 1,
                    isVisible: true,
                    smallDesignMd5hash: "7e7beff3d0827be85b8259135643bf62",
                    smallBackgroundDesignHash: "b0c85ac844ee9758af64ad2c066d5191"
                ),
                ProductData(
                    id: 20000010937,
                    productType: .card,
                    number: "2200980208300050",
                    numberMasked: "2200-XXXX-XXXX-0050",
                    accountNumber: "40817810000005609346",
                    balance: nil,
                    balanceRub: nil,
                    currency: "RUB",
                    mainField: "МИР",
                    additionalField: "Все включено",
                    customName: nil,
                    productName: "MIR ADVANCED R-5",
                    openDate: Date.dateUTC(with: 1701205200000),
                    ownerId: 10002053887,
                    branchId: 2000,
                    allowCredit: true,
                    allowDebit: true,
                    extraLargeDesign: SVGImageData(description: "31EB1F7BAD73E34186ECA70529DE4DA2"),
                    largeDesign: SVGImageData(description: "13084B2530CE94844881BD482007337F"),
                    mediumDesign: SVGImageData(description: "7A0478525DE6AA90708D400C7937CAB2"),
                    smallDesign: SVGImageData(description: "3B061527A82B717E4BEBF80C01965839"),
                    fontDesignColor: ColorData(description: "FFFFFF"),
                    background: [
                        ColorData(description: "FFBB36")
                    ],
                    order: 2,
                    isVisible: true,
                    smallDesignMd5hash: "3B061527A82B717E4BEBF80C01965839",
                    smallBackgroundDesignHash: "5037BD0EA47B9FA070ADADCCEE4352AC"
                ),
                ProductData(
                    id: 20000010933,
                    productType: .card,
                    number: "4578251032525431",
                    numberMasked: "4578-XXXX-XXXX-5431",
                    accountNumber: "40817810700005609345",
                    balance: nil,
                    balanceRub: nil,
                    currency: "RUB",
                    mainField: "Platinum",
                    additionalField: "Все включено",
                    customName: nil,
                    productName: "VISA PLATINUM R-5",
                    openDate: Date.dateUTC(with: 1701205200000),
                    ownerId: 10002053887,
                    branchId: 2000,
                    allowCredit: true,
                    allowDebit: true,
                    extraLargeDesign: SVGImageData(description: "022c499d41ff9e90c915ce9f499358af"),
                    largeDesign: SVGImageData(description: "df9bbab71104b7f768677db7ae51c6bb"),
                    mediumDesign: SVGImageData(description: "c81056de27fa28861c72ad6e248e1103"),
                    smallDesign: SVGImageData(description: "862445934adc016602c7b997e173407f"),
                    fontDesignColor: ColorData(description: "FFFFFF"),
                    background: [
                        ColorData(description: "AAAAAA")
                    ],
                    order: 3,
                    isVisible: true,
                    smallDesignMd5hash: "862445934adc016602c7b997e173407f",
                    smallBackgroundDesignHash: "ce7768ac13f876aa043d36e8e7522dbd"
                )
            ]
    )
}
