//
//  Preview.swift
//
//
//  Created by Andryusina Nataly on 20.11.2024.
//

import SwiftUI

extension SavingsAccountConfig {
    
    static let preview: Self = .init(
        chevronDownImage: Image(systemName: "chevron.down"),
        cornerRadius: 16,
        continueButton: .init(background: .red, cornerRadius: 12, height: 56, title: .init(textFont: .body, textColor: .white)),
        divider: .gray,
        icon: .init(leading: 8, widthAndHeight: 40),
        list: .init(
            background: .gray30,
            item: .init(
                title: .init(textFont: .footnote, textColor: .black),
                subtitle: .init(textFont: .footnote, textColor: .gray)),
            title: .init(textFont: .title3, textColor: .green)),
        navTitle: .init(
            title: .init(textFont: .body, textColor: .black),
            subtitle: .init(textFont: .callout, textColor: .gray)),
        offsetForDisplayHeader: 100,
        paddings: .init(
            negativeBottomPadding: 60,
            vertical: 16,
            list: .init(horizontal: 16, vertical: 16)),
        spacing: 16)
}

extension SavingsAccountState {
    
    static let preview: Self = .init(
        advantages: .advantages,
        basicConditions: .basicConditions,
        imageLink: "1",
        questions: .preview,
        subtitle: "до 8.5%",
        title: "Накопительный счет")
}

extension SavingsAccountState.Items {
    
    static let advantages: Self = .init(
        title: "Преимущества",
        list: [
            .init(id: .init(), md5hash: "1", title: "Снятие и пополнение без ограничений", subtitle: nil),
            .init(id: .init(), md5hash: "2", title: "Бесплатный счет", subtitle: "0 руб за открытие счета")
        ])
    
    static let basicConditions: Self = .init(
        title: "Основные условия",
        list: [
            .init(id: .init(), md5hash: "2", title: "Счет только в рублях", subtitle: nil),
            .init(id: .init(), md5hash: "3", title: "Выплата ежемесячно", subtitle: nil)
        ])
}

extension SavingsAccountState.Questions {
    
    static let preview: Self = .init(
        title: "Вопросы",
        questions: [
            .init(id: .init(), answer: "ответ1", question: "вопрос1"),
            .init(id: .init(), answer: "ответ2", question: "вопрос2"),
            .init(id: .init(), answer: "ответ3", question: "вопрос3"),
        ])
}

extension Color {
    
    static let gray30: Self = .init(red: 211/255, green: 211/255, blue: 211/255, opacity: 0.3)
}
