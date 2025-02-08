//
//  SwiftUIView 3.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

import SwiftUI
import SharedConfigs

struct SelectConfig {
    
    let title: TextConfig
    let select: TextConfig
    let icon: Image
}

struct SelectView: View {
    
    let title: String
    let select: String
    let config: SelectConfig
    
    var body: some View {
        
        cardTypeView(title: title)
    }
    
    private func cardTypeView(
        title: String
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            title.text(withConfig: config.title)
        }
    }
    
    private func selectView(
        title: String
    ) -> some View {
        
        HStack(spacing: 12) {
            
            config.icon
                .resizable()
                .frame(width: 32, height: 32, alignment: .center)
            
            cardTypeView(title: title)
        }
    }
}

#Preview {
    
    SelectView(
        title: "Тип носителя",
        select: "Цифровая",
        config: .init(
            title: .init(textFont: .title, textColor: .blue),
            select: .init(textFont: .body, textColor: .red),
            icon: Image("transport")
        )
    )
}
