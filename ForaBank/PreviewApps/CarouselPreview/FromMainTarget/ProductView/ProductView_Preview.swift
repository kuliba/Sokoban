//
//  ProductViewComponentPreviewContent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.07.2023.
//

import SwiftUI

//MARK: - Preview Content

extension ProductView.ViewModel {
    
    static let notActivate = ProductView.ViewModel(
        id: 0,
        header: .make(period: nil),
        cardInfo: .classicCard,
        footer: .visa,
        statusAction: .init(status: .activation(.init(state: .notActivated))),
        appearance: .whiteSample(),
        isUpdating: false,
        productType: .card,
        cardAction: { _ in }
    )
    
    static let blocked = blockedCard(id: 1, .whiteSample())
    static let blockedSmall = blockedCard(id: 11, .whiteSample(.small))
    
    static func blockedCard(
        id: ProductData.ID,
        _ appearance: Appearance
    ) -> ProductView.ViewModel {
        
        .init(
            id: id,
            header: .make(period: nil),
            cardInfo: .classicCard,
            footer: .mastercard,
            statusAction: .init(status: .unblock),
            appearance: appearance,
            isUpdating: false,
            productType: .card,
            cardAction: { _ in }
        )
    }
    
    static let classic = classicCard(id: 2, .whiteOnRed())
    static let classicSmall = classicCard(id: 12, .whiteOnRed(.small))
    
    static func classicCard(
        id: ProductData.ID,
        _ appearance: Appearance
    ) -> ProductView.ViewModel {
        
        .init(
            id: id,
            header: .make(period: nil),
            cardInfo: .classicCard,
            footer: .mastercard,
            statusAction: nil,
            appearance: appearance,
            isUpdating: false,
            productType: .card,
            cardAction: { _ in }
        )
    }
    
    static let account = ProductView.ViewModel(
        id: 3,
        header: .make(period: nil),
        cardInfo: .salaryAccount,
        footer: .mastercard,
        statusAction: nil,
        appearance: .whiteRIO(),
        isUpdating: false,
        productType: .card,
        cardAction: { _ in }
    )
    
    static let accountSmall = ProductView.ViewModel(
        id: 13,
        header: .make(period: nil),
        cardInfo: .salaryAccount,
        footer: .mastercard,
        statusAction: nil,
        isChecked: true,
        appearance: .whiteRIO(.small),
        isUpdating: false,
        productType: .account,
        cardAction: { _ in }
    )
    
    static let notActivateProfile = ProductView.ViewModel(
        id: 4, header: .make(),
        cardInfo: .classicCard,
        footer: .visa,
        statusAction: .init(status: .activation(.init(state: .notActivated))),
        appearance: .init(
            textColor: .white,
            background: .infiniteLarge,
            style: .profile
        ),
        isUpdating: false,
        productType: .deposit,
        cardAction: { _ in }
    )
    
    static let blockedProfile = ProductView.ViewModel(
        id: 5,
        header: .make(),
        cardInfo: .classicCard,
        footer: .mastercard,
        statusAction: .init(status: .unblock),
        appearance: .init(
            textColor: .white,
            background: .cardInfinite,
            style: .profile),
        isUpdating: false,
        productType: .card,
        cardAction: { _ in }
    )
    static let classicProfile = ProductView.ViewModel(
        id: 6,
        header: .make(),
        cardInfo: .init(
            name: "Classic\nФОРА-Премиум",
            owner: "Иванов",
            cvvTitle: .cvvTitle,
            cardWiggle: false,
            fullNumber: .number,
            numberMasked: .maskedNumber
        ),
        footer: .mastercard,
        statusAction: nil,
        appearance: .whiteRIO(),
        isUpdating: false,
        productType: .card,
        cardAction: { _ in }
    )
    
    static let accountProfile = ProductView.ViewModel(
        id: 7,
        header: .make(),
        cardInfo: .salaryAccount,
        footer: .mastercard,
        statusAction: nil,
        appearance: .whiteRIO(),
        isUpdating: false,
        productType: .account,
        cardAction: { _ in }
    )
    
