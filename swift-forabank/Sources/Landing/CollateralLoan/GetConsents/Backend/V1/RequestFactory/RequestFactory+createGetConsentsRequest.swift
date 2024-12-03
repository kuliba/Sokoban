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
        
        public let applicationID: Int
        public let docIDs: [String]
        
        public init(applicationID: Int, docIDs: [String]) {
            self.applicationID = applicationID
            self.docIDs = docIDs
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
                "applicationId": String(applicationID),
                "docIds": try mapFiles()
            ]
        }
    }
    
    private func mapFiles() throws -> String {
        
        let data = try JSONSerialization.data(withJSONObject: docIDs as [String])
        
        guard
            let output = String(data: data, encoding: String.Encoding.utf8)
        else {
            throw TranscodeError.dataToStringConversionFailure
        }
        
        return output
    }
    
    enum TranscodeError: Error {
        
        case dataToStringConversionFailure
    }
}
