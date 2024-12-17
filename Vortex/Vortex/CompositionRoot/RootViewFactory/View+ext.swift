//
//  View+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.05.2024.
//

import SwiftUI

/// Extending custom API
extension View {

    func bottomSheet<BottomSheet: BottomSheetCustomizable, Content: View>(
        sheet: BottomSheet?,
        dismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping (BottomSheet) -> Content
    ) -> some View {
        
        bottomSheet(
            item: .init(
                get: { sheet },
                set: { if $0 == nil { dismiss() }}
            ),
            content: content
        )
    }
}
