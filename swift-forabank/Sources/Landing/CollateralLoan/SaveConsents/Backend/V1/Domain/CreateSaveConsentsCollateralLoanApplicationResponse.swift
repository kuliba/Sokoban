//
//  CreateSaveConsentsCollateralLoanApplicationResponse.swift
//
//
//  Created by Valentin Ozerov on 24.10.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public struct CreateSaveConsentsCollateralLoanApplicationResponse: Equatable {
        
        public let applicationId: UInt
        public let name: String
        public let amount: UInt
        public let termDays: UInt
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
            termDays: UInt,
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
            self.termDays = termDays
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
