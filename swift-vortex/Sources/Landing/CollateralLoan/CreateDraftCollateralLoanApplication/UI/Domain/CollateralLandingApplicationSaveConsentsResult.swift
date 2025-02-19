//
//  CollateralLandingApplicationSaveConsentsResult.swift
//
//
//  Created by Valentin Ozerov on 21.01.2025.
//

import Foundation
import CollateralLoanLandingGetConsentsBackend
import RemoteServices

public struct CollateralLandingApplicationSaveConsentsResult: Equatable {
    
    public let applicationID: UInt
    public let name: String
    public let amount: UInt
    public let term: String
    public let collateralType: String
    public let interestRate: Double
    public let collateralInfo: String?
    public let documents: [String]
    public let cityName: String
    public let status: String
    public let responseMessage: String
    public let verificationCode: String
    
    public init(
        applicationID: UInt,
        name: String,
        amount: UInt,
        term: String,
        collateralType: String,
        interestRate: Double,
        collateralInfo: String?,
        documents: [String],
        cityName: String,
        status: String,
        responseMessage: String,
        verificationCode: String
    ) {
        self.applicationID = applicationID
        self.name = name
        self.amount = amount
        self.term = term
        self.collateralType = collateralType
        self.interestRate = interestRate
        self.collateralInfo = collateralInfo
        self.documents = documents
        self.cityName = cityName
        self.status = status
        self.responseMessage = responseMessage
        self.verificationCode = verificationCode
    }
}

public extension CollateralLandingApplicationSaveConsentsResult {
    
    var formattedAmount: String {
        
        amount.formattedCurrency()
    }
    
    var payload: RemoteServices.RequestFactory.GetConsentsPayload {
        
        .init(
            cryptoVersion: "1.0", // Constant, can be skipped in request
            applicationId: applicationID,
            verificationCode: verificationCode
        )
    }
}

public extension CollateralLandingApplicationSaveConsentsResult {
    
    static let preview = Self(
        applicationID: 9,
        name: "Кредит под залог транспорта",
        amount: 99998,
        term: "365",
        collateralType: "CAR",
        interestRate: 18,
        collateralInfo: "Лада Приора",
        documents: [
            "/persons/381/collateral_loan_applications/9/consent_processing_personal_data.pdf",
            "/persons/381/collateral_loan_applications/9/consent_request_credit_history.pdf"
        ],
        cityName: "Москва",
        status: "submitted_for_review",
        responseMessage: "Специалист банка свяжется с Вами в ближайшее время.",
        verificationCode: "123456"
    )
}
