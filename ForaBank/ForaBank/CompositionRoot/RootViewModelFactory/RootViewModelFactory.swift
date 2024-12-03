//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import CombineSchedulers
import Foundation
import PayHubUI

final class RootViewModelFactory {
    
    // TODO: - hide properties, provide methods to use in extensions
    
    let model: Model
    let httpClient: HTTPClient
    let logger: LoggerAgentProtocol
    
    let mapScanResult: MapScanResult
    let resolveQR: ResolveQR
    let scanner: any QRScannerViewModel
    
    let settings: RootViewModelFactorySettings
    
    // active flags
    let getProductListByTypeV6Flag: GetProductListByTypeV6Flag = .active
    let historyFilterFlag: HistoryFilterFlag = true
    let updateInfoStatusFlag: UpdateInfoStatusFeatureFlag = .active
    
    let schedulers: Schedulers
    
    // reusable components & factories
    let asyncLocalAgent: LocalAgentAsyncWrapper
    let batchServiceComposer: SerialCachingRemoteBatchServiceComposer
    let loggingSerialLoaderComposer: LoggingSerialLoaderComposer
    let nanoServiceComposer: LoggingRemoteNanoServiceComposer
    
    init(
        model: Model,
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        mapScanResult: @escaping MapScanResult,
        resolveQR: @escaping ResolveQR,
        scanner: any QRScannerViewModel,
        settings: RootViewModelFactorySettings = .prod,
        schedulers: Schedulers
    ) {
        self.model = model
        self.httpClient = httpClient
        self.logger = logger
        self.mapScanResult = mapScanResult
        self.resolveQR = resolveQR
        self.scanner = scanner
        self.settings = settings
        self.schedulers = schedulers
        
        // reusable components & factories
        
        // TODO: let errorErasedNanoServiceComposer: RemoteNanoServiceFactory = LoggingRemoteNanoServiceComposer...
        let nanoServiceComposer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClient,
            logger: logger
        )
        
        self.asyncLocalAgent = .init(
            agent: model.localAgent,
            interactiveScheduler: schedulers.interactive,
            backgroundScheduler: schedulers.background
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
    
    typealias ResolveQR = (String) -> QRViewModel.ScanResult
    typealias MapScanResult = (QRViewModel.ScanResult, @escaping (QRModelResult) -> Void) -> Void
}
