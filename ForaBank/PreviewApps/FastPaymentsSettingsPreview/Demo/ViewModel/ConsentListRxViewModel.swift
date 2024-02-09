//
//  ConsentListRxViewModel.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

import FastPaymentsSettings
import RxViewModel

typealias ConsentListRxViewModel = RxViewModel<ConsentListState, ConsentListEvent, ConsentListEffect>

extension ConsentListRxViewModel {
    
    static func `default`(
        initialState: State,
        changeConsentList: @escaping ConsentListRxEffectHandler.ChangeConsentList,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> ConsentListRxViewModel {
        
        let reducer = ConsentListRxReducer()
        let effectHandler = ConsentListRxEffectHandler(
            changeConsentList: changeConsentList
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
