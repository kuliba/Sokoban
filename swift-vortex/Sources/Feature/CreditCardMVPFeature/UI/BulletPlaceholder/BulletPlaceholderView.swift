//
//  BulletPlaceholderView.swift
//
//
//  Created by Igor Malyarov on 31.03.2025.
//

import SwiftUI

public struct BulletPlaceholderView: View {
    
    private let isAnimating: Bool
    private let config: BulletPlaceholderViewConfig
    
    public init(
        isAnimating: Bool,
        config: BulletPlaceholderViewConfig
    ) {
        self.isAnimating = isAnimating
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            ForEach(0..<config.sectionCount, id: \.self, content: sectionView)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(config.leadingPadding)
    }
}

private extension BulletPlaceholderView {
    
    func sectionView(_ ix: UInt) -> some View {
        
        VStack(spacing: config.sectionSpacing) {
            
            ForEach(0..<config.bulletsCount, id: \.self, content: itemView)
        }
    }
    
    func itemView(_ ix: UInt) -> some View {
        
        config.color
            .frame(config.frame)
            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
            ._shimmering(isActive: isAnimating)
    }
}

// MARK: - Previews

#Preview {
    
    VStack(spacing: 48) {
        
        BulletPlaceholderView(isAnimating: false, config: .preview)
        BulletPlaceholderView(isAnimating: true, config: .preview)
    }
}

extension BulletPlaceholderViewConfig {
    
    static let preview: Self = .init(
        bulletsCount: 3,
        color: .green.opacity(0.5), // Blur/Placeholder
        cornerRadius: 90,
        frame: .init(width: 100, height: 8),
        leadingPadding: 16,
        sectionCount: 2,
        sectionSpacing: 12,
        spacing: 32
    )
}
