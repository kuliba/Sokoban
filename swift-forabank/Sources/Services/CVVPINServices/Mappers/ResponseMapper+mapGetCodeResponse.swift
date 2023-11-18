//
//  ResponseMapper+mapGetCodeResponse.swift
//  
//
//  Created by Igor Malyarov on 19.10.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias GetCodeResult = Result<GetProcessingSessionCodeResponse, GetCodeMapperError>
    
    static func mapGetCodeResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetCodeResult {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                let codePhone = try JSONDecoder().decode(CodePhone.self, from: data)
                return .success(.init(
                    code: .init(code: codePhone.code),
                    phone: .init(phone: codePhone.phone)
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
                statusCode: httpURLResponse.statusCode,
                data: data
            ))
        }
    }
    
    enum GetCodeMapperError: Error {
        
        case invalidData(statusCode: Int, data: Data)
        case server(statusCode: Int, errorMessage: String)
    }
    
    private struct CodePhone: Decodable {
        
        let code: String
        let phone: String
    }
}
