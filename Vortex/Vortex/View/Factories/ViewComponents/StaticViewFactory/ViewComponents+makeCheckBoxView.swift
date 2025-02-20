//
//  ViewComponents+makeCheckBoxView.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import SwiftUI

extension ViewComponents {
    
    // TODO: - add/extract config
    @inlinable
    func makeCheckBoxView(
        title: AttributedString,
        isChecked: Bool,
        toggle: @escaping () -> Void
    ) -> some View {
        
        HStack {
            
            PaymentsCheckView.CheckBoxView(
                isChecked: isChecked,
                activeColor: .systemColorActive
            )
            .onTapGesture(perform: toggle)
            
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.textBodyMR14200())
                .foregroundColor(.textPlaceholder)
        }
        .animation(.easeInOut, value: isChecked)
    }
}
