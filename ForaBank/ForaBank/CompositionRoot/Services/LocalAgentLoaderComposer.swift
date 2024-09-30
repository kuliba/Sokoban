//
//  LocalAgentLoaderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

import CombineSchedulers
import Foundation

final class LocalAgentLoaderComposer<LoadPayload, Model, Value> {
    
    private let fromModel: (Model) -> Value
    private let toModel: (Value) -> Model
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        fromModel: @escaping (Model) -> Value,
        toModel: @escaping (Value) -> Model,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.fromModel = fromModel
        self.toModel = toModel
        self.interactiveScheduler = interactiveScheduler
        self.backgroundScheduler = backgroundScheduler
    }
}

extension LocalAgentLoaderComposer {
    
    func compose(
        load: @escaping (LoadPayload) -> Model?,
        save: @escaping (Model) throws -> Void
    ) -> Loader {
        
        return .init(
            load: { payload, completion in
                
                self.interactiveScheduler.schedule {
                    
                    completion(load(payload).map(self.fromModel))
                }
            },
            save: { value, completion in
                
                self.backgroundScheduler.schedule {
                    
                    completion(.init(catching: {
                        
                        try save(self.toModel(value))
                    }))
                }
            }
        )
    }
    
    typealias Loader = LocalAgentLoader<LoadPayload, Value>
}
