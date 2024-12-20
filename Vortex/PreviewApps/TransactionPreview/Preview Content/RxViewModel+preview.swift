//
//  RxViewModel+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

import RxViewModel

extension RxViewModel
where State == Selector<String>,
      Event == SelectorEvent<String>,
      Effect == Never {
    
    static func preview(
        initialState: Selector<String> = .preview
    ) -> Self {
        
        let reducer = SelectorReducer<String>()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )
    }
}
