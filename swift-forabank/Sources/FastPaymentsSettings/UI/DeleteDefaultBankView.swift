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
            
            config.icon
                .resizable()
                .frame(width: 24, height: 24, alignment: .center)
            
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
            
            config.buttonIcon
                .resizable()
                .frame(width: 24, height: 24, alignment: .center)
                .onTapGesture(perform: action)
        }
        .padding(.leading, 17)
        .padding(.trailing, 20)
        .padding(.vertical, 13)
        .background(Color.gray)
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
        icon: .init(systemName: "building.columns"),
        buttonIcon: .init(systemName: "xmark.circle")
    )
}
