//
//  RequestFactory+createGetCollateralLoanLandingRequest.swift
//  ForaBank
//
//  Created by Valentin Ozerov on 04.10.2024.
//

import ForaTools
import Foundation
import RemoteServices

public extension RequestFactory {
    static func createGetCollateralLoanLandingRequest(
        parameters: [String: String],
        url: URL
    ) throws -> URLRequest {
        let url = try url.appendingQueryItems(parameters: parameters)
        return createEmptyRequest(.get, with: url)
    }
}
