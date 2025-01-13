//
//  PhoneValidator.swift
//  
//
//  Created by Igor Malyarov on 26.04.2023.
//

import TextFieldComponent

struct PhoneValidator: Validator {
    
    init() {}
    
    func isValid(_ input: String) -> Bool {
        
        PhoneNumberKitWrapper.isValidPhoneNumber(input)
    }
}
