//
//  SimpleLabel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct SimpleLabel<IconView: View>: View {
    
    let text: String
    let makeIconView: () -> IconView
    
    var body: some View {

        HStack(alignment: .top, spacing: 16) {
            
            makeIconView()
                .foregroundColor(.textTertiary)
                .frame(width: 24, height: 24)
            
            Text(text)
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}
