//
//  View+ext.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

import SwiftUI

extension View {
    
    func alert<Item: Identifiable>(
        item: Item?,
        content: (Item) -> Alert
    ) -> some View {
        
        alert(
            item: .init(
                get: { item },
                set: { _ in } // managed by action in content
            ),
            content: content
        )
    }
    
    func navigationDestination<Destination: Identifiable, Content: View>(
        destination: Destination?,
        dismissDestination: @escaping () -> Void,
        @ViewBuilder content: @escaping (Destination) -> Content
    ) -> some View {
        
        navigationDestination(
            item: .init(
                get: { destination },
                set: { if $0 == nil { dismissDestination() }}
            ),
            content: content
        )
    }
}

