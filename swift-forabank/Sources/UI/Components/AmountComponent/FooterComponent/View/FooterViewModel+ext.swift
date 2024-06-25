//
//  FooterViewModel+ext.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import TextFieldComponent
import TextFieldModel

public extension FooterViewModel {
    
    convenience init(
        currencySymbol: String,
        initialState: State,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        let formatter = DecimalFormatter(
            currencySymbol: currencySymbol
        )
        let textField = DecimalTextFieldViewModel.decimal(
            formatter: formatter,
            scheduler: scheduler
        )
        let reducer = FooterReducer()
        
        self.init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            formatter: formatter,
            textFieldModel: textField,
            scheduler: scheduler
        )
    }
}
