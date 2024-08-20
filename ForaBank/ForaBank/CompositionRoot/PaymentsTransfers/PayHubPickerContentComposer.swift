//
//  PayHubPickerContentComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

final class PayHubPickerContentComposer {
    
    private let load: Load
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        load: @escaping Load,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.load = load
        self.scheduler = scheduler
    }
    
    typealias Item = PayHubPickerItem<Latest>
    typealias LoadResult = Result<[Item], Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
}

extension PayHubPickerContentComposer {
    
    func compose(
        prefix: [PayHubPickerState.Item],
        suffix: [PayHubPickerState.Item],
        placeholderCount: Int
    ) -> PayHubPickerContent {
        
        let placeholderIDs = (0..<placeholderCount).map { _ in UUID() }
        let reducer = PayHubPickerReducer(
            makeID: UUID.init,
            makePlaceholders: { placeholderIDs }
        )
        let effectHandler = PayHubPickerEffectHandler(
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
