//
//  ErrorView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import SwiftUI

public struct ErrorView: View {
    
    typealias Config = ErrorConfig
    
    let config: Config
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
            ZStack {
                
                Circle()
                    .foregroundColor(config.backgroundIcon)
                    .frame(width: 64, height: 64)
                
                config.icon
                    .renderingMode(.template)
                    .foregroundColor(config.iconForeground)
            }

            config.title.text(withConfig: config.titleConfig)
        }
    }
}

#Preview {
    
    ErrorView(
        config: .init(
            title: "Мы не смогли загрузить данные.\nПопробуйте позже.",
            titleConfig: .init(textFont: .body, textColor: .red),
            icon: .init(systemName: "slider.horizontal.2.square"),
            iconForeground: .black,
            backgroundIcon: .red
        )
    )
}
