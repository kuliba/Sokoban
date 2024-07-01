//
//  FooterViewModel+ext.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import Foundation
import TextFieldComponent
import TextFieldModel

public extension FooterViewModel {
    
    convenience init(
        initialState: State,
        currencySymbol: String,
        locale: Locale = .autoupdatingCurrent,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        let formatter = DecimalFormatter(
            currencySymbol: currencySymbol,
            locale: locale
        )
        let textField = DecimalTextFieldViewModel.decimal(
            formatter: formatter,
            scheduler: scheduler
        )
        let reducer = FooterReducer()
        
        self.init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            format: formatter.format(_:),
            getDecimal: formatter.getDecimal(_:),
            textFieldModel: textField,
            scheduler: scheduler
        )
    }
}
