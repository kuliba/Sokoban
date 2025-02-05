//
//  ResponseMapper+mapCreateDraftCollateralLoanApplicationResponse.swift
//
//
//  Created by Valentin Ozerov on 27.11.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapCreateDraftCollateralLoanApplicationResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CreateDraftCollateralLoanApplicationData> {

        map(
            data, httpURLResponse,
            mapOrThrow: map
        )
    }
    
    private static func map(
        _ data: _Data
    ) throws -> CreateDraftCollateralLoanApplicationData {

        try data.getCreateDraftCollateralLoanApplicationData()
    }
    
    private struct InvalidResponse: Error {}
}

private extension ResponseMapper._Data {
    
    func getCreateDraftCollateralLoanApplicationData() throws
        -> ResponseMapper.CreateDraftCollateralLoanApplicationData {
        
        guard
            let applicationId,
            let verificationCode
        else {
            throw ResponseMapper.InvalidResponse()
        }

        return .init(
            applicationId: applicationId,
            verificationCode: verificationCode
        )
    }
}

private extension ResponseMapper {

    struct _Data: Decodable {
        
        let applicationId: UInt?
        let verificationCode: String?
    }
}
