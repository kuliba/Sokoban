//
//  ContentView_Preview.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 22.03.2024.
//

import CarouselComponent
import SwiftUI

extension Product {
    
    static let card1: Self = .init(id: 1, productType: .card, number: "1111", balance: "111.11 rub", productName: "Card 1", cardType: .main)
    static let card2: Self = .init(id: 2, productType: .card, number: "2222", balance: "222.11 rub", productName: "Card 2", cardType: .additionalOther)
    static let card3: Self = .init(id: 3, productType: .card, number: "3333", balance: "333.33 rub", productName: "Card 3", cardType: .additionalSelf)
    static let card4: Self = .init(id: 4, productType: .card, number: "4444", balance: "444.44 rub", productName: "Card 4", cardType: .additionalSelfAccOwn)
    static let card5: Self = .init(id: 5, productType: .card, number: "5555", balance: "555.55 rub", productName: "Card 5", cardType: .regular)
    
    static let account1: Self = .init(id: 6, productType: .account, number: "6661", balance: "23.11 rub", productName: "Account 1", cardType: nil)
    static let account2: Self = .init(id: 16, productType: .account, number: "6662", balance: "56.11 rub", productName: "Account 2", cardType: nil)
    static let account3: Self = .init(id: 26, productType: .account, number: "6663", balance: "78.11 rub", productName: "Account 3", cardType: nil)
    
    static let deposit1: Self = .init(id: 7, productType: .deposit, number: "7771", balance: "89.77 rub", productName: "Deposit 1", cardType: nil)
    static let deposit2: Self = .init(id: 17, productType: .deposit, number: "7772", balance: "78.77 rub", productName: "Deposit 2", cardType: nil)
    static let deposit3: Self = .init(id: 27, productType: .deposit, number: "7773", balance: "56.77 rub", productName: "Deposit 3", cardType: nil)
    
    static let loan1: Self = .init(id: 8, productType: .loan, number: "8888", balance: "89.8 rub", productName: "Loan 1", cardType: nil)
    static let loan2: Self = .init(id: 9, productType: .loan, number: "9999", balance: "26.8 rub", productName: "Loan 2", cardType: nil)
    static let loan3: Self = .init(id: 10, productType: .loan, number: "1010", balance: "89.8 rub", productName: "Loan 3", cardType: nil)
    static let loan4: Self = .init(id: 11, productType: .loan, number: "9878", balance: "78.8 rub", productName: "Loan 4", cardType: nil)
    static let loan5: Self = .init(id: 12, productType: .loan, number: "9949", balance: "39.8 rub", productName: "Loan 5", cardType: nil)
    static let loan6: Self = .init(id: 13, productType: .loan, number: "1510", balance: "782.8 rub", productName: "Loan 6", cardType: nil)
}

extension Array where Element == Product {
    
    static let preview: Self = [
        .card1, .card2, .card3, .card4, .card5,
        .account1, .account2, .account3,
        .deposit1, .deposit2, .deposit3,
        .loan1, .loan2, .loan3, .loan4, .loan5, .loan6
    ]
    
    static let previewWithOneCard: Self = [
        .card1,
        .account1, .account2, .account3,
        .deposit1, .deposit2, .deposit3,
        .loan1, .loan2, .loan3, .loan4, .loan5, .loan6
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

