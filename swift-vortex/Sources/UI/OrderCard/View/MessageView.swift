//
//  SwiftUIView 2.swift
//  
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

import SwiftUI

struct MessageView: View {
    
    let icon: Image
    let title: String
    let subtitle: String
    let description: String
    
    var body: some View {
        
        messageView()
    }
    
    private func messageView(
    ) -> some View {
        
        HStack(alignment: .top, spacing: 16) {
            
            icon
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundStyle(.gray)
            
            VStack(alignment: .leading, spacing: 6) {
                
                infoWithToggle()
                
                Text(description)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private func infoWithToggle() -> some View {
        
        HStack(spacing: 16) {
            
            VStack(spacing: 6) {
                
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(subtitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
//            Toggle("", isOn: $isShowingProducts)
//                .toggleStyle(TopUpToggleStyle(config: config.topUp.toggle))
        }
    }
}

#Preview {
    
    MessageView(
        icon: .bolt,
        title: "Информирование",
        subtitle: "Пуш/смс расширенные",
        description: "Присылаем пуш-уведомления по операциям, если не доходят - отправляем смс. С тарифами за услугу согласен."
    )
}
