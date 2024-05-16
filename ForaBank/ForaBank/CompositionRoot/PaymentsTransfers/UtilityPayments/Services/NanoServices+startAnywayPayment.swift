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
        
        let createAnywayTransferNew = NanoServices.makeCreateAnywayTransferNew(httpClient, log)
        let adapted = FetchAdapter(
            fetch: createAnywayTransferNew,
            mapResult: StartPaymentResult.init(result:)
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
    
    typealias StartPaymentResult = PrepaymentFlowEffectHandler.StartPaymentResult
    typealias StartAnywayPayment = PrepaymentFlowEffectHandler.StartPayment
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<UtilityPaymentLastPayment, UtilityPaymentOperator, UtilityService>
}

// MARK: - Adapters

private typealias PrepaymentFlowEvent = UtilityPaymentFlowEvent<UtilityPaymentLastPayment, UtilityPaymentOperator, UtilityService>.UtilityPrepaymentFlowEvent

private extension RemoteServices.RequestFactory.CreateAnywayTransferPayload {
    
    init(_ payload: PrepaymentFlowEvent.Select) {
        #warning("check is optional!!!!!!!!!!!!!!!! Признак проверки операции (если check=true, то OTP не отправляется, если check=false - OTP отправляется)")
        self.init(additional: [], check: true, puref: payload.puref)
    }
}

private extension PrepaymentFlowEvent.Select {
    
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

private extension PrepaymentFlowEvent.StartPaymentResult {
    
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
