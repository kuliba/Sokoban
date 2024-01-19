//
//  ResponseMapper+mapGetCardStatementResponse.swift
//
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

extension ResponseMapper {
        
    public static func mapGetCardStatementResponse(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Swift.Result<[GetCardStatementForPeriodResponse], MapperError> {
        
        let statusCode = response.statusCode
        
        switch statusCode {
        case statusCode200:
            return handle200(with: data)
            
        default:
            return errorByCode(statusCode)
        }
    }
        
    private static func handle200(with data: Data) -> Swift.Result<[GetCardStatementForPeriodResponse], MapperError> {
        
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
    ) -> Swift.Result<[GetCardStatementForPeriodResponse], MapperError> {
        
        .failure(.mappingFailure(HTTPURLResponse.localizedString(forStatusCode: code)))
    }
    
    public enum MapperError: Error, Equatable {
        
        case mappingFailure(String)
        case not200Status(String)
    }
}

private let statusCode200 = 200

public extension String {
    
    static let defaultError: Self = "Возникла техническая ошибка"
}

private struct Response: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: [GetCardStatementForPeriodResponse]?
}
