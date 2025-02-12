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
        
        public let cryptoVersion: String
        public let applicationId: UInt
        public let verificationCode: String

        public init(
            cryptoVersion: String,
            applicationId: UInt,
            verificationCode: String
        ) {
            self.cryptoVersion = cryptoVersion
            self.applicationId = applicationId
            self.verificationCode = verificationCode
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
                "applicationId": String(applicationId)
            ]
        }
    }
    
    enum TranscodeError: Error {
        
        case dataToStringConversionFailure
    }
}
