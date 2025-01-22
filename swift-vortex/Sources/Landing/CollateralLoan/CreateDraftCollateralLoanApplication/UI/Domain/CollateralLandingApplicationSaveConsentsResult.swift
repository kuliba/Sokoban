//
//  CollateralLandingApplicationSaveConsentsResult.swift
//
//
//  Created by Valentin Ozerov on 21.01.2025.
//

public struct CollateralLandingApplicationSaveConsentsResult: Equatable {
    
    public let applicationId: UInt
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
        applicationId: UInt,
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
        self.applicationId = applicationId
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
    
    static let preview = Self(
        applicationId: 9,
        name: "Кредит под залог транспорта",
        amount: 99998,
        termMonth: 365,
        collateralType: "CAR",
        interestRate: 18,
        collateralInfo: "Лада",
        documents: [
            "/persons/381/collateral_loan_applications/9/consent_processing_personal_data.pdf",
            "/persons/381/collateral_loan_applications/9/consent_request_credit_history.pdf"
        ],
        cityName: "Москва",
        status: "submitted_for_review",
        responseMessage: "Специалист банка свяжется с Вами в ближайшее время."
    )
}
