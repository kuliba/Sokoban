//
//  NanoServices+startAnywayPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.05.2024.
//

import Fetcher
import Foundation
import RemoteServices

extension NanoServices {
    
    static func startAnywayPayment(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> StartAnywayPayment {
        #warning("move into startAnywayPaymentLive?")
        let createAnywayTransferNew = NanoServices.makeCreateAnywayTransferNew(httpClient, log)
        let adapted = FetchAdapter(
            fetch: createAnywayTransferNew,
            mapResult: StartAnywayPaymentResult.init(result:)
        )
        let mapped = MapPayloadDecorator(
            decoratee: adapted.fetch,
            mapPayload: RemoteServices.RequestFactory.CreateAnywayTransferPayload.init
        )
        
//        return { mapped($0, completion: $1) }
        
        #warning("return shorter form")
        return { payload, completion in
            
            mapped(payload) { result in
            
                completion(result)
            }
        }
    }
    
}

typealias StartAnywayPayment = _UtilityPaymentNanoServices.StartAnywayPayment
typealias StartAnywayPaymentPayload = _UtilityPaymentNanoServices.StartAnywayPaymentPayload
typealias StartAnywayPaymentResult = _UtilityPaymentNanoServices.StartAnywayPaymentResult

typealias _UtilityPaymentNanoServices = UtilityPaymentNanoServices<UtilityPaymentLastPayment, UtilityPaymentOperator>

// MARK: - Adapters

private extension RemoteServices.RequestFactory.CreateAnywayTransferPayload {
    
    init(_ payload: StartAnywayPaymentPayload) {
        
        /// - Note: `check` is optional
        /// Признак проверки операции:
        /// - если `check="true"`, то OTP не отправляется,
        /// - если `check="false"` - OTP отправляется
        self.init(additional: [], check: true, puref: payload.puref)
    }
}

private extension StartAnywayPaymentPayload {
    
#warning("fix me")
    var puref: String {
        
     //   "iFora||MOO2" // one sum
        "iFora||7602" // mutli sum
        
//        switch self {
//        case let .lastPayment(lastPayment):
//            return lastPayment.puref
//
//        case let .operator(`operator`):
//            return `operator`.puref
//
//        case let .service(utilityService, _):
//            return utilityService.puref
//        }
    }
}

private extension StartAnywayPaymentResult {
    
    init(result: NanoServices.CreateAnywayTransferResult) {
        
        switch result {
        case let .failure(serviceFailure):
            switch serviceFailure {
            case .connectivityError:
                self = .failure(.serviceFailure(.connectivityError))
                
            case let .serverError(message):
                self = .failure(.serviceFailure(.serverError(message)))
            }
            
        case let .success(response):
#warning("use response")
            self = .success(.startPayment(.init()))
        }
    }
}
