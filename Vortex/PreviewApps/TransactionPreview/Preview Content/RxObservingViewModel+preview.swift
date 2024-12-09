//
//  RxObservingViewModel+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

import RxViewModel

extension RxObservingViewModel
where State == Selector<String>,
      Event == SelectorEvent<String>,
      Effect == Never {
    
    static func preview(
        initialState: Selector<String> = .preview
    ) -> Self {
        
        .init(
            observable: .preview(initialState: initialState),
            observe: { _,_ in }
        )
    }
}
