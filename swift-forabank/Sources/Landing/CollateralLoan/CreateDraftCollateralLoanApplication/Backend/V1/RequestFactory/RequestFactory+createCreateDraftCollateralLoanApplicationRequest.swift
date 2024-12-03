//
//  RequestFactory+createCreateDraftCollateralLoanApplicationRequest.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {

    struct CreateDraftCollateralLoanApplicationPayload: Encodable, Equatable {
     
        public let name: String
        public let amount: UInt
        public let termMonth: UInt
        public let collateralType: String
        public let interestRate: Double
        public let collateralInfo: String
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
    
    static func createCreateDraftCollateralLoanApplicationRequest(
        url: URL,
        payload: Payload
    ) throws -> URLRequest {
                
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
    
    typealias Payload = CreateDraftCollateralLoanApplicationPayload
}

extension RequestFactory.CreateDraftCollateralLoanApplicationPayload {
    
    var httpBody: Data {

        get throws {
            
            let parameters: [String: Any] = [
                "name": name,
                "amount": amount,
                "termMonth": termMonth,
                "collateralType": collateralType,
                "interestRate": interestRate,
                "collateralInfo": collateralInfo,
                "cityName": cityName,
                "payrollClient": payrollClient
            ]
                        
            return try JSONSerialization.data(
                withJSONObject: parameters as [String: Any]
            )
        }
    }
}
