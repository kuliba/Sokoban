//
//  ModelHTTPClientFactory+shared.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2024.
//

extension ModelHTTPClientFactory {
    
    static let shared: ModelHTTPClientFactory = .init(
        logger: LoggerAgent.shared,
        model: Model.shared
    )
}
