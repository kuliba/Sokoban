//
//  View+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.05.2024.
//

import SwiftUI

/// Extending SwiftUI API
extension View {
    
    /// Alert setter is managed by action in alert content
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
    
    @available(*, deprecated, renamed: "fullScreenCover(cover:dismiss:content:)")
    func fullScreenCover<FullScreenCover: Identifiable, Content: View>(
        cover: FullScreenCover?,
        dismissFullScreenCover: @escaping () -> Void,
        @ViewBuilder content: @escaping (FullScreenCover) -> Content
    ) -> some View {
        
        fullScreenCover(
            item: .init(
                get: { cover },
                set: { if $0 == nil { dismissFullScreenCover() }}
            ),
            content: content
        )
    }
    
    func fullScreenCover<FullScreenCover: Identifiable, Content: View>(
        cover: FullScreenCover?,
        dismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping (FullScreenCover) -> Content
    ) -> some View {
        
        fullScreenCover(
            item: .init(
                get: { cover },
                set: { if $0 == nil { dismiss() }}
            ),
            content: content
        )
    }
    
    /// - Warning: Use for cases when cover setter is managed programmatically, not by SwiftUI
    func fullScreenCover<FullScreenCover: Identifiable, Content: View>(
        cover: FullScreenCover?,
        @ViewBuilder content: @escaping (FullScreenCover) -> Content
    ) -> some View {
        
        fullScreenCover(
            item: .init(
                get: { cover },
                set: { _ in } // managed programmatically
            ),
            content: content
        )
    }
    
    @available(*, deprecated, renamed: "navigationDestination(destination:dismiss:content:)")
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
    
    func navigationDestination<Destination: Identifiable, Content: View>(
        destination: Destination?,
        dismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping (Destination) -> Content
    ) -> some View {
        
        navigationDestination(
            item: .init(
                get: { destination },
                set: { if $0 == nil { dismiss() }}
            ),
            content: content
        )
    }
    
    /// - Warning: Use for cases when destination setter is managed programmatically, not by SwiftUI
    func navigationDestination<Destination: Identifiable, Content: View>(
        destination: Destination?,
        @ViewBuilder content: @escaping (Destination) -> Content
    ) -> some View {
        
        navigationDestination(
            item: .init(
                get: { destination },
                set: { _ in } // managed programmatically
            ),
            content: content
        )
    }
    
    @available(*, deprecated, renamed: "sheet(modal:dismiss:content:)")
    func sheet<Modal: Identifiable, Content: View>(
        modal: Modal?,
        dismissModal: @escaping () -> Void,
        @ViewBuilder content: @escaping (Modal) -> Content
    ) -> some View {
        
        sheet(
            item: .init(
                get: { modal },
                set: { if $0 == nil { dismissModal() }}
            ),
            content: content
        )
    }
    
    func sheet<Modal: Identifiable, Content: View>(
        modal: Modal?,
        dismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping (Modal) -> Content
    ) -> some View {
        
        sheet(
            item: .init(
                get: { modal },
                set: { if $0 == nil { dismiss() }}
            ),
            content: content
        )
    }
}

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
