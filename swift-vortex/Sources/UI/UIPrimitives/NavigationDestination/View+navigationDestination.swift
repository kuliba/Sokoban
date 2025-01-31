//
//  View+navigationDestination.swift
//
//
//  Created by Andryusina Nataly on 15.09.2023.
//

import SwiftUI

/// Extending SwiftUI API
public extension View {
    
    /// Presents a navigation destination for an `Identifiable` item while ensuring duplicate updates are ignored.
    ///
    /// This variant of `navigationDestination` prevents unnecessary UI updates by deduplicating the bound item
    /// based on its `id` before triggering the navigation.
    ///
    /// - Parameters:
    ///   - titleKey: A localized string key for the navigation title. Defaults to an empty string.
    ///   - item: A binding to an optional `Identifiable` item that determines when the destination should be presented.
    ///   - content: A closure that returns the destination view for the given item.
    @inlinable
    func navigationDestination<Item: Identifiable, Content: View>(
        _ titleKey: LocalizedStringKey = "",
        deduplicated item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        
        navigationDestination(
            titleKey,
            item: item.removingDuplicates(),
            content: content
        )
    }
    
    /// Presents a navigation destination for an `Identifiable` item with a custom deduplication strategy.
    ///
    /// This variant of `navigationDestination` prevents redundant updates by applying a custom comparison
    /// closure to determine whether the new value is a duplicate of the existing one.
    ///
    /// - Parameters:
    ///   - titleKey: A localized string key for the navigation title. Defaults to an empty string.
    ///   - item: A binding to an optional `Identifiable` item that determines when the destination should be presented.
    ///   - isDuplicate: A closure that takes two `Item?` values and returns `true` if the update should be ignored.
    ///   - content: A closure that returns the destination view for the given item.
    @inlinable
    func navigationDestination<Item: Identifiable, Content: View>(
        _ titleKey: LocalizedStringKey = "",
        item: Binding<Item?>,
        removingDuplicatesBy isDuplicate: @escaping (Item?, Item?) -> Bool,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        
        navigationDestination(
            titleKey,
            item: item.removingDuplicates(by: isDuplicate),
            content: content
        )
    }
    
    @inlinable
    func navigationDestination<Item: Identifiable, Content: View>(
        _ titleKey: LocalizedStringKey = "",
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        
        self.background(
            NavigationLink(
                titleKey,
                isActive: .init(
                    get: { item.wrappedValue != nil },
                    set: { if !$0 { item.wrappedValue = nil }}
                ),
                destination: {
                    item.wrappedValue.map(content)
                }
            )
        )
    }
    
    /// Alert setter is managed by action in alert content
    @inlinable
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
    
    @inlinable
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
    @inlinable
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
    
    /// Presents a navigation destination for an `Identifiable` item while ensuring duplicate updates are ignored.
    ///
    /// This variant of `navigationDestination` accepts a non-binding `Identifiable` destination and provides a closure
    /// to handle dismissal when the destination is set to `nil`. It ensures duplicate updates are ignored by deduplicating
    /// the destination before triggering the navigation.
    ///
    /// - Parameters:
    ///   - destination: An optional `Identifiable` item that determines when the destination should be presented.
    ///   - dismiss: A closure that is called when the destination is set to `nil`, typically used to handle dismissal.
    ///   - content: A closure that returns the destination view for the given item.
    @inlinable
    func navigationDestination<Destination: Identifiable, Content: View>(
        deduplicated destination: Destination?,
        dismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping (Destination) -> Content
    ) -> some View {
        
        navigationDestination(
            deduplicated: .init(
                get: { destination },
                set: { if $0 == nil { dismiss() }}
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
