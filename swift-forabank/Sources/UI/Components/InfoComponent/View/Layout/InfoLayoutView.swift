//
//  InfoLayoutView.swift
//
//
//  Created by Igor Malyarov on 22.05.2024.
//

import SwiftUI

struct InfoLayoutView<Icon: View>: View {
    
    let info: LayoutInfo
    let config: InfoConfig
    let icon: () -> Icon
    
    var body: some View {
        
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

private extension LayoutInfo {
    
    var size: CGSize {
        
        switch id {
        case .amount:
            return .init(width: 24, height: 24)
            
        case .brandName, .recipientBank:
            return .init(width: 32, height: 32)
        }
    }
}

// MARK: - Previews

#Preview {
    
    VStack(spacing: 32) {
        
        InfoView(info: .amount, config: .preview)
        InfoView(info: .brandName, config: .preview)
        InfoView(info: .recipientBank, config: .preview)
    }
    .previewLayout(.sizeThatFits)
}
