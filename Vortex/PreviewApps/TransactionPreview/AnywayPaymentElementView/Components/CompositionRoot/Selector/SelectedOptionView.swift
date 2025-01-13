//
//  SelectedOptionView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct SelectedOptionView: View {
    
    let option: Option
    
    var body: some View {
        
        Text(option.value.rawValue)
            .bold()
    }
}

extension SelectedOptionView {
    
    typealias Option = AnywayElement.UIComponent.Parameter.ParameterType.Option
}
