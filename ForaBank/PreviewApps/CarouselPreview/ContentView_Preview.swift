//
//  ContentView_Preview.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 22.03.2024.
//

import CarouselComponent
import SwiftUI

extension Product {
    
    static let card: Self = .init(id: 1, order: 0, type: .card, cardType: .main)
    static let cardAdditionalOther: Self = .init(id: 2, order: 1, type: .card, cardType: .additionalOther)
    static let cardAdditionalSelf: Self = .init(id: 3, order: 2, type: .card, cardType: .additionalSelf)
    static let cardAdditionalSelfAccOwn: Self = .init(id: 4, order: 3, type: .card, cardType: .additionalSelfAccOwn)
    static let cardRegular: Self = .init(id: 5, order: 4, type: .card, cardType: .regular)
    
    static let account1: Self = .init(id: 6, order: 0, type: .account, cardType: .none)
    static let account2: Self = .init(id: 16, order: 0, type: .account, cardType: .none)
    static let account3: Self = .init(id: 26, order: 0, type: .account, cardType: .none)
    
    static let deposit1: Self = .init(id: 7, order: 0, type: .deposit, cardType: .none)
    static let deposit2: Self = .init(id: 17, order: 0, type: .deposit, cardType: .none)
    static let deposit3: Self = .init(id: 27, order: 0, type: .deposit, cardType: .none)
    
    static let loan1: Self = .init(id: 8, order: 0, type: .loan, cardType: .none)
    static let loan2: Self = .init(id: 9, order: 0, type: .loan, cardType: .none)
    static let loan3: Self = .init(id: 10, order: 0, type: .loan, cardType: .none)
    
    static let sticker: Self = .init(id: 28, order: 0, type: .card, cardType: .sticker)
}

extension ProductData {
    
    static let card1: Self = .init(id: 1, productType: .card, number: "1111", balance: "111.11 rub", productName: "Card 1")
    static let card2: Self = .init(id: 2, productType: .card, number: "2222", balance: "222.11 rub", productName: "Card 2")
    static let card3: Self = .init(id: 3, productType: .card, number: "3333", balance: "333.33 rub", productName: "Card 3")
    static let card4: Self = .init(id: 4, productType: .card, number: "4444", balance: "444.44 rub", productName: "Card 4")
    static let card5: Self = .init(id: 5, productType: .card, number: "5555", balance: "555.55 rub", productName: "Card 5")
    
    static let account1: Self = .init(id: 6, productType: .account, number: "6661", balance: "23.11 rub", productName: "Account 1")
    static let account2: Self = .init(id: 16, productType: .account, number: "6662", balance: "56.11 rub", productName: "Account 2")
    static let account3: Self = .init(id: 26, productType: .account, number: "6663", balance: "78.11 rub", productName: "Account 3")
    
    static let deposit1: Self = .init(id: 7, productType: .deposit, number: "7771", balance: "89.77 rub", productName: "Deposit 1")
    static let deposit2: Self = .init(id: 17, productType: .deposit, number: "7772", balance: "78.77 rub", productName: "Deposit 2")
    static let deposit3: Self = .init(id: 27, productType: .deposit, number: "7773", balance: "56.77 rub", productName: "Deposit 3")
    
    static let loan1: Self = .init(id: 8, productType: .loan, number: "8888", balance: "89.8 rub", productName: "Loan 1")
    static let loan2: Self = .init(id: 9, productType: .loan, number: "9999", balance: "26.8 rub", productName: "Loan 2")
    static let loan3: Self = .init(id: 10, productType: .loan, number: "1010", balance: "89.8 rub", productName: "Loan 3")
}

extension Array where Element == Product {
    
    static let allProducts: Self = [
        .card, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn, .cardRegular,
        .account1, .account2, .account3,
        .deposit1, .deposit2, .deposit3,
        .loan1, .loan2, .loan3
    ]
}

extension Array where Element == ProductData {
    
    static let preview: Self = [
        .card1, .card2, .card3, .card4, .card5,
        .account1, .account2, .account3,
        .deposit1, .deposit2, .deposit3,
        .loan1, .loan2, .loan3
    ]
}

extension CarouselComponentConfig {
    
    static let preview: Self = .init(
        carousel: .init(
            item: .init(
                spacing: 13,
                horizontalPadding: 20
            ),
            group: .init(
                spacing: 8,
                buttonFont: .footnote,
                shadowForeground: Color(red: 0.11, green: 0.11, blue: 0.11),
                buttonForegroundPrimary: Color(red: 0.91, green: 0.92, blue: 0.92),
                buttonForegroundSecondary: Color(red: 28/255, green: 28/255, blue: 28/255),
                buttonIconForeground: Color(red: 0.91, green: 0.92, blue: 0.92)
            ),
            spoilerImage: Image("chevron"),
            separatorForeground: Color(red: 0.91, green: 0.92, blue: 0.92),
            productDimensions: .regular),
        selector: .init(
            optionConfig: .init(
                frameHeight: 24,
                textFont: .caption2,
                textForeground: Color(red: 0.6, green: 0.6, blue: 0.6),
                textForegroundSelected: Color(red: 0.11, green: 0.11, blue: 0.11),
                shapeForeground: .white,
                shapeForegroundSelected: Color(red: 0.96, green: 0.96, blue: 0.96)
            ),
            itemSpacing: 8
        )
    )
}