    static let depositProfile = ProductView.ViewModel(
        id: 8,
        header: .make(),
        cardInfo: .init(
            name: "Стандарный вклад",
            owner: "Иванов",
            cvvTitle: .emptyTitle,
            cardWiggle: false,
            fullNumber: .emptyNumber,
            numberMasked: .emptyMaskedNumber
        ),
        footer: .mastercard,
        statusAction: nil,
        appearance: .init(
            textColor: Color("mainColorsBlackMedium"),
            background: .init(color: Color("cardRio"),
                              image: Image("Cover Deposit"))),
        isUpdating: false,
        productType: .deposit,
        cardAction: { _ in }
    )
    
    static let updating = ProductView.ViewModel(
        id: 9,
        header: .make(period: nil),
        cardInfo: .init(
            name: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
            owner: "Иванов",
            cvvTitle: .cvvTitle,
            cardWiggle: false,
            fullNumber: .number,
            numberMasked: .maskedNumber
        ),
        footer: .visa,
        statusAction: nil,
        appearance: .whiteSample(),
        isUpdating: true,
        productType: .card,
        cardAction: { _ in }
    )
    
    static let additionalMain = ProductView.ViewModel(
        id: 9,
        header: .make(period: nil),
        cardInfo: .init(
            name: "Основная",
            owner: "Иванов",
            cvvTitle: .cvvTitle,
            cardWiggle: false,
            fullNumber: .number,
            numberMasked: .maskedNumber
        ),
        footer: .visa,
        statusAction: nil,
        appearance: .whiteSample(),
        isUpdating: false,
        productType: .card,
        cardAction: { _ in }
    )
    
    static let additionalRegular = ProductView.ViewModel(
        id: 9,
        header: .make(period: nil),
        cardInfo: .init(
            name: "Regular",
            owner: "Иванов",
            cvvTitle: .cvvTitle,
            cardWiggle: false,
            fullNumber: .number,
            numberMasked: .maskedNumber
        ),
        footer: .visa,
        statusAction: nil,
        appearance: .whiteSample(),
        isUpdating: false,
        productType: .card,
        cardAction: { _ in }
    )
    
    static let additionalCard = ProductView.ViewModel(
        id: 10,
        header: .make(period: nil),
        cardInfo: .init(
            name: "Дополнительная",
            owner: "Иванов",
            cvvTitle: .cvvTitle,
            cardWiggle: false,
            fullNumber: .number,
            numberMasked: .maskedNumber
        ),
        footer: .visa,
        statusAction: nil,
        appearance: .whiteRIO(),
        isUpdating: false,
        productType: .card,
        cardAction: { _ in }
    )
    
    static let stickerCard = ProductView.ViewModel(
        id: 10,
        header: .make(period: nil),
        cardInfo: .init(
            name: "Дополнительная",
            owner: "Иванов",
            cvvTitle: .cvvTitle,
            cardWiggle: false,
            fullNumber: .number,
            numberMasked: .maskedNumber
        ),
        footer: .visa,
        statusAction: nil,
        appearance: .whiteRIO(),
        isUpdating: false,
        productType: .card,
        cardAction: { _ in }
    )
}

extension Image {
    
    static let visa: Self = .init("Payment System Visa")
    static let mastercard: Self = .init("Payment System Mastercard")
}

extension ProductView.ViewModel.HeaderViewModel {
    
    static func make(period: String? = "12/24") -> Self {
        .init(logo: Image("ic24LogoForaColor"), number: "7854", period: period)
    }
}

extension ProductView.ViewModel.FooterViewModel {
    
    static let visa = ProductView.ViewModel.FooterViewModel(balance: "170 897 ₽", paymentSystem: .visa)
    static let mastercard = ProductView.ViewModel.FooterViewModel(balance: "170 897 ₽", paymentSystem: .mastercard)
}

extension ProductView.ViewModel.Appearance {
    
    static func whiteSample(_ size: Size = .normal) -> Self {
        
        .make(
            textColor: .white,
            background: .infiniteSample,
            size: size
        )
    }
    
    static func whiteOnRed(_ size: Size = .normal) -> Self {
        
        .make(
            textColor: .white,
            background: .red,
            size: size
        )
    }
    
    static func whiteRIO(_ size: Size = .normal) -> Self {
        
        .make(
            textColor: .white,
            background: .cardRIO,
            size: size
        )
    }
    
