//
//  ResponseMapper+mapShowCVVResponse.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import Foundation

public struct RemoteCVV: Equatable {
    
    public let value: String
    
    public init(_ value: String) {
        
        self.value = value
    }
}

public extension ResponseMapper {
    
    typealias ShowCVVResult = Result<RemoteCVV, ShowCVVMapperError>
    
    static func mapShowCVVResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ShowCVVResult {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                let cvv = try JSONDecoder().decode(CVV.self, from: data)
                return .success(.init(cvv.cvv))
                
            default:
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.error(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
        } catch {
            return .failure(.invalidData(
                statusCode: httpURLResponse.statusCode,
                data: data
            ))
        }
    }
    
    enum ShowCVVMapperError: Error, Equatable {
        
        case invalidData(statusCode: Int, data: Data)
        case error(
            statusCode: Int,
            errorMessage: String
        )
    }
    
    private struct CVV: Decodable {
        
        let cvv: String
    }
}
