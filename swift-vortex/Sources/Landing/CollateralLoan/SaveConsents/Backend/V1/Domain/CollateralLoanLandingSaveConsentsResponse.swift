//
//  CollateralLoanLandingSaveConsentsResponse.swift
//
//
//  Created by Valentin Ozerov on 24.10.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public struct CollateralLoanLandingSaveConsentsResponse: Equatable {
        
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
}
