//
//  LatestPlaceholder.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

struct LatestPlaceholder: View {
    
    var opacity: Double
    let config: LatestPlaceholderConfig
    
    var body: some View {
        
        VStack(spacing: config.spacing) {
            
            placeholder
                .clipShape(Circle())
                .frame(width: config.circleSize, height: config.circleSize)
            
            VStack(spacing: config.textSpacing) {
                
                placeholder
                    .clipShape(Capsule(style: .continuous))
                    .frame(width: config.circleSize, height: config.textHeight)
                
                placeholder
                    .clipShape(Capsule(style: .continuous))
                    .frame(width: config.textWidth, height: config.textHeight)
            }
        }
        .frame(config.frame)
    }
    
    private var placeholder: some View {
        
        PlaceholderView(opacity: opacity)
    }
}

struct LatestPlaceholder_Previews: PreviewProvider {
    
    static var previews: some View {
        
        HStack(spacing: 4) {
            
            latestPlaceholder(opacity: 1)
            latestPlaceholder(opacity: 0.2)
            
            Group {
                
                latestPlaceholder(opacity: 1)
                latestPlaceholder(opacity: 0.2)
            }
            ._shimmering()
        }
    }
    
    private static func latestPlaceholder(
        opacity: Double
    ) -> some View {
        
        LatestPlaceholder(opacity: opacity, config: .preview)
    }
}

extension LatestPlaceholderConfig {
    
    static let preview: Self = .init(
        circleSize: 56,
        frame: .init(width: 80, height: 96),
        spacing: 8,
        textHeight: 8,
        textSpacing: 4,
        textWidth: 48
    )
}
