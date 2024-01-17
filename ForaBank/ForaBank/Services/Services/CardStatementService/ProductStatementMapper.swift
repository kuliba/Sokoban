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
            let decodableData = try JSONDecoder().decode(DecodeProductStatmentData.self, from: data)
            
            switch decodableData.statusCode {
                
            default:
                guard let data = decodableData.data
                else { return .failure(.mapError(decodableData.errorMessage ?? .defaultError))}
                return .success(data)
            }
        } catch {
            return .failure(.mapError(.defaultError))
        }
    }
    
    enum MapperError: Error, Equatable {
        
        case mapError(String)
        case status3122
    }
}

private let statusCode200 = 200

// TODO: уточнить ошибки!!!
