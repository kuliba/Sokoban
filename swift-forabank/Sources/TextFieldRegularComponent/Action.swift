//
//  Action.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import Foundation

extension TextFieldRegularView.ViewModel {

    enum Action {
        
        case textViewDidBeginEditing, textViewDidEndEditing
        case shouldChangeTextIn(NSRange, String)
        case setTextTo(String?)
    }
}
