//
//  CollateralLandingApplicationSaveConsentsResult.swift
//
//
//  Created by Valentin Ozerov on 21.01.2025.
//

import Foundation

public struct CollateralLandingApplicationSaveConsentsResult: Equatable {
    
    public let applicationID: UInt
    public let name: String
    public let amount: UInt
    public let termMonth: UInt
    public let collateralType: String
    public let interestRate: UInt
    public let collateralInfo: String?
    public let documents: [String]
    public let cityName: String
    public let status: String
    public let responseMessage: String
    
    public init(
        applicationID: UInt,
        name: String,
        amount: UInt,
        termMonth: UInt,
        collateralType: String,
        interestRate: UInt,
        collateralInfo: String?,
        documents: [String],
        cityName: String,
        status: String,
        responseMessage: String
    ) {
        self.applicationID = applicationID
        self.name = name
        self.amount = amount
        self.termMonth = termMonth
        self.collateralType = collateralType
        self.interestRate = interestRate
        self.collateralInfo = collateralInfo
        self.documents = documents
        self.cityName = cityName
        self.status = status
        self.responseMessage = responseMessage
    }
}

public extension CollateralLandingApplicationSaveConsentsResult {
    
    func formattedAmount() -> String {
        
        String(format: "%ld %@", locale: Locale.current, amount, rubSymbol)
    }
}

// MARK: Helpers

var rubSymbol: String {
    
    let code = "RUB"
    let locale = NSLocale(localeIdentifier: code)
    return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code) ?? "₽"
}

public extension CollateralLandingApplicationSaveConsentsResult {
    
    static let preview = Self(
        applicationID: 9,
        name: "Кредит под залог транспорта",
        amount: 99998,
        termMonth: 365,
        collateralType: "CAR",
        interestRate: 18,
        collateralInfo: "Лада Приора",
        documents: [
            "/persons/381/collateral_loan_applications/9/consent_processing_personal_data.pdf",
            "/persons/381/collateral_loan_applications/9/consent_request_credit_history.pdf"
        ],
        cityName: "Москва",
        status: "submitted_for_review",
        responseMessage: "Специалист банка свяжется с Вами в ближайшее время."
    )
}
