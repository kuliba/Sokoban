//
//  PublicServerSessionKeyMapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2023.
//

import CvvPin
import Foundation

enum PublicServerSessionKeyMapper {
    
    #warning("should throw custom error! with case for server error || reuse Generic Mapper")
    static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) throws -> FormSessionKeyDomain.Response {
        
        guard response.statusCode == statusCode200
        else {
            throw NSError(domain: "non-200 HTTPURLResponse", code: response.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(DecodablePublicServerSessionKeyPayload.self, from: data)
        
        return decoded.response
    }
    
    private static let statusCode200 = 200
    
    private struct DecodablePublicServerSessionKeyPayload: Decodable {
        
        let publicServerSessionKey: String
        let eventId: String
        let sessionTTL: Int
        
        var response: FormSessionKeyDomain.Response {
            
            .init(
                publicServerSessionKey: .init(value: publicServerSessionKey),
                eventID: .init(value: eventId),
                sessionTTL: .init(sessionTTL)
            )
        }
    }
}
