//
//  NanoServices+initiateAnywayPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.08.2024.
//

import AnywayPaymentBackend
import CombineSchedulers
import Foundation
import RemoteServices
import GenericRemoteService

extension NanoServices {
    
    typealias Puref = String
    typealias MakeInitiateAnywayPayment = (Puref, @escaping CreateAnywayTransferCompletion) -> Void
    
    static func initiateAnywayPayment(
        flag: StubbedFeatureFlag.Option,
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> MakeInitiateAnywayPayment {
        
        switch flag {
        case .live:
            let createTransfer = makeCreateAnywayTransferNewV2(httpClient, log, file: file, line: line)
            
            return {
                
                createTransfer(.init(additional: [], check: true, puref: $0), $1)
            }
            
        case .stub:
            return { puref, completion in
                
                scheduler.delay(for: .seconds(1)) {
                    
                    completion(.failure(.connectivityError))
                }
            }
        }
    }
}
