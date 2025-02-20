//
//  ResponseMapper+mapCollateralLoanLandingSaveConsentsResponse.swift
//
//
//  Created by Valentin Ozerov on 24.10.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    typealias MappingError = RemoteServices.ResponseMapper.MappingError
    typealias GetSaveConsentsResult = Result<CollateralLoanLandingSaveConsentsResponse, MappingError>
    
    static func mapSaveConsentsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetSaveConsentsResult {

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
            let applicationID = self.applicationId,
            let name = self.name,
            let amount = self.amount,
            let term = self.term,
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
            applicationID: UInt(applicationID),
            name: name,
            amount: UInt(amount),
            term: term,
            collateralType: collateralType,
            interestRate: interestRate,
            collateralInfo: collateralInfo,
            documents: documents,
            cityName: cityName,
            status: status,
            responseMessage: responseMessage,
            description: description
        )
    }
}

private extension ResponseMapper {

    struct _Data: Decodable {
        
        let applicationId: Int?
        let name: String?
        let amount: Int?
        let term: String?
        let collateralType: String?
        let interestRate: Double?
        let collateralInfo: String?
        let documents: [String]?
        let cityName: String?
        let status: String?
        let responseMessage: String?
        let description: String?
    }
}
