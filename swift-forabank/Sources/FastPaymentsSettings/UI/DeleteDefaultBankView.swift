//
//  DeleteDefaultBankView.swift
//
//
//  Created by Дмитрий Савушкин on 29.09.2024.
//

import Foundation
import SwiftUI

struct DeleteDefaultBankView: View {
    
    let action: () -> Void
    let config: DeleteDefaultBankConfig
    
    var body: some View {
        
        HStack(spacing: 17) {
            
            config.iconConfig.icon
                .resizable()
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(config.iconConfig.foreground)
            
            VStack(spacing: 8) {
                
                config.title.text(
                    withConfig: config.titleConfig
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                
                config.description.text(
                    withConfig: config.descriptionConfig
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button(action: action) {
                
                config.buttonConfig.icon
                    .resizable()
                    .foregroundColor(config.buttonConfig.foreground)
                    .frame(width: 24, height: 24, alignment: .center)
            }
        }
        .background(config.backgroundView)
        .cornerRadius(12)
    }
}

struct DeleteDefaultBankView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            deleteBankDefaultView()
        }
        .padding()
    }
    
    static func deleteBankDefaultView() -> some View {
        
        DeleteDefaultBankView(
            action: {},
            config: .preview
        )
    }
}

extension DeleteDefaultBankConfig {
    
    static let preview: Self = .init(
        title: "Удалить банк по умолчанию",
        titleConfig: .init(textFont: .system(size: 16), textColor: .black),
        description: "Вы можете удалить любой банк ранее установленный по умолчанию",
        descriptionConfig: .init(textFont: .system(size: 12), textColor: .white),
        iconConfig: .init(icon: .init(systemName: "building.columns"), foreground: .black),
        buttonConfig: .init(icon: .init(systemName: "xmark.circle"), foreground: .gray),
        backgroundView: .red
    )
}
