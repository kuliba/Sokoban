//
//  LoadablePickerContentComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI
import RxViewModel

typealias LoadablePickerContent<Item> = RxViewModel<LoadablePickerState<UUID, Item>, LoadablePickerEvent<Item>, LoadablePickerEffect>

final class LoadablePickerContentComposer<Item> {
    
    private let load: Load
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        load: @escaping Load,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.load = load
        self.scheduler = scheduler
    }
    
    typealias LoadCompletion = ([Item]) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
}

extension LoadablePickerContentComposer {
    
    func compose(
        prefix: [LoadablePickerState<UUID, Item>.Item],
        suffix: [LoadablePickerState<UUID, Item>.Item],
        placeholderCount: Int
    ) -> LoadablePickerContent<Item> {
        
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
