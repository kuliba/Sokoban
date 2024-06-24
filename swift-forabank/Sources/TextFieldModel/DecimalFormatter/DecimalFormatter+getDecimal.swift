//
//  DecimalFormatter+getDecimal.swift
//  
//
//  Created by Igor Malyarov on 16.12.2023.
//

import Foundation
import TextFieldDomain

public extension DecimalFormatter {
    
    func getDecimal(_ textFieldState: TextFieldState) -> Decimal {
        
        switch textFieldState {
        case .placeholder:
            return 0

        case let .noFocus(text):
            return number(from: text)
            
        case let .editing(textState):
            return number(from: textState.text)
        }
    }
}
