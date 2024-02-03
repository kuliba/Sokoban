//
//  ResponseMapper+mapGetBankDefaultResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

public enum GetBankDefaultMappingError: Error, Equatable {
    
    case invalid(statusCode: Int, data: Data)
    case limit(errorMessage: String)
    case server(statusCode: Int, errorMessage: String)
}

public extension ResponseMapper {
    #warning("mapping to `GetBankDefaultMappingError` should perforn upper level client")
    // typealias GetBankDefaultResult = MappingResult<GetBankDefault>
    typealias GetBankDefaultResult = Result<GetBankDefault, GetBankDefaultMappingError>
    
    static func mapGetBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetBankDefaultResult {
        
        map(data, httpURLResponse, mapOrThrow: map)
            .mapError(GetBankDefaultMappingError.init(error:))
    }
    
    private static func map(
        _ data: _Data
    ) throws -> GetBankDefault {
        
        .init(data.foraBank)
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let foraBank: Bool
    }
}

private extension GetBankDefaultMappingError {
    
    init(error: MappingError) {
        
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .server(_, .limitErrorMessage):
            self = .limit(errorMessage: .limitErrorMessage)
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

private extension String {
    
    static let limitErrorMessage = "Исчерпан лимит запросов. Повторите попытку через 24 часа."
}
