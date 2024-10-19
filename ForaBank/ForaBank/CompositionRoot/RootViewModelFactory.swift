//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import Foundation

final class RootViewModelFactory {
    
    let model: Model
    let httpClient: HTTPClient
    let logger: LoggerAgentProtocol
    
    init(
        model: Model, 
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol
    ) {
        self.model = model
        self.httpClient = httpClient
        self.logger = logger
    }
}
