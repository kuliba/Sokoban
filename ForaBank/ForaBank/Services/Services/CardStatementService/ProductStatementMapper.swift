//
//  ProductStatementMapper.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import Foundation

struct ProductStatementMapper {
    
    typealias Result = Swift.Result<[ProductStatementData], MapperError>
    
    public static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Result {
        
        let statusCode = response.statusCode
        
        switch statusCode {
        case statusCode200:
            return handle200(with: data)
            
        default:
            return .failure(.mapError(HTTPURLResponse.localizedString(forStatusCode: statusCode)))
        }
    }
    
    private static func handle200(with data: Data) -> Result {
        
        do {
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601)

            let response = try decoder.decode(Response.self, from: data)
            switch response.statusCode {
                
            default:
                guard let data = response.data
                else { return .failure(.mapError(response.errorMessage ?? .defaultError))}
                return .success(data)
            }
        } catch {
            return .failure(.mapError(.defaultError))
        }
    }
    
    enum MapperError: Error, Equatable {
        
        case mapError(String)
    }
}

private let statusCode200 = 200

private struct Response: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: [ProductStatementData]?
}
