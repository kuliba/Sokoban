//
//  RequestFactory+createCollateralLoanLandingGetConsentsRequest.swift
//
//
//  Created by Valentin Ozerov on 18.11.2024.
//

import Foundation
import RemoteServices
import ForaTools

public extension RequestFactory {

    struct CreateCollateralLoanLandingGetConsentsPayload: Encodable, Equatable {
        
        public let applicationId: Int
        public let files: [String]
        
        public init(applicationId: Int, files: [String]) {
            self.applicationId = applicationId
            self.files = files
        }
    }
    
    static func createCollateralLoanLandingGetConsentsRequest(
        url: URL,
        payload: CreateCollateralLoanLandingGetConsentsPayload
    ) throws -> URLRequest {
                
        let url = try url.appendingQueryItems(parameters: payload.parameters)
        return createEmptyRequest(.get, with: url)
    }
}

extension RequestFactory.CreateCollateralLoanLandingGetConsentsPayload {

    var parameters: [String: String] {

        get throws {

            [
                "applicationId": String(applicationId),
                "files": try mapFiles
            ]
        }
    }
    
    private var mapFiles: String {

        get throws {
            
            let data = try JSONSerialization.data(withJSONObject: files as [String])
            
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
