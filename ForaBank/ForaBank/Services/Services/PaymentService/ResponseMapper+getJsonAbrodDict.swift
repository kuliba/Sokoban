//
//  ResponseMapper+getJsonAbrodDict.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 01.11.2023.
//

import Foundation

enum ResponseMapper {}

extension ResponseMapper {
    
    typealias StickerDictionaryResult = Result<//public type, StickerDictionaryError>
    
    static func mapStickerDictionaryResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> StickerDictionaryResult {
        
        do {
            
            switch httpURLResponse.statusCode {
            case 200:
                
                if data.isEmpty {
                    
                    return .failure(.invalidData(
                        statusCode: httpURLResponse.statusCode,
                        data: data
                    ))
                    
                } else {
                    
                    let stickerDictionary = try JSONDecoder().decode(_StickerDictionary.self, from: data)
                    return .success(stickerDictionary)
                }
                
            default:
                
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.error(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
            
        } catch {
            return .failure(.invalidData(
                statusCode: httpURLResponse.statusCode, data: data
            ))
            
        }
    }
    
    enum StickerDictionaryError: Error , Equatable{
        
        case error(
            statusCode: Int,
            errorMessage: String
        )
        case invalidData(statusCode: Int, data: Data)
    }
    
    struct ServerError: Decodable, Equatable {
        
        let statusCode: Int
        let errorMessage: String
    }
}

