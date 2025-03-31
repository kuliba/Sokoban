//
//  ConsentPlaceholderView.swift
//
//
//  Created by Igor Malyarov on 31.03.2025.
//

import SwiftUI

public struct ConsentPlaceholderView: View {
    
    private let isAnimating: Bool
    private let config: ConsentPlaceholderViewConfig
    
    public init(
        isAnimating: Bool,
        config: ConsentPlaceholderViewConfig
    ) {
        self.isAnimating = isAnimating
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            ForEach(0..<config.count, id: \.self, content: itemView)
        }
    }
}

private extension ConsentPlaceholderView {
    
    func itemView(_ ix: UInt) -> some View {
        
        HStack {
            
            config.color
                .clipShape(Circle())
                .frame(config.circleFrame)
            
            config.color
                .height(config.height)
                .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
        }
        .height(config.frameHeight)
        ._shimmering(isActive: isAnimating)
    }
}

// MARK: - Previews

#Preview {
    
    VStack(spacing: 48) {
        
        ConsentPlaceholderView(isAnimating: false, config: .preview(1))
        ConsentPlaceholderView(isAnimating: true, config: .preview(1))
        
        ConsentPlaceholderView(isAnimating: false, config: .preview(2))
        ConsentPlaceholderView(isAnimating: true, config: .preview(2))
    }
    .padding()
}

extension ConsentPlaceholderViewConfig {
    
    static func preview(_ count: UInt) -> Self {
        
        return .init(
            circleFrame: .init(width: 24, height: 24),
            color: .green.opacity(0.5), // Blur/Placeholder
            cornerRadius: 90,
            count: count,
            frameHeight: 36,
            height: 8,
            spacing: 16
        )
    }
}
