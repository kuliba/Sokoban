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
    let title: String
    let config: Config
    
    public var body: some View {
        
        HStack {
            
            Spacer()
            
            VStack(spacing: 24) {
                
                Spacer()
                
                icon()
                
                config.title.text(withConfig: config.titleConfig)
                
                Spacer()
            }
            
            Spacer()
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
