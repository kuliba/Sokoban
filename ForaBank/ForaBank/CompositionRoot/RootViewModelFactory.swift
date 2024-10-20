//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import CombineSchedulers
import Foundation

final class RootViewModelFactory {
    
    let model: Model
    let httpClient: HTTPClient
    let logger: LoggerAgentProtocol
    
    let mainScheduler: AnySchedulerOf<DispatchQueue>
    let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    let backgroundScheduler: AnySchedulerOf<DispatchQueue>
    
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
    }
}
