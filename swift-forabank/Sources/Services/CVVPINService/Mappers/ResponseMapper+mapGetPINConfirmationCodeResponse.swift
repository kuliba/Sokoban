//
//  ResponseMapper+mapGetPINConfirmationCodeResponse.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import Foundation

public struct GetPINConfirmationCodeResponse: Equatable {
    
    let eventID: String
    let phone: String
    
    public init(
        eventID: String,
        phone: String
    ) {
        self.eventID = eventID
        self.phone = phone
    }
}

public extension ResponseMapper {
    
    typealias GetPINConfirmationCodeResult = Result<GetPINConfirmationCodeResponse, GetPINConfirmationCodeError>
    
    static func mapGetPINConfirmationCodeResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetPINConfirmationCodeResult {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                let confirmation = try JSONDecoder().decode(Confirmation.self, from: data)
                return .success(.init(
                    eventID: confirmation.eventId,
                    phone: confirmation.phone
                ))
                
            default:
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.server(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
        } catch {
            return .failure(.invalidData(
                statusCode: httpURLResponse.statusCode
            ))
        }
    }
    
    enum GetPINConfirmationCodeError: Error {
        
        case invalidData(statusCode: Int)
        case server(statusCode: Int, errorMessage: String)
    }
    
    private struct Confirmation: Decodable {
        
        let eventId: String
        let phone: String
    }
}
