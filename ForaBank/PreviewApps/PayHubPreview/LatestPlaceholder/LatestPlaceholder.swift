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
        
        IconWithTitleLabelVertical(
            icon: placeholder,
            title: title,
            config: config.label
        )
    }
    
    private func  placeholder() -> some View {
        
        PlaceholderView(opacity: opacity)
    }
    
    private func title() -> some View {
        
        VStack(spacing: config.textSpacing) {
            
            placeholder()
                .clipShape(Capsule(style: .continuous))
                .frame(width: config.label.circleSize, height: config.textHeight)
            
            placeholder()
                .clipShape(Capsule(style: .continuous))
                .frame(width: config.textWidth, height: config.textHeight)
        }
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
