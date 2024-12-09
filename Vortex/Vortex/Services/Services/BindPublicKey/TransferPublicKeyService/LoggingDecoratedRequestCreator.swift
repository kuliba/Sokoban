//
//  LoggingDecoratedRequestCreator.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.09.2023.
//

import GenericRemoteService
import Foundation

struct LoggingDecoratedRequestCreator<Input> {
    
    typealias CreateRequest = (Input) throws -> URLRequest
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
    
    let createRequest: CreateRequest
    
    init(
        log: @escaping Log,
        decoratee: @escaping CreateRequest,
        file: StaticString = #file, line: UInt = #line
    ) {
        self.createRequest = { payload in
            
            log(.debug, .network, "Asked to create request with payload: \"\(payload)\"", file, line)
            let request = try decoratee(payload)
            log(.debug, .network, "Created request \"\(request)\"", file, line)
            
            return request
        }
    }
}
