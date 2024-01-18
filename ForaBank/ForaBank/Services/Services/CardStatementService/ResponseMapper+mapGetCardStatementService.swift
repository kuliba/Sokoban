//
//  ResponseMapper+mapGetCardStatementService.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import Foundation

extension ResponseMapper {
        
    static func mapGetCardStatementService(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Swift.Result<[ProductStatementData], MapperError> {
        
        let statusCode = response.statusCode
        
        switch statusCode {
        case statusCode200:
            return handle200(with: data)
            
        default:
            return errorByCode(statusCode)
        }
    }
    
    private static func handle200(with data: Data) -> Swift.Result<[ProductStatementData], MapperError> {
        
        do {
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601)

            let response = try decoder.decode(Response.self, from: data)
            switch response.statusCode {
                
            default:
                guard let data = response.data
                else { return .failure(.mappingFailure(response.errorMessage ?? .defaultError))}
                return .success(data)
            }
        } catch {
            return .failure(.mappingFailure(.defaultError))
        }
    }
    
    private static func errorByCode(
        _ code: Int
    ) -> Swift.Result<[ProductStatementData], MapperError> {
        
        .failure(.mappingFailure(HTTPURLResponse.localizedString(forStatusCode: code)))
    }
    
    enum MapperError: Error, Equatable {
        
        case mappingFailure(String)
        case not200Status(String)
    }
}

private let statusCode200 = 200

private struct Response: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: [ProductStatementData]?
}
