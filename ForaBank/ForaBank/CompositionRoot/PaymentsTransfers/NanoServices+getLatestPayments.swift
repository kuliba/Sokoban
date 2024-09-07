//
//  NanoServices+getLatestPayments.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import Foundation
import LatestPaymentsBackendV3
import RemoteServices

extension NanoServices {
    
    typealias GetAllLatestPaymentsCompletion = (Result<[Latest], Error>) -> Void
    typealias MakeGetAllLatestPaymentsV3 = ([ServiceCategory], @escaping GetAllLatestPaymentsCompletion) -> Void
    typealias MakeGetAllLatestPaymentsV3Stringly = ([String], @escaping GetAllLatestPaymentsCompletion) -> Void
    
    static func makeGetAllLatestPaymentsV3(
        httpClient: HTTPClient,
        log: @escaping Log
    ) -> MakeGetAllLatestPaymentsV3 {
        
        let getLatest = makeGetAllLatestPaymentsV3Stringly(
            httpClient: httpClient,
            log: log
        )
        
        return { categories, completion in
            
            let parameters = categories.compactMap(\.latestPaymentsCategoryName)
            getLatest(parameters, completion)
        }
    }
    
    static func makeGetAllLatestPaymentsV3Stringly(
        httpClient: HTTPClient,
        log: @escaping Log
    ) -> MakeGetAllLatestPaymentsV3Stringly {
        
        return { parameters, completion in
            
            let fetch = ForaBank.NanoServices.adaptedLoggingFetch(
                createRequest: { try RequestFactory.createGetAllLatestPaymentsV3Request(parameters: parameters) },
                httpClient: httpClient,
                mapResponse: RemoteServices.ResponseMapper.mapGetAllLatestPaymentsResponse(_:_:),
                mapOutput: { $0 },
                mapError: { $0 },
                log: { log(.info, .network, $0, $1, $2) }
            )
            
            fetch { [fetch] in
                
                completion($0.mapError { $0 })
                _ = fetch
            }
        }
    }
    
    static func getLatestPayments(
        categories: [ServiceCategory],
        completion: @escaping GetAllLatestPaymentsCompletion
    ) {
        #warning("replace stub with implementation")
        DispatchQueue.global(qos: .userInitiated).delay(for: .seconds(2)) {
            
            completion(.success([]))
        }
    }
    
    static func getLatestPayments(
        category: ServiceCategory,
        completion: @escaping GetAllLatestPaymentsCompletion
    ) {
        getLatestPayments(categories: [category], completion: completion)
    }
    
    // MARK: - Stringly API
    // see deprecation warnings for details
    
    @available(*, deprecated, message: "Use `static NanoServices.getLatestPayments(categories:completion:)` with strong API after hard-code for `isOutsidePayments` and `isPhonePayments` deprecation")
    static func getLatestPayments(
        categoryNames: [String],
        completion: @escaping GetAllLatestPaymentsCompletion
    ) {
        #warning("replace stub with implementation")
        DispatchQueue.global(qos: .userInitiated).delay(for: .seconds(2)) {
            
            completion(.success([]))
        }
    }
    
    @available(*, deprecated, message: "Use `static NanoServices.getLatestPayments(category:completion:)` with strong API after hard-code for `isOutsidePayments` and `isPhonePayments` deprecation")
    static func getLatestPayments(
        categoryName category: String,
        completion: @escaping GetAllLatestPaymentsCompletion
    ) {
        getLatestPayments(categoryNames: [category], completion: completion)
    }
}
