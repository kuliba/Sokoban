//
//  CollateralLandingApplicationSubmitPayload.swift
//
//
//  Created by Valentin Ozerov on 20.01.2025.
//

public struct CollateralLandingApplicationCreateDraftPayload: Equatable {
    
    public let name: String
    public let amount: UInt
    public let termMonth: UInt
    public let collateralType: String
    public let interestRate: Double
    public let collateralInfo: String?
    public let cityName: String
    public let payrollClient: Bool
    
    public init(
        name: String,
        amount: UInt,
        termMonth: UInt,
        collateralType: String,
        interestRate: Double,
        collateralInfo: String,
        cityName: String,
        payrollClient: Bool
    ) {
        
        self.name = name
        self.amount = amount
        self.termMonth = termMonth
        self.collateralType = collateralType
        self.interestRate = interestRate
        self.collateralInfo = collateralInfo
        self.cityName = cityName
        self.payrollClient = payrollClient
    }
}
