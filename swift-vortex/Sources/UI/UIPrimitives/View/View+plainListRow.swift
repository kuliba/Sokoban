//
//  View+plainListRow.swift
//
//
//  Created by Igor Malyarov on 25.01.2025.
//

import SwiftUI

public extension View {
    
    /// A modifier to simplify creating plain list rows without separators.
    /// - Parameters:
    ///   - spacing: The vertical spacing between rows. Defaults to `0`.
    ///   - insets: The edge insets for the row. Defaults to `.zero`.    @inlinable
    func plainListRow(
        spacing: CGFloat? = 0,
        insets: EdgeInsets = .zero
    ) -> some View {
        
        self
            .listRowSeparator(.hidden)
            .listRowSpacing(spacing)
            .listRowInsets(insets)
    }
}
