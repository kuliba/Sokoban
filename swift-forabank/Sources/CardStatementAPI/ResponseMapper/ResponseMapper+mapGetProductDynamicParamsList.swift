//
//  ResponseMapper+mapGetProductDynamicParamsList.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public extension ResponseMapper {
    
    static func mapGetProductDynamicParamsList(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Swift.Result<DynamicParamsList, MappingError> {
        
        let statusCode = response.statusCode
        
        switch statusCode {
        case statusCode200:
            return handle200(with: data)
            
        default:
            return errorByCode(statusCode)
        }
    }
    
    private static func handle200(with data: Data) -> Swift.Result<DynamicParamsList, MappingError> {
        
        fatalError("unimplemented")

        /*do {
            
            }
        } catch {
            return .failure(.mappingFailure(.defaultErrorMessage))
        }*/
    }
    
    private static func errorByCode(
        _ code: Int
    ) -> Swift.Result<DynamicParamsList, MappingError> {
        
        .failure(.mappingFailure(HTTPURLResponse.localizedString(forStatusCode: code)))
    }
}

private let statusCode200 = 200

private struct GetProductDynamicParamsListResponse: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: ResponseMapper._Data?
}

private extension ResponseMapper {
    
    typealias _Data = [_DTO]
}

private extension ResponseMapper {
    
    struct _DTO: Decodable, Equatable {
    }
}
