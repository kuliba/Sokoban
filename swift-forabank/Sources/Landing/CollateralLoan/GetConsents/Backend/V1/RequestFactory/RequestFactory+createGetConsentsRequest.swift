//
//  RequestFactory+createGetConsentsRequest.swift
//
//
//  Created by Valentin Ozerov on 18.11.2024.
//

import Foundation
import RemoteServices
import ForaTools

public extension RequestFactory {

    struct GetConsentsPayload: Encodable, Equatable {
        
        public let applicationId: Int
        public let docIds: [String]
        
        public init(applicationId: Int, docIds: [String]) {
            self.applicationId = applicationId
            self.docIds = docIds
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
                "applicationId": String(applicationId),
                "docIds": try mapFiles
            ]
        }
    }
    
    private var mapFiles: String {

        get throws {
            
            let data = try JSONSerialization.data(withJSONObject: docIds as [String])
            
            guard
                let output = String(data: data, encoding: String.Encoding.utf8)
            else {
                throw TranscodeError.dataToStringConversionFailure
            }
            
            return output
        }
    }
    
    enum TranscodeError: Error {
        
        case dataToStringConversionFailure
    }
}
