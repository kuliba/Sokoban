//
//  TabModel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import RxViewModel

typealias TabModel = RxViewModel<TabState, TabEvent, TabEffect>

extension TabModel
where State == TabState,
      Event == TabEvent,
      Effect == TabEffect {
    
    convenience init(
        initialState: TabState = .noLatest
    ) {
        
        let reducer = TabReducer()
        let effectHandler = TabEffectHandler()
        
        self.init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}
