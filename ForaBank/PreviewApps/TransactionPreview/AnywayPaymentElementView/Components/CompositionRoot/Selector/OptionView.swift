//
//  File.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct OptionView: View {
    
    let option: Option
    
    var body: some View {
        
        Text(option.value.rawValue)
    }
}

extension OptionView {
    
    typealias Option = AnywayElement.UIComponent.Parameter.ParameterType.Option
}
