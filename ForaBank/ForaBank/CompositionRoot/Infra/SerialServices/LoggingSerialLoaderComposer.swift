//
//  LoggingSerialLoaderComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 16.10.2024.
//

import ForaTools
import Foundation
import SerialComponents

final class LoggingSerialLoaderComposer {
    
    private let httpClient: any HTTPClient
    private let localAgent: any LocalAgentProtocol
    private let logger: any LoggerAgentProtocol
    
    init(
        httpClient: any HTTPClient,
        localAgent: any LocalAgentProtocol,
        logger: any LoggerAgentProtocol
    ) {
        self.httpClient = httpClient
        self.localAgent = localAgent
        self.logger = logger
    }
}

extension LoggingSerialLoaderComposer {
    
    typealias Serial = String
    typealias StampedResult<T> = Result<SerialStamped<String, [T]>, Error>
    
    func compose<T, Model: Codable>(
        createRequest: @escaping (Serial?) throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> StampedResult<T>,
        fromModel: @escaping (Model) -> T,
        toModel: @escaping (T) -> Model
    ) -> (load: Load<T>, reload: Load<T>) {
        
        let nanoServiceComposer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClient,
            logger: logger
        )
        
        let composer = SerialComponents.SerialLoaderComposer(
            localAgent: localAgent,
            remoteLoad: nanoServiceComposer.compose(
                createRequest: createRequest,
                mapResponse: mapResponse
            ),
            fromModel: fromModel,
            toModel: toModel
        )
        
        return composer.compose()
    }
}
