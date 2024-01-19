//
//  ResponseMapper+mapMakeSetBankDefaultResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

public enum MakeSetBankDefaultMappingError: Error, Equatable {
    
    case invalid(statusCode: Int, data: Data)
    case retry(errorMessage: String)
    case server(statusCode: Int, errorMessage: String)
}

public extension ResponseMapper {
    
    typealias MakeSetBankDefaultResponseResult = Result<Void, MakeSetBankDefaultMappingError>
    
    static func mapMakeSetBankDefaultResponseResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MakeSetBankDefaultResponseResult {
        
        mapToVoid(data, httpURLResponse)
            .mapError(MakeSetBankDefaultMappingError.init(error:))
    }
}

private extension MakeSetBankDefaultMappingError {
    
    init(error: MappingError) {
        
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .server(_, .retryErrorMessage):
            self = .retry(errorMessage: .retryErrorMessage)
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

private extension String {
    
    static let retryErrorMessage = "Введен некорректный код. Попробуйте еще раз."
}
