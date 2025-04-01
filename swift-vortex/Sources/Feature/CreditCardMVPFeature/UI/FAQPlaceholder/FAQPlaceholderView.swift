//
//  FAQPlaceholderView.swift
//
//
//  Created by Igor Malyarov on 31.03.2025.
//

import SwiftUI

public struct FAQPlaceholderView: View {
    
    private let isAnimating: Bool
    private let config: FAQPlaceholderViewConfig
    
    public init(
        isAnimating: Bool,
        config: FAQPlaceholderViewConfig
    ) {
        self.isAnimating = isAnimating
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            ForEach(0..<config.count, id: \.self) { _ in
                
                Color.blue.opacity(0.3)
                    .height(config.item.height)
                    .clipShape(RoundedRectangle(cornerRadius: config.item.cornerRadius))
                    ._shimmering(isActive: isAnimating)
            }
        }
        .padding(config.edges)
        .background(config.background
            ._shimmering(isActive: isAnimating)
        )
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
    }
}

// MARK: - Previews

#Preview {
    
    VStack {
        
        FAQPlaceholderView(isAnimating: false, config: .preview)
        FAQPlaceholderView(isAnimating: true, config: .preview)
    }
    .padding()
}

extension FAQPlaceholderViewConfig {
    
    static let preview: Self = .init(
        background: .green.opacity(0.15), // Blur/Placeholder
        cornerRadius: 12,
        count: 4,
        item: .init(cornerRadius: 90, height: 24),
        edges: .init(top: 12, leading: 16, bottom: 24, trailing: 16),
        spacing: 36
    )
}
