//
//  NanoServices+initiateAnywayPayment.swift
//  Vortex
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
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
    typealias MakeInitiateAnywayPayment = (Puref, @escaping CreateAnywayTransferCompletion) -> Void
    
    static func initiateAnywayPayment(
        httpClient: HTTPClient,
        log: @escaping Log,
        scheduler: AnySchedulerOf<DispatchQueue>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> MakeInitiateAnywayPayment {
        
        let log = { log(.debug, .network, $0, $1, $2) }
        let createTransfer = makeCreateAnywayTransferNewV2(httpClient, log, file: file, line: line)
        
        return {
            
            createTransfer(.init(additional: [], check: true, puref: $0), $1)
        }
    }
}
