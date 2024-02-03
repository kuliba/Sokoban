//
//  NanoServices+makeFPSGetBankDefault.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Fetcher
import Foundation
import GenericRemoteService

extension NanoServices {
    
    // getBankDefault
    typealias GetBankDefaultResult = Result<BankDefault, ServiceFailure>
    typealias GetBankDefaultCompletion = (GetBankDefaultResult) -> Void
    typealias GetBankDefault = (PhoneNumber, @escaping GetBankDefaultCompletion) -> Void
    
    static func makeFPSGetBankDefault(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> GetBankDefault {
        
        let getBankDefaultService = loggingRemoteService(
            createRequest: ForaBank.RequestFactory.createGetBankDefaultRequest,
            httpClient: httpClient,
            mapResponse: FastPaymentsSettings.ResponseMapper.mapGetBankDefaultResponse,
            log: log
        )
        #warning("use adapter to simplify expression")
        return { payload, completion in
            
            getBankDefaultService.fetch(.init(payload.rawValue)) {
                
#warning("limit is lost her - a better way would be to get `ServiceError` from `mapGetBankDefaultResponse` and map special limit case here with a special error type instead of `ServiceFailure`")
                completion($0
                    .map { .init($0.rawValue) }
                    .mapError(ServiceFailure.init(error:))
                )
            }
        }
    }
}

// MARK: - Adapters

/*
 public enum GetBankDefaultMappingError: Error, Equatable {
     
     case invalid(statusCode: Int, data: Data)
     case limit(errorMessage: String)
     case server(statusCode: Int, errorMessage: String)
 }
 
 private extension GetBankDefaultMappingError {
     
     init(error: ResponseMapper.MappingError) {
         
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

 */

private extension ServiceFailure {
    
//    init(error: RemoteServiceError<Error, Error, GetBankDefaultMappingError>) {
//        
//        switch error {
//        case .createRequest, .performRequest:
//            self = .connectivityError
//            
//        case let .mapResponse(mapResponseError):
//            switch mapResponseError {
//            case .invalid:
//                self = .connectivityError
//                
//                #warning("limit is lost in this conversion - a better way would be to get `ServiceError` from `mapGetBankDefaultResponse` and map special limit case here with a special error type")
//            case let .limit(errorMessage),
//                let .server(_, errorMessage):
//                self = .serverError(errorMessage)
//            }
//        }
//    }
}
/*
public enum GetBankDefaultMappingError: Error, Equatable {
    
    case invalid(statusCode: Int, data: Data)
    case limit(errorMessage: String)
    case server(statusCode: Int, errorMessage: String)
}

private extension GetBankDefaultMappingError {
    
    init(error: ResponseMapper.MappingError) {
        
        
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
*/
