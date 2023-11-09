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
        cardAction: { _ in },
        showCvv: nil
    )
    
    static let blocked = blockedCard(id: 1, .whiteSample())
    static let blockedSmall = blockedCard(id: 11, .whiteSample(.small))
    
    private static func blockedCard(
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
            cardAction: { _ in },
            showCvv: nil
        )
    }
    
    static let classic = classicCard(id: 2, .whiteOnRed())
    static let classicSmall = classicCard(id: 12, .whiteOnRed(.small))
    
    private static func classicCard(
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
            cardAction: { _ in },
            showCvv: nil
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
        cardAction: { _ in },
        showCvv: nil
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
        cardAction: { _ in },
        showCvv: nil
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
        cardAction: { _ in },
        showCvv: nil
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
        cardAction: { _ in },
        showCvv: nil
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
        cardAction: { _ in },
        showCvv: nil
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
        cardAction: { _ in },
        showCvv: nil
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
            textColor: .mainColorsBlackMedium,
            background: .init(color: .cardRio, image: Image( "Cover Deposit"))),
        isUpdating: false,
        productType: .deposit,
        cardAction: { _ in },
        showCvv: nil
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
        cardAction: { _ in },
        showCvv: nil
    )
}

private extension Image {
    
    static let visa: Self = .init("Payment System Visa")
    static let mastercard: Self = .init("Payment System Mastercard")
}

private extension ProductView.ViewModel.HeaderViewModel {
    
    static func make(period: String? = "12/24") -> Self {
        .init(logo: .ic24LogoForaColor, number: "7854", period: period)
    }
}

private extension ProductView.ViewModel.FooterViewModel {
    
    static let visa = ProductView.ViewModel.FooterViewModel(balance: "170 897 ₽", paymentSystem: .visa)
    static let mastercard = ProductView.ViewModel.FooterViewModel(balance: "170 897 ₽", paymentSystem: .mastercard)
}

private extension ProductView.ViewModel.Appearance {
    
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

private extension ProductView.ViewModel.Appearance.Background {
    
    static let red: Self =          .init(color: .mainColorsRed, image: nil)
    static let cardRIO: Self =      .init(color: .cardRio,       image: nil)
    static let cardInfinite: Self = .init(color: .cardInfinite,  image: nil)
    
    static let infiniteSample: Self = .init(
        color: .cardInfinite,
        image: Image("Product Background Sample")
    )
    
    static let infiniteLarge: Self = .init(
        color: .cardInfinite,
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
