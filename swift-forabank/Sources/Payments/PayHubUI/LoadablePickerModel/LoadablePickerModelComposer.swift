//
//  LoadablePickerModelComposer.swift
//
//
//  Created by Igor Malyarov on 20.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub

public final class LoadablePickerModelComposer<Item> {
    
    private let load: Load
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        load: @escaping Load,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.load = load
        self.scheduler = scheduler
    }
    
    public typealias LoadCompletion = ([Item]) -> Void
    public typealias Load = (@escaping LoadCompletion) -> Void
}

public extension LoadablePickerModelComposer {
    
    func compose(
        prefix: [LoadablePickerState<UUID, Item>.Item],
        suffix: [LoadablePickerState<UUID, Item>.Item],
        placeholderCount: Int
    ) -> LoadablePickerModel<Item> {
        
        let placeholderIDs = (0..<placeholderCount).map { _ in UUID() }
        let reducer = LoadablePickerReducer<UUID, Item>(
            makeID: UUID.init,
            makePlaceholders: { placeholderIDs }
        )
        let effectHandler = LoadablePickerEffectHandler<Item>(
            microServices: .init(load: load)
        )
        
        return .init(
            initialState: .init(prefix: prefix, suffix: suffix),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
