//
//  Preview.swift
//
//
//  Created by Andryusina Nataly on 20.11.2024.
//

import SwiftUI
import PaymentComponents

extension SavingsAccountConfig {
    
    static let preview: Self = .init(
        backImage: Image(systemName: "chevron.backward"),
        bannerHeight: 703,
        chevronDownImage: Image(systemName: "chevron.down"),
        cornerRadius: 16,
        continueButton: .init(background: .red, cornerRadius: 12, height: 56, label: "Продолжить", title: .init(textFont: .body, textColor: .white)),
        divider: .gray,
        icon: .init(leading: 8, widthAndHeight: 40),
        list: .init(
            background: .gray30,
            item: .init(
                title: .init(textFont: .footnote, textColor: .black),
                subtitle: .init(textFont: .footnote, textColor: .gray)),
            title: .init(textFont: .title3, textColor: .green)),
        navTitle: .init(
            title: .init(text: "Накопительный счет", config: .init(textFont: .body, textColor: .black)),
            subtitle: .init(text: "Накопительный подзаголовок", config: .init(textFont: .callout, textColor: .gray))),
        offsetForDisplayHeader: 100,
        paddings: .init(
            negativeBottomPadding: 60,
            vertical: 16,
            list: .init(horizontal: 16, vertical: 12)),
        spacing: 16,
        questionHeight: 64
    )
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
    static let background: Self = Color(red: 0.76, green: 0.76, blue: 0.76)
    static let textSecondary: Self = Color(red: 28/255, green: 28/255, blue: 28/255)
    static let textPrimary: Self = Color(red: 61/255, green: 61/255, blue: 69/255)
    static let systemColorActive: Self = Color(red: 34/255, green: 193/255, blue: 131/255)
    static let new: Self = Color(red: 255/255, green: 187/255, blue: 54/255) //FFBB36
    static let buttonPrimary: Self = Color(red: 255/255, green: 54/255, blue: 54/255) //FF3636
}

extension OrderSavingsAccount {
    
    static let preview: Self = .init(
        currency: .init(code: 810, symbol: "₽"),
        designMd5hash: "1",
        fee: .init(open: 100, subscription: .init(period: "month", value: 0)),
        header: .init(title: "Накопительный Счет", subtitle: "Накопительный в рублях"),
        hint: "Вы можете сразу пополнить счет",
        income: "6,05%",
        links: .init(conditions: "link1", tariff: "link2"))
}

extension NumberFormatter {
    
    static func preview() -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.currencySymbol = ""

        return formatter
    }
}

extension OrderSavingsAccountState {
    
    static let preview: Self = .init(status: .result(.preview))
    static let placeholder: Self = .init(status: .inflight)
}

extension ToggleConfig {
    
    static let preview: Self = .init(colors: .init(on: .green, off: .black))
}

extension OrderSavingsAccountConfig {
    
    static let preview: Self = .init(
        amount: .init(
            amount: .init(textFont: .system(size: 24), textColor: .white),
            backgroundColor: .black.opacity(0.8),
            button: .init(
                active: .init(backgroundColor: .red, text: .init(textFont: .system(size: 14), textColor: .white)),
                inactive: .init(backgroundColor: .gray, text: .init(textFont: .system(size: 14), textColor: .white)), buttonHeight: 38),
            dividerColor: .gray30,
            title: .init(textFont: .system(size: 14), textColor: .white)),
        background: .gray30,
        cornerRadius: 12,
        header: .init(text: "Оформление\nнакопительного счета", config: .init(textFont: .system(size: 18), textColor: .black)),
        images: .init(
            back: .init(systemName: "chevron.backward"),
            checkOff: .init(systemName: "square"),
            checkOn: .init(systemName: "checkmark.square")),
        income: .init(
            image: .init(systemName: "percent"),
            imageSize: .init(width: 24, height: 24),
            title: .init(text: "Доход",
                         config: .init(textFont: .body, textColor: .gray)),
            subtitle: .init(textFont: .headline, textColor: .black)),
        linkableTexts: .init(checkBoxSize: .init(width: 24, height: 24), condition: "Я соглашаюсь с <u>Условиями</u> и ", tariff: "<u>Тарифами</u>"),
        openButton: .init(
            background: .init(active: .red, inactive: .gray),
            cornerRadius: 12,
            height: 56,
            labels: .init(open: "Открыть накопительный счет", confirm: "Подтвердить и открыть"),
            title: .init(textFont: .body, textColor: .white)),
        order: .init(
            card: .init(width: 112, height: 72),
            header: .init(title: .init(textFont: .body, textColor: .black), subtitle: .init(textFont: .subheadline, textColor: .gray)),
            image: .init(systemName: "arrow.forward"),
            imageSize: .init(width: 16, height: 16),
            options: .init(headlines: .init(
                open: "Открытие",
                service: "Стоимость обслуживания"), config: .init(title: .init(textFont: .body, textColor: .gray), subtitle: .init(textFont: .caption2, textColor: .black)))
        ),
        padding: 16,
        shimmering: .background,
        topUp: .init(
            amount: .init(
                amount: .init(text: "Сумма пополнения", config: .init(textFont: .system(size: 14), textColor: .gray)),
                fee: .init(text: "Комиссия", config: .init(textFont: .system(size: 14), textColor: .gray)),
                value: .init(textFont: .system(size: 14), textColor: .black)
            ),
            description: .init(text: "Пополнение доступно без комиссии\nс рублевого счета или карты ", config: .init(textFont: .system(size: 12), textColor: .gray)),
            image: .init(systemName: "message"),
            subtitle: .init(text: "Пополнить сейчас", config: .init(textFont: .system(size: 16), textColor: .black)),
            title: .init(text: "Хотите пополнить счет?", config: .init(textFont: .system(size: 14), textColor: .gray)),
            toggle: .preview
        )
    )
}

extension SavingsAccountDetails {
    
    static let preview: Self = .init(
        currentInterest: 22400,
        minBalance: 8000,
        paidInterest: 11134056.77,
        progress: 0.8, 
        currencyCode: "₽"
    )
}

extension SavingsAccountDetailsConfig {
    
    static let preview: Self = .init(
        chevronDown: .init(systemName: "chevron.down"),
        colors: .init(
            background: .textSecondary,
            chevron: .gray,
            progress: .textPrimary,
            shimmering: .background),
        cornerRadius: 12,
        days: .init(textFont: .system(size: 12), textColor: .gray),
        heights: .init(
            big: 340,
            header: 24,
            interest: 20,
            period: 16,
            progress: 6,
            small: 144
        ),
        info: .init(systemName: "info.circle"),
        interestDate: .init(textFont: .system(size: 16), textColor: .white),
        interestTitle: .init(textFont: .system(size: 14), textColor: .gray),
        interestSubtitle: .init(textFont: .system(size: 16), textColor: .white),
        padding: 16,
        period: .init(textFont: .system(size: 12), textColor: .gray),
        progressColors: [
            .systemColorActive,
            .new,
            .buttonPrimary
        ],
        texts: .init(
            currentInterest: "Проценты текущего периода",
            header: .init(text: "Детали счета", config: .init(textFont: .system(size: 20), textColor: .white)),
            minBalance: "Минимальный остаток текущего периода",
            paidInterest: "Выплачено всего процентов", 
            per: " / мес",
            days: "5 дней",
            interestDate: "Дата выплаты % - 31 мая",
            period: "Отчетный период 1 мая - 31 мая"
        )
    )
}
