//
//  ResponseMapper+mapMakeSetBankDefaultResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import Foundation

public enum MakeSetBankDefaultMappingError: Error, Equatable {
    
    case invalid(statusCode: Int, data: Data)
    case retry(errorMessage: String)
    case server(statusCode: Int, errorMessage: String)
}

extension ResponseMapper {
    
    typealias MakeSetBankDefaultResponseResult = Result<Void, MakeSetBankDefaultMappingError>
    
    static func mapMakeSetBankDefaultResponseResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MakeSetBankDefaultResponseResult {
        
        map(data, httpURLResponse, mapOrThrow: map)
            .mapError(MakeSetBankDefaultMappingError.init(error:))
    }
    
    private static func map(
        _ data: _Data
    ) throws -> Void {
        
        if data != nil { throw InvalidResponse() }
    }
    
    private struct InvalidResponse: Error {}
    
    private typealias _Data = Data?
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
