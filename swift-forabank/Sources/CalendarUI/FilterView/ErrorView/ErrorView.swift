//
//  ErrorView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import SwiftUI

public struct ErrorView: View {
    
    typealias Config = ErrorConfig
    
    let icon: () -> Image
    let config: Config
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
            icon()
            
            config.title.text(withConfig: config.titleConfig)
        }
    }
}

#Preview {
    
    ErrorView(
        icon: {
            return .init(systemName: "slider.horizontal.2.square")
        },
        config: .init(
            title: "Ошибка",
            titleConfig: .init(
                textFont: .body,
                textColor: .red
            )
        )
    )
}