    static func make(
        textColor: Color = .white,
        background: Background = .cardInfinite,
        opacity: Double = 0.5,
        size: Size,
        style: Style = .main
    ) -> Self {
        
        .init(
            textColor: textColor,
            background: background,
            opacity: opacity,
            size: size,
            style: style
        )
    }
}

extension ProductView.ViewModel.Appearance.Background {
    
    static let red: Self =          .init(color: Color("mainColorsRed"), image: nil)
    static let cardRIO: Self =      .init(color: Color("cardRio"),       image: nil)
    static let cardInfinite: Self = .init(color: Color("cardInfinite"),  image: nil)
    
    static let infiniteSample: Self = .init(
        color: Color("cardInfinite"),
        image: Image("Product Background Sample")
    )
    
    static let infiniteLarge: Self = .init(
        color: Color("cardInfinite"),
        image: Image("Product Background Large Sample")
    )
}

extension ProductView.ViewModel.CardInfo {
    
    static let classicCard: Self = .init(
        name: "Classic",
        owner: "Иванов",
        cvvTitle: .cvvTitle,
        cardWiggle: false,
        fullNumber: .number,
        numberMasked: .maskedNumber
    )
    
    static let salaryAccount: Self = .init(
        name: "Текущий зарплатный счет",
        owner: "Иванов",
        cvvTitle: .emptyTitle,
        cardWiggle: false,
        fullNumber: .emptyNumber,
        numberMasked: .emptyMaskedNumber
    )
}

extension String {
    
    static let cvvTitle = "CVV"
}

extension ProductView.ViewModel.CardInfo.CVVTitle {
    
    static let cvvTitle: Self = .init(value: "CVV")
    static let emptyTitle: Self = .init(value: "")
}

extension ProductView.ViewModel.CardInfo.FullNumber {
    
    static let number: Self = .init(value: "4444 4444 4444 4444")
    static let emptyNumber: Self = .init(value: "")
}

extension ProductView.ViewModel.CardInfo.MaskedNumber {
    
    static let maskedNumber: Self = .init(value: "4444 **** **** **44")
    static let emptyMaskedNumber: Self = .init(value: "")
}

//MARK: - Preview

struct ProductView_Previews: PreviewProvider {
    
    static func previewsGroup() -> some View {
        
        Group {
            
            Group {
                
                ProductView(viewModel: .updating)
                    .previewDisplayName("updating")
                ProductView(viewModel: .notActivate)
                    .previewDisplayName("notActivate")
                ProductView(viewModel: .blocked)
                    .previewDisplayName("blocked")
                ProductView(viewModel: .classic)
                    .previewDisplayName("classic")
                ProductView(viewModel: .account)
                    .previewDisplayName("account")
            }
            .frame(width: 164, height: 104)
            
            ProductView(viewModel: .notActivateProfile)
                .previewDisplayName("notActivateProfile")
                .frame(width: 268, height: 160)
            
            ProductView(viewModel: .blockedProfile)
                .previewDisplayName("blockedProfile")
                .frame(width: 268, height: 160)
                .frame(width: 375, height: 200)
            
            Group {
                
                ProductView(viewModel: .classicProfile)
                    .previewDisplayName("classicProfile")
                ProductView(viewModel: .accountProfile)
                    .previewDisplayName("accountProfile")
            }
            .frame(width: 268, height: 160)
            
            ProductView(viewModel: .depositProfile)
                .previewDisplayName("depositProfile")
                .frame(width: 228, height: 160)
            
            Group {
                
                ProductView(viewModel: .classicSmall)
                    .previewDisplayName("classicSmall")
                ProductView(viewModel: .accountSmall)
                    .previewDisplayName("accountSmall")
            }
            .frame(width: 112, height: 72)
        }
        .previewLayout(.sizeThatFits)
    }
    
    static var previews: some View {
        
        ScrollView {
            VStack(content: previewsGroup)
                .previewDisplayName("For Xcode 14 and later")
                .previewLayout(.sizeThatFits)
        }
    }
}

extension Array where Element == (String, String) {
    
    static let replacements = [
        ("X", "*"),
        ("-", " ")
    ]
}


