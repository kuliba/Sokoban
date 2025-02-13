//
//  RequestFactory+createGetConsentsRequest.swift
//
//
//  Created by Valentin Ozerov on 18.11.2024.
//

import Foundation
import RemoteServices
import VortexTools

public extension RequestFactory {

    struct GetConsentsPayload: Encodable, Equatable {
        
        public let applicationID: Int
        
        public init(applicationID: Int) {
            
            self.applicationID = applicationID
        }
    }
    
    static func createGetConsentsRequest(
        url: URL,
        payload: GetConsentsPayload
    ) throws -> URLRequest {
                
        let url = try url.appendingQueryItems(parameters: payload.parameters)
        return createEmptyRequest(.get, with: url)
    }
}

extension RequestFactory.GetConsentsPayload {

    var parameters: [String: String] {

        get throws {

            [
                "applicationId": String(applicationID)
            ]
        }
    }
    
    enum TranscodeError: Error {
        
        case dataToStringConversionFailure
    }
}
