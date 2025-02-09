//
//  SwiftUIView 3.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

import SwiftUI
import SharedConfigs

struct SelectView: View {
    
    let title: String
    let select: String
    let config: SelectConfig
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            config.icon
                .resizable()
                .frame(width: 32, height: 32, alignment: .center)
            
            VStack(alignment: .leading) {
                
                title.text(withConfig: config.title)
                select.text(withConfig: config.select)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    
    SelectView(
        title: "Тип носителя",
        select: "Цифровая",
        config: .init(
            title: .init(textFont: .footnote, textColor: .blue),
            select: .init(textFont: .headline, textColor: .red),
            icon: .bolt
        )
    )
}
