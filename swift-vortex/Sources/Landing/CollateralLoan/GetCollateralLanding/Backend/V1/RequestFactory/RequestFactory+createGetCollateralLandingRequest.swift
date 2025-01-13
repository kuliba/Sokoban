//
//  RequestFactory+createGetCollateralLandingRequest.swift
//
//
//  Created by Valentin Ozerov on 28.11.2024.
//

import Foundation
import RemoteServices
import VortexTools

public extension RequestFactory {

    enum CollateralLoanLandingType: Equatable {
        case car
        case realEstate
    }

    static func createGetCollateralLandingRequest(
        url: URL
    ) throws -> URLRequest {
                
        return createEmptyRequest(.get, with: url)
    }
}
