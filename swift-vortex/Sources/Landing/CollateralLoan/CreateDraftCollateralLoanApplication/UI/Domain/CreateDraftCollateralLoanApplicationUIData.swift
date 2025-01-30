//
//  CreateDraftCollateralLoanApplicationData.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import Foundation

public struct CreateDraftCollateralLoanApplicationUIData {
    
    public let amount: UInt
    public let cities: [String]
    public let icons: Icons
    public let maxAmount: UInt
    public let minAmount: UInt
    public let name: String
    public let percent: Double
    public let periods: [Period]
    public let selectedCity: String
    public let selectedMonths: UInt

    public init(
        name: String,
        amount: UInt,
        minAmount: UInt,
        maxAmount: UInt,
        periods: [Period],
        selectedMonths: UInt,
        percent: Double,
        cities: [String],
        selectedCity: String,
        icons: Icons
    ) {
        self.name = name
        self.amount = amount
        self.minAmount = minAmount
        self.maxAmount = maxAmount
        self.periods = periods
        self.selectedMonths = selectedMonths
        self.percent = percent
        self.cities = cities
        self.selectedCity = selectedCity
        self.icons = icons
    }
    
    public struct Period: Equatable {
        
        public let title: String
        public let months: UInt
        
        public init(
            title: String,
            months: UInt
        ) {
            self.title = title
            self.months = months
        }
    }
    
    public struct Icons {
        
        public let productName: String
        public let amount: String
        public let term: String
        public let rate: String
        public let city: String
        
        public init(
            productName: String,
            amount: String,
            term: String,
            rate: String,
            city: String
        ) {
            self.productName = productName
            self.amount = amount
            self.term = term
            self.rate = rate
            self.city = city
        }
    }
}

extension CreateDraftCollateralLoanApplicationUIData {
    
    var formattedPercent: String {
        
        String(format: "%.1f", percent) + "%"
    }
    
    var formattedAmount: String {
        
        String(format: "%ld %@", locale: Locale.current, amount, rubSymbol)
    }
    
    var selectedPeriodTitle: String {
        
        periods.first { $0.months == selectedMonths }?.title ?? ""
    }
    
    public var hintText: String {
        
        let minAmount = String(format: "%ld %@", locale: Locale.current, minAmount, rubSymbol)
        let maxAmount = String(format: "%ld %@", locale: Locale.current, maxAmount, rubSymbol)
        
        return "Мин. - \(minAmount), Макс. - \(maxAmount)"
    }
    
    // MARK: Helpers
    
    var rubSymbol: String {
        let code = "RUB"
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code) ?? "₽"
    }
}

extension CreateDraftCollateralLoanApplicationUIData {
    
    public static let preview = Self(
        name: "Кредит под залог транспорта",
        amount: 1_234_567,
        minAmount: 1_000_000,
        maxAmount: 5_000_000,
        periods: [
            .init(title: "6 месяцев", months: 6),
            .init(title: "9 месяцев", months: 9),
            .init(title: "1 год", months: 12),
            .init(title: "2 года", months: 24),
            .init(title: "3 года", months: 36),
            .init(title: "4 года", months: 48),
            .init(title: "5 лет", months: 60),
            .init(title: "6 лет", months: 72),
            .init(title: "7 лет", months: 84)
        ],
        selectedMonths: 24,
        percent: 18.51114,
        cities: [
            "Москва",
            "п.Коммунарка",
            "Реутов",
            "Орехово-Зуево",
            "Апрелевка",
            "Наро-Фоминск",
            "Подольск",
            "Балашиха",
            "Люберцы",
            "Одинцово",
            "Химки",
            "Мытищи",
            "Красногорск",
            "Серпухов",
            "Домодедово",
            "п.Случайный",
            "Калуга",
            "Обнинск",
            "п.Воротынск",
            "Малоярославец",
            "Балабаново",
            "Тула",
            "Коломна",
            "Ярославль",
            "Рыбинск",
            "Иваново",
            "Пермь",
            "Саранск",
            "Нижний Новгород",
            "Ростов-на-Дону",
            "Сочи",
            "Краснодар",
            "Армавир",
            "Тамбов",
            "Санкт-Петербург",
            "Ставрополь",
            "Тверь",
            "Липецк"
        ],
        selectedCity: "Балабаново",
        icons: .init(
            productName: "info",
            amount: "info",
            term: "info",
            rate: "info",
            city: "info"
        )
    )
}

extension CreateDraftCollateralLoanApplicationUIData: Equatable {}
extension CreateDraftCollateralLoanApplicationUIData.Icons: Equatable {}

extension CreateDraftCollateralLoanApplicationUIData: Identifiable {
    
    public var id: String { name }
}
