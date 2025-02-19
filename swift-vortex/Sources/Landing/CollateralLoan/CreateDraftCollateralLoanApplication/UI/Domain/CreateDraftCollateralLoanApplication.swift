//
//  CreateDraftCollateralLoanApplicationData.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import Foundation

public struct CreateDraftCollateralLoanApplication {
    
    public let amount: UInt
    public let cities: [String]
    public let consents: [Consent]
    public let icons: Icons
    public let maxAmount: UInt
    public let minAmount: UInt
    public let name: String
    public let percent: Double
    public let periods: [Period]
    public let selectedMonths: UInt

    public init(
        amount: UInt,
        cities: [String],
        consents: [Consent],
        icons: Icons,
        maxAmount: UInt,
        minAmount: UInt,
        name: String,
        percent: Double,
        periods: [Period],
        selectedMonths: UInt
    ) {
        self.amount = amount
        self.cities = cities
        self.consents = consents
        self.icons = icons
        self.maxAmount = maxAmount
        self.minAmount = minAmount
        self.name = name
        self.percent = percent
        self.periods = periods
        self.selectedMonths = selectedMonths
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
    
    public struct Consent {
        
        public let name: String
        public let link: String
        
        public init(
            name: String,
            link: String
        ) {
            self.name = name
            self.link = link
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

extension CreateDraftCollateralLoanApplication {
    
    var formattedPercent: String {
        
        String(format: "%.1f", percent) + "%"
    }
    
    var formattedAmount: String {
        
        amount.formattedCurrency()
    }
    
    var selectedPeriodTitle: String {
        
        periods.first { $0.months == selectedMonths }?.title ?? ""
    }
    
    public var hintText: String {
        
        let minAmount = minAmount.formattedCurrency()
        let maxAmount = maxAmount.formattedCurrency()
        
        return "Мин. - \(minAmount), Макс. - \(maxAmount)"
    }
    
    // MARK: Helpers
    
    var rubSymbol: String {
        
        let code = "RUB"
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code) ?? "₽"
    }
}

extension CreateDraftCollateralLoanApplication {
    
    public static let preview = Self(
        amount: 1_234_567,
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
        consents: [
            .init(name: "Согласие 1", link: "https://www.forabank.ru/"),
            .init(name: "Согласие 2", link: "https://www.forabank.ru/")
            ],
        icons: .init(
            productName: "info",
            amount: "info",
            term: "info",
            rate: "info",
            city: "info"
        ),
        maxAmount: 5_000_000,
        minAmount: 1_000_000,
        name: "Кредит под залог транспорта",
        percent: 18.51114,
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
        selectedMonths: 24
    )
}

extension CreateDraftCollateralLoanApplication: Equatable {}
extension CreateDraftCollateralLoanApplication.Icons: Equatable {}
extension CreateDraftCollateralLoanApplication.Consent: Equatable {}

extension CreateDraftCollateralLoanApplication: Identifiable {
    
    public var id: String { name }
}

extension UInt {
    
    func formattedCurrency(_ currencySymbol: String = "₽") -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = currencySymbol
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.maximumFractionDigits = 0

        if let value = currencyFormatter.string(from: NSNumber(value: self)) {
            return value
        }
        
        return String(self)
    }
}
