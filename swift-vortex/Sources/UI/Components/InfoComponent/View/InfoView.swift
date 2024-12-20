//
//  InfoView.swift
//
//
//  Created by Igor Malyarov on 22.05.2024.
//

import SwiftUI

public struct InfoView<Icon: View>: View {
    
    let info: Info
    let config: InfoConfig
    let icon: () -> Icon
    
    public init(
        info: Info,
        config: InfoConfig,
        icon: @escaping () -> Icon
    ) {
        self.info = info
        self.config = config
        self.icon = icon
    }
    
    public var body: some View {
        
        HStack(spacing: 12) {
            
            icon()
                .frame(info.size)
                .frame(width: 32, height: 32)
            
            switch info.style {
            case .expanded:
                VStack(alignment: .leading, spacing: 4) {
                    
                    info.title.text(withConfig: config.title)
                    info.value.text(withConfig: config.value)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            case .compressed:
                HStack {
                    
                    info.title.text(withConfig: config.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    info.value.text(withConfig: config.value)
                }
            }
        }
    }
}

private extension Info {
    
    var size: CGSize {
        
        switch id {
        case .amount:
            return .init(width: 24, height: 24)
            
        case .brandName, .recipientBank, .other:
            return .init(width: 32, height: 32)
        }
    }
}

// MARK: - Previews

#Preview {
    
    VStack(spacing: 32) {
        
        InfoView(info: .amount, config: .preview) { Text("Icon") }
        InfoView(info: .brandName, config: .preview) { Text("Icon") }
        InfoView(info: .recipientBank, config: .preview) { Text("Icon") }
    }
    .previewLayout(.sizeThatFits)
}
