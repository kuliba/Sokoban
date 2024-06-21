//
//  BottomAmountViewModel+ext.swift
//
//
//  Created by Igor Malyarov on 20.06.2024.
//

import TextFieldComponent
import TextFieldModel

public extension BottomAmountViewModel {
    
    convenience init(
        currencySymbol: String,
        initialState: State,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        let formatter = DecimalFormatter(
            currencySymbol: currencySymbol
        )
        let textField = DecimalTextFieldViewModel.decimal(
            formatter: formatter
        )
        let reducer = BottomAmountReducer()
        
        self.init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            formatter: formatter,
            textFieldModel: textField,
            scheduler: scheduler
        )
    }
}
