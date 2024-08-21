//
//  LoadablePickerModelComposer.swift
//
//
//  Created by Igor Malyarov on 20.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub

public final class LoadablePickerModelComposer<ID, Item>
where ID: Hashable {
    
    private let load: Load
    private let makeID: MakeID
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        load: @escaping Load,
        makeID: @escaping MakeID,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.load = load
        self.makeID = makeID
        self.scheduler = scheduler
    }
    
    public typealias LoadCompletion = ([Item]) -> Void
    public typealias Load = (@escaping LoadCompletion) -> Void
    public typealias MakeID = () -> ID
}

public extension LoadablePickerModelComposer {
    
    func compose(
        prefix: [LoadablePickerState<ID, Item>.Item],
        suffix: [LoadablePickerState<ID, Item>.Item],
        placeholderCount: Int
    ) -> LoadablePickerModel<ID, Item> {
        
        let placeholderIDs = (0..<placeholderCount).map { _ in makeID() }
        let reducer = LoadablePickerReducer<ID, Item>(
            makeID: makeID,
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
