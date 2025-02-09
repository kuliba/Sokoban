//
//  CardTypeView.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

import SwiftUI
import SharedConfigs

struct CardTypeView<IconView>: View
where IconView: View {
    
    let select: CardType
    let config: CardTypeViewConfig
    let makeIconView: (String) -> IconView
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            makeIconView(select.icon)
                .frame(width: 32, height: 32, alignment: .center)
            
            VStack(alignment: .leading) {
                
                config.subtitle.render()
                select.title.text(withConfig: config.title)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    
    CardTypeView(select: .preview, config: .preview) { _ in
        
        Image.percent
    }
}

private extension CardType {
    
    static let preview: Self = .init(icon: "", title: "Digital")
}


private extension CardTypeViewConfig {
    
    static let preview: Self = .init(
        title: .init(textFont: .title3, textColor: .green),
        subtitle: .init(
            text: "Select type",
            config: .init(
                textFont: .footnote,
                textColor: .pink
            )
        )
    )
}

