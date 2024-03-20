@testable import ForaBank
import Foundation

public extension Array where Element == ProductData {
    
    static let loanStubs: Self = [.loanStub1, .loanStub2, .loanStub3]
}

extension ProductData {
    
    static let loanStub1 = ProductData(
        id: 20000002425,
        productType: .loan,
        number: nil,
        numberMasked: nil,
        accountNumber: nil,
        balance: nil,
        balanceRub: nil,
        currency: "RUB",
        mainField: "Сотрудник",
        additionalField: nil,
        customName: nil,
        productName: "Ф_ПотКред",
        openDate: nil,
        ownerId: 10002053887,
        branchId: nil,
        allowCredit: false,
        allowDebit: false,
        extraLargeDesign: SVGImageData(description: "6a68356ece01dec7819ced110e136ecf"),
        largeDesign: SVGImageData(description: "a782dc8aac4f1442cb1a8e605b21f337"),
        mediumDesign: SVGImageData(description: "222b894a9b71b974392b7ee22ae26571"),
        smallDesign: SVGImageData(description: "adb37ee92357dd56154bff6b64d0db38"),
        fontDesignColor: ColorData(description: "FFFFFF"),
        background: [
            ColorData(description: "80CBC3")
        ],
        order: 0,
        isVisible: true,
        smallDesignMd5hash: "adb37ee92357dd56154bff6b64d0db38",
        smallBackgroundDesignHash: "4e303667d389d73fbe6c7bbf647bbc83"
    )
    
    static let loanStub2 = ProductData(
        id: 10002699472,
        productType: .loan,
        number: nil,
        numberMasked: nil,
        accountNumber: nil,
        balance: nil,
        balanceRub: nil,
        currency: "RUB",
        mainField: "Премиум",
        additionalField: nil,
        customName: nil,
        productName: "Ф_ПотКред",
        openDate: nil,
        ownerId: 10002053887,
        branchId: nil,
        allowCredit: false,
        allowDebit: false,
        extraLargeDesign: SVGImageData(description: "6a68356ece01dec7819ced110e136ecf"),
        largeDesign: SVGImageData(description: "a782dc8aac4f1442cb1a8e605b21f337"),
        mediumDesign: SVGImageData(description: "222b894a9b71b974392b7ee22ae26571"),
        smallDesign: SVGImageData(description: "adb37ee92357dd56154bff6b64d0db38"),
        fontDesignColor: ColorData(description: "FFFFFF"),
        background: [
            ColorData(description: "80CBC3")
        ],
        order: 1,
        isVisible: true,
        smallDesignMd5hash: "adb37ee92357dd56154bff6b64d0db38",
        smallBackgroundDesignHash: "4e303667d389d73fbe6c7bbf647bbc83"
    )
    
    static let loanStub3 = ProductData(
        id: 10002156052,
        productType: .loan,
        number: nil,
        numberMasked: nil,
        accountNumber: nil,
        balance: nil,
        balanceRub: nil,
        currency: "RUB",
        mainField: "Ипотечный",
        additionalField: "Ипотечный кредит",
        customName: nil,
        productName: "Ф_ИпКред",
        openDate: nil,
        ownerId: 10002053887,
        branchId: nil,
        allowCredit: false,
        allowDebit: false,
        extraLargeDesign: SVGImageData(description: "8c77f670a3381f28f6b7483468514b54"),
        largeDesign: SVGImageData(description: "01cf528baad8c71edc4db7535fe6bdc4"),
        mediumDesign: SVGImageData(description: "dc3c8f68537620342d2bd4916f9e6a4e"),
        smallDesign: SVGImageData(description: "1deea13bf04c558bd34229fed46846a2"),
        fontDesignColor: ColorData(description: "FFFFFF"),
        background: [
            ColorData(description: "FF9636")
        ],
        order: 2,
        isVisible: true,
        smallDesignMd5hash: "1deea13bf04c558bd34229fed46846a2",
        smallBackgroundDesignHash: "75b3d3cc00c325e970874da5cae8bc86"
    )
}
