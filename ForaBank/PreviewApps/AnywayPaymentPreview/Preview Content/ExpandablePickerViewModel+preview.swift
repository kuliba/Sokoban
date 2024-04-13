//
//  ExpandablePickerViewModel+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

extension ExpandablePickerViewModel {
    
    static var preview: ExpandablePickerViewModel<String> {
        
        let reducer = ExpandablePickerReducer<String>()
        
        return .init(
            initialState: .preview,
            reduce: reducer.reduce,
            handleEffect: { _,_ in }
        )
    }
}
