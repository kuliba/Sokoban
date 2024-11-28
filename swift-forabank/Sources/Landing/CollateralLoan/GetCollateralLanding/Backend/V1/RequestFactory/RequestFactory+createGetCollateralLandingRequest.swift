//
//  RequestFactory+createGetCollateralLandingRequest.swift
//
//
//  Created by Valentin Ozerov on 28.11.2024.
//

import Foundation
import RemoteServices
import ForaTools

public extension RequestFactory {

    struct GetCollateralLandingPayload: Encodable, Equatable {
        
        public let landingTypes: String
        
        public init(landingTypes: String) {
            self.landingTypes = landingTypes
        }
    }
    
    static func createGetCollateralLandingRequest(
        url: URL,
        payload: GetCollateralLandingPayload
    ) throws -> URLRequest {
                
        let url = try url.appendingQueryItems(parameters: payload.parameters)
        return createEmptyRequest(.get, with: url)
    }
}

extension RequestFactory.GetCollateralLandingPayload {

    var parameters: [String: String] {

        get throws {

            [
                "landingTypes": landingTypes,
            ]
        }
    }
    
    enum TranscodeError: Error {
        
        case dataToStringConversionFailure
    }
}
