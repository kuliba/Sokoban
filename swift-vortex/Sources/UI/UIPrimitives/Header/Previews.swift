//
//  Previews.swift
//
//
//  Created by Igor Malyarov on 30.03.2025.
//

import SwiftUI

struct HeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        preview(title: "title", subtitle: "subtitle") {
            Color.blue.opacity(0.3)
        }
        
        preview(title: "title", subtitle: nil) {
            Color.blue.opacity(0.3)
        }
        
        preview(title: "title", subtitle: "subtitle") {
            Color.blue.opacity(0.3).ignoresSafeArea()
        }
        
        preview(title: "title", subtitle: nil) {
            Color.blue.opacity(0.3).ignoresSafeArea()
        }
    }
    
    private static func preview(
        title: String,
        subtitle: String?,
        view: () -> some View
    ) -> some View {
        
        view()
            .header(title: title, subtitle: subtitle, config: .preview, action: { print("back tapped") })
    }
}

private extension HeaderViewConfig {
    
    static let preview: Self = .init(
        backImage: .init(
            image: .init(systemName: "chevron.left"),
            color: .primary,
            frame: .init(width: 24, height: 24)
        ),
        height: 48,
        hPadding: 16,
        title: .init(textFont: .headline, textColor: .primary),
        subtitle: .init(textFont: .subheadline, textColor: .secondary),
        vSpacing: 4
    )
}
