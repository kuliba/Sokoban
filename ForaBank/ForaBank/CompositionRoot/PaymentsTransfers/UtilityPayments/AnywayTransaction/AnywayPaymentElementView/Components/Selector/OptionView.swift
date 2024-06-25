//
//  OptionView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct OptionView: View {
    
    let option: Option
    
    var body: some View {
        
        Text(option.value)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
    }
}

extension OptionView {
    
    typealias Option = AnywayPaymentDomain.AnywayElement.UIComponent.Parameter.ParameterType.Option
}
