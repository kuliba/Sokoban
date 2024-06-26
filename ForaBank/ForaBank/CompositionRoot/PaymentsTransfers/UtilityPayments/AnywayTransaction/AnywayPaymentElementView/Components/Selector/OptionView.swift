//
//  OptionView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct OptionView<IconView: View>: View {
    
    let option: Option
    let makeIconView: () -> IconView
    
    var body: some View {

        HStack(alignment: .top, spacing: 16) {
            
            makeIconView()
                .foregroundColor(.textTertiary)
                .frame(width: 24, height: 24)
            
            Text(option.value)
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}

extension OptionView {
    
    typealias Option = AnywayPaymentDomain.AnywayElement.UIComponent.Parameter.ParameterType.Option
}
