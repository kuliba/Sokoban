//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import CombineSchedulers
import Foundation

final class RootViewModelFactory {
    
    // TODO: - hide properties, provide methods to use in extensions
    
    let model: Model
    let httpClient: HTTPClient
    let logger: LoggerAgentProtocol
    
    let mainScheduler: AnySchedulerOf<DispatchQueue>
    let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    let backgroundScheduler: AnySchedulerOf<DispatchQueue>
    
    // reusable components & factories
    let asyncLocalAgent: LocalAgentAsyncWrapper
    let batchServiceComposer: SerialCachingRemoteBatchServiceComposer
    let loggingSerialLoaderComposer: LoggingSerialLoaderComposer
    let nanoServiceComposer: LoggingRemoteNanoServiceComposer
    
    init(
        model: Model,
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main,
        interactiveScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInteractive),
        backgroundScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInitiated)
    ) {
        self.model = model
        self.httpClient = httpClient
        self.logger = logger
        self.mainScheduler = mainScheduler
        self.interactiveScheduler = interactiveScheduler
        self.backgroundScheduler = backgroundScheduler
        
        // reusable components & factories
        
        // TODO: let errorErasedNanoServiceComposer: RemoteNanoServiceFactory = LoggingRemoteNanoServiceComposer...
        let nanoServiceComposer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClient,
            logger: logger
        )
        
        self.asyncLocalAgent = .init(
            agent: model.localAgent,
            interactiveScheduler: interactiveScheduler,
            backgroundScheduler: backgroundScheduler
        )
        
        self.batchServiceComposer = .init(
            nanoServiceFactory: nanoServiceComposer,
            updateMaker: asyncLocalAgent
        )
        
        self.loggingSerialLoaderComposer = .init(
            httpClient: httpClient,
            localAgent: model.localAgent,
            logger: logger
        )
        
        self.nanoServiceComposer = nanoServiceComposer
    }
}
