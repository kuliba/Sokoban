//
//  SwiftUIView 3.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

import SwiftUI
import SharedConfigs

struct SelectView<IconView>: View
where IconView: View {
    
    let select: CardType
    let config: SelectViewConfig
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
    
    SelectView(select: .preview, config: .preview) { _ in
        
        Image.percent
    }
}

private extension CardType {
    
    static let preview: Self = .init(icon: "", title: "Digital")
}


private extension SelectViewConfig {
    
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

