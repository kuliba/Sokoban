//
//  View+header.swift
//
//
//  Created by Igor Malyarov on 30.03.2025.
//

import SwiftUI

public extension View {
    
    /// Adds a header view to the top safe area of the view using the specified header model, configuration, and back button action.
    func header(
        header: Header,
        config: HeaderViewConfig,
        action: @escaping () -> Void
    ) -> some View {
        
        safeAreaInset(edge: .top) {
            
            HeaderView(header: header, action: action, config: config)
        }
    }
    
    /// Adds a header view to the top safe area of the view using the provided title, optional subtitle, configuration, and back button action.
    func header(
        title: String,
        subtitle: String?,
        config: HeaderViewConfig,
        action: @escaping () -> Void
    ) -> some View {
        
        safeAreaInset(edge: .top) {
            
            HeaderView(
                title: title,
                subtitle: subtitle,
                action: action,
                config: config
            )
        }
    }
}
