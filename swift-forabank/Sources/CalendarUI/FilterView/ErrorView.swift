//
//  ErrorView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

public struct ErrorView: View {
    
    let icon: () -> Image
    let config: Config
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
            icon()
            
            config.title.text(withConfig: config.titleConfig)
        }
    }
}

public extension ErrorView {
    
    struct Config {
        
        let title: String
        public let titleConfig: TextConfig
        
        public init(
            title: String,
            titleConfig: TextConfig
        ) {
            self.title = title
            self.titleConfig = titleConfig
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
