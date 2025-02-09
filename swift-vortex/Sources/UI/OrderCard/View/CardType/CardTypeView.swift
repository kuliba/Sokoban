//
//  CardTypeView.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

import SwiftUI
import SharedConfigs

struct CardTypeView: View {
    
    let select: CardType
    let config: CardTypeViewConfig
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            ZStack(alignment: .center) {
                
                Circle()
                    .foregroundColor(config.backgroundColorIcon)
                    .frame(width: 32, height: 32, alignment: .center)
                
                config.icon
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 19, height: 19)
            }
            
            VStack(alignment: .leading) {
                
                config.subtitle.render()
                select.title.text(withConfig: config.title)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    
    CardTypeView(select: .preview, config: .preview)
}

private extension CardType {
    
    static let preview: Self = .init(title: "Digital")
}


private extension CardTypeViewConfig {
    
    static let preview: Self = .init(
        backgroundColorIcon: .red,
        icon: .bolt,
        subtitle: .init(
            text: "Select type",
            config: .init(
                textFont: .footnote,
                textColor: .pink
            )
        ),
        title: .init(
            textFont: .title3,
            textColor: .green
        )
    )
}

