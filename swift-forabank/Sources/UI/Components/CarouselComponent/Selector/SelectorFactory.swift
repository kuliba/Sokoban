//
//  SelectorFactory.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import SwiftUI
import RxViewModel

public typealias SelectorViewModel = RxViewModel<SelectorState, SelectorEvent, SelectorEffect>

final public class SelectorFactory {
    
    private let scheduler: AnySchedulerOfDispatchQueue
    
    init(
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.scheduler = scheduler
    }
}

public extension SelectorFactory {
    
    func makeViewModel() -> SelectorViewModel {
        
        let reducer = SelectorReducer()
        let effectHandler = SelectorEffectHandler()
        
        return SelectorViewModel(
            initialState: .initial(.init()),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

