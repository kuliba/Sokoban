//
//  ResponseMapper+mapCollateralLoanLandingSaveConsentsResponse.swift
//
//
//  Created by Valentin Ozerov on 24.10.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapSaveConsentsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CollateralLoanLandingSaveConsentsResponse> {

        map(
            data, httpURLResponse,
            mapOrThrow: map
        )
    }
    
    private static func map(
        _ data: _Data
    ) throws -> CollateralLoanLandingSaveConsentsResponse {

        try data.getCollateralLoanLandingConsents()
    }
    
    private struct InvalidResponse: Error {}
}

private extension ResponseMapper._Data {
    
    func getCollateralLoanLandingConsents() throws
        -> ResponseMapper.CollateralLoanLandingSaveConsentsResponse {
        
        guard
            let applicationId = self.applicationId,
            let name = self.name,
            let amount = self.amount,
            let termMonth = self.termMonth,
            let collateralType = self.collateralType,
            let interestRate = self.interestRate,
            let documents = self.documents,
            let cityName = self.cityName,
            let status = self.status,
            let responseMessage = self.responseMessage
        else {
            throw ResponseMapper.InvalidResponse()
        }

        return .init(
            applicationId: applicationId,
            name: name,
            amount: amount,
            termMonth: termMonth,
            collateralType: collateralType,
            interestRate: interestRate,
            collateralInfo: collateralInfo,
            documents: documents,
            cityName: cityName,
            status: status,
            responseMessage: responseMessage
        )
    }
}

private extension ResponseMapper {

    struct _Data: Decodable {
        
        let applicationId: UInt?
        let name: String?
        let amount: UInt?
        let termMonth: UInt?
        let collateralType: String?
        let interestRate: UInt?
        let collateralInfo: String?
        let documents: [String]?
        let cityName: String?
        let status: String?
        let responseMessage: String?
    }
}
